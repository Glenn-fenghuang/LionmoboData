//
//  LionmoboDataCrashManager.m
//  LionmoboData
//
//  Created by LionmoboData on 2025/7/7.
//  Copyright © 2025 Lionmobo. All rights reserved.
//

#import "LionmoboDataCrashManager.h"
#import "LionmoboDataCrashReport.h"
#import "../Logging/LionmoboDataLogger.h"
#import "../Notification/LionmoboDataNotificationManager.h"
#import <signal.h>
#import <unistd.h>
#import <fcntl.h>
#import <UIKit/UIKit.h>
#import <sys/time.h>
#import <string.h>
#import <execinfo.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <sys/utsname.h>
#import <sys/sysctl.h>
#import <CoreFoundation/CoreFoundation.h>
#import "../Utils/LionmoboDataNetworkManager.h"
#import "../Utils/LionmoboDataTools.h"
#import "../Utils/DeviceInfo.h"
// 崩溃文件存储相关常量
static NSString * const kCrashReportsDirectory = @"LionmoboDataCrashReports";
static NSString * const kCrashReportFileExtension = @"crash";
static NSString * const kRawCrashInfoExtension = @"raw";
static NSString * const kUploadedCrashReportsKey = @"UploadedCrashReports";

// 静态变量用于信号处理
static LionmoboDataCrashManager *_crashManagerInstance = nil;
static NSUncaughtExceptionHandler *_previousExceptionHandler = NULL;

// 信号安全的全局变量
static char g_crashReportsPath[1024] = {0};
static char g_currentScreenName[256] = "Unknown"; // 缓存当前屏幕名称
static volatile sig_atomic_t g_signalHandlerInProgress = 0;
static volatile sig_atomic_t g_crashHandlerInProgress = 0; // 新增：防止重复崩溃处理
static volatile time_t g_lastCrashTime = 0; // 上次崩溃时间，用于去重
// 崩溃日志上传地址（内部配置，不对外暴露）
static NSString * const kCrashUploadURL = @"https://api.lionmobo.com/v1/click-events";
@interface LionmoboDataCrashManager ()

@property (nonatomic, strong) NSString *crashReportsPath;
@property (nonatomic, strong) dispatch_queue_t crashQueue;
@property (nonatomic, assign) BOOL isMonitoring;

// 私有方法声明
- (void)setupCrashReportsDirectory;
- (void)setupExceptionHandler;
- (void)setupSignalHandler;
- (void)restoreExceptionHandler;
- (void)restoreSignalHandler;
- (void)processRawCrashFiles;
- (LionmoboDataCrashReport *)convertRawCrashInfoToReport:(NSString *)filePath;
- (NSString *)getCurrentScreenNameSafe;
- (void)saveCrashReportImmediately:(LionmoboDataCrashReport *)crashReport;
- (NSArray<LionmoboDataCrashReport *> *)getAllCrashReportsSync;
- (LionmoboDataCrashReport *)loadCrashReportFromFile:(NSString *)filePath;
- (BOOL)deleteCrashReportSync:(LionmoboDataCrashReport *)crashReport;
- (void)cleanupOldCrashReports;
- (void)performUploadCrashReport:(LionmoboDataCrashReport *)crashReport completion:(void(^)(BOOL success, NSError *error))completion;
- (void)markCrashReportAsUploaded:(LionmoboDataCrashReport *)crashReport;
- (NSString *)getCurrentDeviceModel;
- (UIViewController *)getTopViewController;
- (UIViewController *)topViewControllerFromViewController:(UIViewController *)viewController;
- (NSArray<NSString *> *)symbolizeCallStack:(NSArray<NSString *> *)addressStrings;
- (void)updateCurrentScreenNameCache;

@end

// 纯C函数，信号安全的崩溃信息写入
void writeCrashInfoSafe(int signal) {
    if (g_crashReportsPath[0] == '\0') {
        return; // 路径未初始化
    }
    
    // 时间窗去重检查（3秒内的重复崩溃不处理）
    time_t currentTime = time(NULL);
    if (g_lastCrashTime != 0 && (currentTime - g_lastCrashTime) < 3) {
        return; // 短时间内的重复崩溃，跳过处理
    }
    g_lastCrashTime = currentTime;
    char fileName[256];
    snprintf(fileName, sizeof(fileName), "crash_%ld_%d.raw", (long)currentTime, signal);
    
    // 构建完整路径
    char fullPath[1024];
    snprintf(fullPath, sizeof(fullPath), "%s/%s", g_crashReportsPath, fileName);
    
    // 打开文件进行写入
    int fd = open(fullPath, O_CREAT | O_WRONLY | O_TRUNC, 0644);
    if (fd == -1) {
        return; // 无法创建文件，静默返回
    }
    
    // 获取当前调用栈
    void *callstack[128];
    int frames = backtrace(callstack, 128);
    char **symbols = backtrace_symbols(callstack, frames);
    
    // 构建调用栈字符串
    char callStackString[4096] = {0};
    if (symbols) {
        for (int i = 0; i < frames && i < 50; i++) { // 限制调用栈深度
            if (strlen(callStackString) + strlen(symbols[i]) + 3 < sizeof(callStackString)) {
                if (i > 0) {
                    strcat(callStackString, "\\n");
                }
                strcat(callStackString, symbols[i]);
            }
        }
        free(symbols);
    }
    
    // 获取信号名称
    const char* signalName;
    switch (signal) {
        case SIGABRT: signalName = "SIGABRT"; break;
        case SIGBUS: signalName = "SIGBUS"; break;
        case SIGFPE: signalName = "SIGFPE"; break;
        case SIGILL: signalName = "SIGILL"; break;
        case SIGPIPE: signalName = "SIGPIPE"; break;
        case SIGSEGV: signalName = "SIGSEGV"; break;
        case SIGSYS: signalName = "SIGSYS"; break;
        case SIGTRAP: signalName = "SIGTRAP"; break;
        default: signalName = "UNKNOWN"; break;
    }
    
    // 获取app版本信息（信号安全方式）
    char appVersion[256] = "Unknown";
    CFStringRef versionRef = (CFStringRef)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), CFSTR("CFBundleShortVersionString"));
    if (versionRef) {
        CFStringGetCString(versionRef, appVersion, sizeof(appVersion), kCFStringEncodingUTF8);
    }
    
    // 获取系统版本信息（信号安全方式）
    char systemVersion[256] = "Unknown";
    struct utsname systemInfo;
    if (uname(&systemInfo) == 0) {
        snprintf(systemVersion, sizeof(systemVersion), "%s %s", systemInfo.sysname, systemInfo.release);
    }
    
    // 获取设备型号（信号安全方式）
    char deviceModel[256] = "Unknown";
    size_t size = sizeof(deviceModel);
    sysctlbyname("hw.machine", deviceModel, &size, NULL, 0);
    
    // 写入崩溃信息（使用简单的文本格式）
    char crashInfo[8192];
    snprintf(crashInfo, sizeof(crashInfo),
             "type=signal\n"
             "signal=%d\n"
             "time=%ld\n"
             "name=%s\n"
             "screen=%s\n"
             "reason=Signal %d (%s)\n"
             "version=%s\n"
             "system=%s\n"
             "device=%s\n"
             "callstack=%s\n",
             signal, (long)currentTime, signalName, g_currentScreenName, signal, signalName, appVersion, systemVersion, deviceModel, callStackString);
    
    // 写入文件
    write(fd, crashInfo, strlen(crashInfo));
    fsync(fd);
    close(fd);
}

// 安全的信号处理函数 - 只使用 async-signal-safe 函数
void LionmoboDataSignalHandler(int sig) {
    // 避免重入和重复处理
    if (g_signalHandlerInProgress || g_crashHandlerInProgress) {
        return;
    }
    g_signalHandlerInProgress = 1;
    g_crashHandlerInProgress = 1; // 标记崩溃处理正在进行
    
    // 使用纯C函数保存崩溃信息
    writeCrashInfoSafe(sig);
    
    g_signalHandlerInProgress = 0;
    
    // 恢复默认信号处理并重新发送信号
    signal(sig, SIG_DFL);
    raise(sig);
}

// 异常处理函数
void LionmoboDataUncaughtExceptionHandler(NSException *exception) {
    // 检查是否已经在处理崩溃
    if (g_crashHandlerInProgress) {
        // 如果信号处理器已经在处理，直接调用之前的异常处理器
        if (_previousExceptionHandler) {
            _previousExceptionHandler(exception);
        }
        return;
    }
    
    g_crashHandlerInProgress = 1; // 标记崩溃处理正在进行
    
    if (_crashManagerInstance && _crashManagerInstance.enabled) {
        // 直接写入原始异常信息文件，避免复杂对象操作
        [_crashManagerInstance writeExceptionInfoSafe:exception];
    }
    
    // 调用之前的异常处理器
    if (_previousExceptionHandler) {
        _previousExceptionHandler(exception);
    }
}

// 先前的信号处理器
static struct sigaction previous_sigabrt_handler;
static struct sigaction previous_sigbus_handler;
static struct sigaction previous_sigfpe_handler;
static struct sigaction previous_sigill_handler;
static struct sigaction previous_sigpipe_handler;
static struct sigaction previous_sigsegv_handler;
static struct sigaction previous_sigsys_handler;
static struct sigaction previous_sigtrap_handler;

@implementation LionmoboDataCrashManager

#pragma mark - 单例

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _crashManagerInstance = [[self alloc] init];
    });
    return _crashManagerInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _enabled = YES;
        _maxCrashReports = 10;
        _isMonitoring = NO;
        _uploadURL = kCrashUploadURL;
        [self setupCrashReportsDirectory];
        self.crashQueue = dispatch_queue_create("LionmoboData.CrashQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - 崩溃监控管理

- (void)startCrashMonitoring {
    if (!self.enabled || self.isMonitoring) {
        return;
    }
    
    dispatch_async(self.crashQueue, ^{
        // 首先处理之前保存的原始崩溃信息文件
        [self processRawCrashFiles];
        
        [self setupExceptionHandler];
        [self setupSignalHandler];
        self.isMonitoring = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [LionmoboDataNotificationManager postCrashMonitoringStarted];
        });
    });
}

- (void)stopCrashMonitoring {
    if (!self.isMonitoring) {
        return;
    }
    
    dispatch_async(self.crashQueue, ^{
        [self restoreExceptionHandler];
        [self restoreSignalHandler];
        self.isMonitoring = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            LMBLog(@"停止崩溃监控");
            [LionmoboDataNotificationManager postCrashMonitoringStopped];
        });
    });
}

#pragma mark - 异常和信号处理器设置

- (void)setupExceptionHandler {
    _previousExceptionHandler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(LionmoboDataUncaughtExceptionHandler);
}

- (void)setupSignalHandler {
    // 初始化全局路径变量
    const char* pathCStr = [self.crashReportsPath UTF8String];
    strncpy(g_crashReportsPath, pathCStr, sizeof(g_crashReportsPath) - 1);
    g_crashReportsPath[sizeof(g_crashReportsPath) - 1] = '\0';
    
    // 初始化当前屏幕名称缓存
    [self updateCurrentScreenNameCache];
    
    struct sigaction action;
    sigemptyset(&action.sa_mask);
    action.sa_flags = SA_NODEFER | SA_ONSTACK;
    action.sa_handler = LionmoboDataSignalHandler;
    
    // 设置信号处理器并保存原有的
    sigaction(SIGABRT, &action, &previous_sigabrt_handler);
    sigaction(SIGBUS, &action, &previous_sigbus_handler);
    sigaction(SIGFPE, &action, &previous_sigfpe_handler);
    sigaction(SIGILL, &action, &previous_sigill_handler);
    sigaction(SIGPIPE, &action, &previous_sigpipe_handler);
    sigaction(SIGSEGV, &action, &previous_sigsegv_handler);
    sigaction(SIGSYS, &action, &previous_sigsys_handler);
    sigaction(SIGTRAP, &action, &previous_sigtrap_handler);
}

- (void)restoreExceptionHandler {
    NSSetUncaughtExceptionHandler(_previousExceptionHandler);
    _previousExceptionHandler = NULL;
}

- (void)restoreSignalHandler {
    // 清理全局路径变量
    memset(g_crashReportsPath, 0, sizeof(g_crashReportsPath));
    memset(g_currentScreenName, 0, sizeof(g_currentScreenName));
    strncpy(g_currentScreenName, "Unknown", sizeof(g_currentScreenName) - 1);
    g_signalHandlerInProgress = 0;
    g_crashHandlerInProgress = 0; // 清理崩溃处理标志
    g_lastCrashTime = 0; // 清理上次崩溃时间
    
    // 恢复原有信号处理器
    sigaction(SIGABRT, &previous_sigabrt_handler, NULL);
    sigaction(SIGBUS, &previous_sigbus_handler, NULL);
    sigaction(SIGFPE, &previous_sigfpe_handler, NULL);
    sigaction(SIGILL, &previous_sigill_handler, NULL);
    sigaction(SIGPIPE, &previous_sigpipe_handler, NULL);
    sigaction(SIGSEGV, &previous_sigsegv_handler, NULL);
    sigaction(SIGSYS, &previous_sigsys_handler, NULL);
    sigaction(SIGTRAP, &previous_sigtrap_handler, NULL);
}

#pragma mark - 崩溃报告管理

- (NSArray<LionmoboDataCrashReport *> *)getAllCrashReports {
    __block NSArray<LionmoboDataCrashReport *> *reports;
    dispatch_sync(self.crashQueue, ^{
        reports = [self getAllCrashReportsSync];
    });
    return reports;
}

- (NSArray<LionmoboDataCrashReport *> *)getPendingCrashReports {
    NSArray<LionmoboDataCrashReport *> *allReports = [self getAllCrashReports];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *uploadedReportIds = [defaults arrayForKey:kUploadedCrashReportsKey] ?: @[];
    
    // 过滤出未上传的报告
    NSMutableArray<LionmoboDataCrashReport *> *pendingReports = [NSMutableArray array];
    for (LionmoboDataCrashReport *report in allReports) {
        if (![uploadedReportIds containsObject:report.reportId]) {
            [pendingReports addObject:report];
        }
    }
    
    return [pendingReports copy];
}

- (void)uploadCrashReport:(LionmoboDataCrashReport *)crashReport
               completion:(nullable void(^)(BOOL success, NSError *error))completion {
    if (!crashReport) {
        if (completion) {
            completion(NO, [NSError errorWithDomain:@"LionmoboDataCrashManager" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"崩溃报告为空"}]);
        }
        return;
    }
    
    dispatch_async(self.crashQueue, ^{
        [self performUploadCrashReport:crashReport completion:completion];
    });
}

- (void)uploadAllPendingCrashReportsWithCompletion:(nullable void(^)(NSInteger successCount, NSInteger failureCount, NSArray<NSError *> *errors))completion {
    dispatch_async(self.crashQueue, ^{
        NSArray<LionmoboDataCrashReport *> *pendingReports = [self getAllCrashReportsSync];
        
        if (pendingReports.count == 0) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(0, 0, @[]);
                });
            }
            return;
        }
        
        __block NSInteger successCount = 0;
        __block NSInteger failureCount = 0;
        __block NSMutableArray<NSError *> *errors = [NSMutableArray array];
        
        dispatch_group_t group = dispatch_group_create();
        
        for (LionmoboDataCrashReport *report in pendingReports) {
            dispatch_group_enter(group);
            [self performUploadCrashReport:report completion:^(BOOL success, NSError *error) {
                if (success) {
                    successCount++;
                } else {
                    failureCount++;
                    if (error) {
                        [errors addObject:error];
                    }
                }
                dispatch_group_leave(group);
            }];
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if (completion) {
                completion(successCount, failureCount, [errors copy]);
            }
        });
    });
}

- (BOOL)deleteCrashReport:(LionmoboDataCrashReport *)crashReport {
    __block BOOL success = NO;
    dispatch_sync(self.crashQueue, ^{
        success = [self deleteCrashReportSync:crashReport];
    });
    return success;
}

- (void)clearAllCrashReports {
    dispatch_async(self.crashQueue, ^{
        NSArray<LionmoboDataCrashReport *> *allReports = [self getAllCrashReportsSync];
        for (LionmoboDataCrashReport *report in allReports) {
            [self deleteCrashReportSync:report];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            LMBLog(@"已清除所有崩溃报告");
            [LionmoboDataNotificationManager postAllCrashReportsCleared];
        });
    });
}

- (void)saveCrashReport:(LionmoboDataCrashReport *)crashReport {
    if (!crashReport) {
        return;
    }
    
    dispatch_async(self.crashQueue, ^{
        [self saveCrashReportImmediately:crashReport];
    });
}

- (void)saveCrashReportImmediate:(LionmoboDataCrashReport *)crashReport {
    [self saveCrashReportImmediately:crashReport];
}

- (void)writeExceptionInfoSafe:(NSException *)exception {
    if (!exception) {
        return;
    }
    
    @try {
        // 时间窗去重检查（3秒内的重复崩溃不处理）
        time_t currentTime = time(NULL);
        if (g_lastCrashTime != 0 && (currentTime - g_lastCrashTime) < 3) {
            return; // 短时间内的重复崩溃，跳过处理
        }
        g_lastCrashTime = currentTime;
        
        // 创建文件名（使用时间戳和异常类型）
        NSString *exceptionName = exception.name ?: @"UnknownException";
        NSString *fileName = [NSString stringWithFormat:@"exception_%ld_%@.raw", (long)currentTime, exceptionName];
        NSString *filePath = [self.crashReportsPath stringByAppendingPathComponent:fileName];
        
        // 收集异常信息
        NSMutableString *exceptionInfo = [NSMutableString string];
        [exceptionInfo appendFormat:@"type=exception\n"];
        [exceptionInfo appendFormat:@"time=%ld\n", (long)currentTime];
        [exceptionInfo appendFormat:@"name=%@\n", exception.name ?: @"Unknown"];
        [exceptionInfo appendFormat:@"reason=%@\n", exception.reason ?: @"Unknown"];
        [exceptionInfo appendFormat:@"screen=%@\n", [self getCurrentScreenNameSafe]];
        [exceptionInfo appendFormat:@"version=%@\n", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"Unknown"];
        [exceptionInfo appendFormat:@"system=%@\n", [[UIDevice currentDevice] systemVersion]];
        [exceptionInfo appendFormat:@"device=%@\n", [self getCurrentDeviceModel]];
        
        // 添加调用栈
        if (exception.callStackSymbols && exception.callStackSymbols.count > 0) {
            [exceptionInfo appendString:@"callstack_start\n"];
            for (NSString *symbol in exception.callStackSymbols) {
                [exceptionInfo appendFormat:@"%@\n", symbol];
            }
            [exceptionInfo appendString:@"callstack_end\n"];
        }
        
        // 添加用户信息
        if (exception.userInfo && exception.userInfo.count > 0) {
            [exceptionInfo appendString:@"userinfo_start\n"];
            for (NSString *key in exception.userInfo) {
                [exceptionInfo appendFormat:@"%@=%@\n", key, exception.userInfo[key]];
            }
            [exceptionInfo appendString:@"userinfo_end\n"];
        }
        
        // 写入文件
        [exceptionInfo writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
    } @catch (NSException *writeException) {
        // 如果写入过程中出错，静默处理，避免二次崩溃
    }
}

#pragma mark - 私有方法实现

- (void)setupCrashReportsDirectory {
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    self.crashReportsPath = [documentsDirectory stringByAppendingPathComponent:kCrashReportsDirectory];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if (![fileManager createDirectoryAtPath:self.crashReportsPath
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:&error]) {
        LMBLogError(@"创建崩溃报告目录失败: %@", error.localizedDescription);
    } else {
        LMBLogDebug(@"崩溃报告目录: %@", self.crashReportsPath);
    }
}

- (void)saveCrashReportImmediately:(LionmoboDataCrashReport *)crashReport {
    if (!crashReport.reportId) {
        crashReport.reportId = [[NSUUID UUID] UUIDString];
    }
    
    if (!crashReport.createdAt) {
        crashReport.createdAt = [NSDate date];
    }
    
    NSString *fileName = [NSString stringWithFormat:@"%@.%@", crashReport.reportId, kCrashReportFileExtension];
    NSString *filePath = [self.crashReportsPath stringByAppendingPathComponent:fileName];
    
         @try {
         NSData *data;
         if (@available(iOS 11.0, *)) {
             data = [NSKeyedArchiver archivedDataWithRootObject:crashReport requiringSecureCoding:NO error:nil];
         } else {
             data = [NSKeyedArchiver archivedDataWithRootObject:crashReport];
         }
         if (data && [data writeToFile:filePath atomically:YES]) {
            [self cleanupOldCrashReports];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                LMBLog(@"已保存崩溃报告: %@ [%@]", crashReport.reportId, crashReport.appCrashedReason);
                [LionmoboDataNotificationManager postCrashReportSaved:crashReport];
            });
        } else {
            LMBLogError(@"保存崩溃报告失败: %@", crashReport.reportId);
        }
    } @catch (NSException *exception) {
        LMBLogError(@"保存崩溃报告异常: %@", exception.reason);
    }
}

- (NSArray<LionmoboDataCrashReport *> *)getAllCrashReportsSync {
    NSMutableArray<LionmoboDataCrashReport *> *reports = [NSMutableArray array];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:self.crashReportsPath error:nil];
    
    for (NSString *fileName in files) {
        if ([fileName hasSuffix:kCrashReportFileExtension]) {
            NSString *filePath = [self.crashReportsPath stringByAppendingPathComponent:fileName];
            LionmoboDataCrashReport *report = [self loadCrashReportFromFile:filePath];
            if (report) {
                [reports addObject:report];
            }
        }
    }
    
    // 按创建时间排序
    [reports sortUsingComparator:^NSComparisonResult(LionmoboDataCrashReport *obj1, LionmoboDataCrashReport *obj2) {
        return [obj2.createdAt compare:obj1.createdAt];
    }];
    
    return [reports copy];
}

- (LionmoboDataCrashReport *)loadCrashReportFromFile:(NSString *)filePath {
         @try {
         NSData *data = [NSData dataWithContentsOfFile:filePath];
         if (data) {
             if (@available(iOS 11.0, *)) {
                 return [NSKeyedUnarchiver unarchivedObjectOfClass:[LionmoboDataCrashReport class] fromData:data error:nil];
             } else {
                 return [NSKeyedUnarchiver unarchiveObjectWithData:data];
             }
         }
    } @catch (NSException *exception) {
        LMBLogError(@"加载崩溃报告失败: %@", exception.reason);
    }
    return nil;
}

- (BOOL)deleteCrashReportSync:(LionmoboDataCrashReport *)crashReport {
    if (!crashReport.reportId) {
        return NO;
    }
    
    NSString *fileName = [NSString stringWithFormat:@"%@.%@", crashReport.reportId, kCrashReportFileExtension];
    NSString *filePath = [self.crashReportsPath stringByAppendingPathComponent:fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    
    if (success) {
        LMBLogDebug(@"已删除崩溃报告: %@", crashReport.reportId);
    } else {
        LMBLogError(@"删除崩溃报告失败: %@", error.localizedDescription);
    }
    
    return success;
}

- (void)cleanupOldCrashReports {
    NSArray<LionmoboDataCrashReport *> *allReports = [self getAllCrashReportsSync];
    
    if (allReports.count > self.maxCrashReports) {
        NSArray<LionmoboDataCrashReport *> *reportsToDelete = [allReports subarrayWithRange:NSMakeRange(self.maxCrashReports, allReports.count - self.maxCrashReports)];
        
        for (LionmoboDataCrashReport *report in reportsToDelete) {
            [self deleteCrashReportSync:report];
        }
        
        LMBLogDebug(@"清理了 %lu 个旧的崩溃报告", (unsigned long)reportsToDelete.count);
    }
}

- (void)performUploadCrashReport:(LionmoboDataCrashReport *)crashReport completion:(void(^)(BOOL success, NSError *error))completion {
    long long timestampMs = (long long)(crashReport.crashTime * 1000);
    NSDictionary *appCrashed = @{@"user_id":[LionmoboDataTools detail].user_id,
                                 @"app_crashed_reason":crashReport.appCrashedReason,
                                 @"crash_time":[NSNumber numberWithLongLong:timestampMs],
                                 @"screen_name":crashReport.screenName,
                                 @"eventName":@"AppCrashed"};
    NSArray *items = @[appCrashed];
    NSDictionary *paramets = @{@"details":items};
    [[LionmoboDataNetworkManager sharedManager] requestWithURL:@"/api/sdkPutEvents" method:LionmoboHTTPMethodPOST parameters:paramets headers:nil success:^(NSData * _Nullable data, NSDictionary * _Nullable responseObject) {
        if (responseObject) {
            NSError *error = nil;
            NSInteger code = [NSString stringWithFormat:@"%@",responseObject[@"code"]].integerValue;
            if (code == 200) {
                [self markCrashReportAsUploaded:crashReport];
                // 上传成功后删除本地文件
                [self deleteCrashReportSync:crashReport];
                dispatch_async(dispatch_get_main_queue(), ^{
                    LMBLogSuccess(@"崩溃报告上传成功: %@", crashReport.reportId);
                    [LionmoboDataNotificationManager postCrashReportUploaded:crashReport];
                    completion(YES, error);
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *userInfo = responseObject; // 确保 responseObject 是 NSDictionary
                    NSError *error = [NSError errorWithDomain:@"com.lionmobodata.domain"
                                                         code:code
                                                     userInfo:userInfo];
                    LMBLogError(@"崩溃报告上传失败: %@", crashReport.reportId);
                    completion(NO, error);
                });
            }
        }
    } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                LMBLogError(@"崩溃报告上传失败: %@", crashReport.reportId);
                completion(NO, error);
            });
        }
    }];
}

- (void)markCrashReportAsUploaded:(LionmoboDataCrashReport *)crashReport {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *uploadedReports = [defaults arrayForKey:kUploadedCrashReportsKey] ?: @[];
    NSMutableArray *mutableUploadedReports = [uploadedReports mutableCopy];
    
    if (![mutableUploadedReports containsObject:crashReport.reportId]) {
        [mutableUploadedReports addObject:crashReport.reportId];
        [defaults setObject:[mutableUploadedReports copy] forKey:kUploadedCrashReportsKey];
        [defaults synchronize];
    }
}

- (void)processRawCrashFiles {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:self.crashReportsPath error:nil];
    
    for (NSString *fileName in files) {
        if ([fileName hasSuffix:@".raw"]) {
            NSString *filePath = [self.crashReportsPath stringByAppendingPathComponent:fileName];
            
            // 转换原始崩溃信息为正式报告
            LionmoboDataCrashReport *crashReport = [self convertRawCrashInfoToReport:filePath];
            if (crashReport) {
                // 保存为正式的崩溃报告
                [self saveCrashReportImmediately:crashReport];
                
                // 删除原始文件
                [fileManager removeItemAtPath:filePath error:nil];
                LMBLogSuccess(@"成功转换崩溃信息: %@ [%@]", crashReport.reportId, crashReport.appCrashedReason);
                LMBLogDebug(@"崩溃页面: %@", crashReport.screenName);
                LMBLogDebug(@"设备信息: %@ %@", crashReport.deviceModel, crashReport.systemVersion);
                LMBLogDebug(@"调用栈帧数: %lu", (unsigned long)crashReport.callStack.count);
            } else {
                LMBLogError(@"转换崩溃信息失败: %@", fileName);
            }
        }
    }
}

- (LionmoboDataCrashReport *)convertRawCrashInfoToReport:(NSString *)filePath {
    @try {
        NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        if (!content || content.length == 0) {
            LMBLogError(@"原始崩溃文件为空或无法读取: %@", filePath);
            return nil;
        }
        
        LionmoboDataCrashReport *report = [[LionmoboDataCrashReport alloc] init];
        if (!report) {
            LMBLogError(@"无法创建崩溃报告对象");
            return nil;
        }
        
        // 解析原始崩溃信息
        NSArray *lines = [content componentsSeparatedByString:@"\n"];
        NSMutableArray *callStack = [NSMutableArray array];
        BOOL inCallStack = NO;
        BOOL inUserInfo = NO;
        NSString *crashType = @"signal"; // 默认为信号
        
        for (NSString *line in lines) {
            NSString *trimmedLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            if ([trimmedLine isEqualToString:@"callstack_start"]) {
                inCallStack = YES;
                continue;
            } else if ([trimmedLine isEqualToString:@"callstack_end"]) {
                inCallStack = NO;
                continue;
            } else if ([trimmedLine isEqualToString:@"userinfo_start"]) {
                inUserInfo = YES;
                continue;
            } else if ([trimmedLine isEqualToString:@"userinfo_end"]) {
                inUserInfo = NO;
                continue;
            }
            
            if (inCallStack && trimmedLine.length > 0) {
                [callStack addObject:trimmedLine];
            } else if (!inUserInfo && !inCallStack) {
                NSArray *components = [trimmedLine componentsSeparatedByString:@"="];
                if (components.count >= 2) {
                    NSString *key = [components[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    NSString *value = [[components subarrayWithRange:NSMakeRange(1, components.count - 1)] componentsJoinedByString:@"="];
                    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    
                    // 安全检查
                    if (!key || key.length == 0) {
                        continue;
                    }
                    
                    if ([key isEqualToString:@"type"]) {
                        crashType = value;
                    } else if ([key isEqualToString:@"time"]) {
                        report.crashTime = [value doubleValue];
                    } else if ([key isEqualToString:@"screen"]) {
                        report.screenName = value;
                    } else if ([key isEqualToString:@"reason"]) {
                        report.appCrashedReason = value;
                    } else if ([key isEqualToString:@"name"] && [crashType isEqualToString:@"exception"]) {
                        // 对于异常，组合名称和原因
                        NSString *currentReason = report.appCrashedReason ?: @"";
                        report.appCrashedReason = [NSString stringWithFormat:@"Exception: %@ - %@", value, currentReason];
                    } else if ([key isEqualToString:@"version"]) {
                        report.appVersion = value;
                    } else if ([key isEqualToString:@"system"]) {
                        report.systemVersion = value;
                    } else if ([key isEqualToString:@"device"]) {
                        report.deviceModel = value;
                    } else if ([key isEqualToString:@"callstack"]) {
                        // 处理信号崩溃的调用栈（使用\\n分隔）
                        if (value && value.length > 0) {
                            NSArray *stackFrames = [value componentsSeparatedByString:@"\\n"];
                            [callStack addObjectsFromArray:stackFrames];
                        }
                    }
                }
            }
        }
        
        // 处理调用栈
        if (callStack.count > 0) {
            if ([crashType isEqualToString:@"exception"]) {
                // 异常崩溃已经有符号化的调用栈
                report.callStack = [callStack copy];
            } else {
                // 信号崩溃需要尝试符号化地址
                report.callStack = [self symbolizeCallStack:callStack];
            }
        } else {
            report.callStack = @[@"No call stack available"];
        }
        
                 // 设置其他必要字段
         report.reportId = [[NSUUID UUID] UUIDString];
         if (report.crashTime == 0) {
             report.crashTime = [[NSDate date] timeIntervalSince1970];
         }
         report.createdAt = [NSDate dateWithTimeIntervalSince1970:report.crashTime];
        
        // 如果没有设置原因，根据类型设置默认原因
        if (!report.appCrashedReason || report.appCrashedReason.length == 0) {
            report.appCrashedReason = [crashType isEqualToString:@"exception"] ? @"Uncaught Exception" : @"Signal Crash";
        }
        
        // 设置其他基本信息（如果没有在原始文件中找到）
        if (!report.appVersion) {
            report.appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"Unknown";
        }
        if (!report.systemVersion) {
            report.systemVersion = [[UIDevice currentDevice] systemVersion];
        }
        if (!report.deviceModel) {
            report.deviceModel = [self getCurrentDeviceModel];
        }
        if (!report.screenName) {
            report.screenName = @"Unknown";
        }
        
        return report;
    } @catch (NSException *exception) {
        LMBLogError(@"转换原始崩溃信息失败: %@", exception.reason);
        return nil;
    }
}

- (NSArray<NSString *> *)symbolizeCallStack:(NSArray<NSString *> *)addressStrings {
    NSMutableArray *symbolizedStack = [NSMutableArray array];
    
    for (NSString *addressString in addressStrings) {
        // 解析地址
        unsigned long address = strtoul([addressString UTF8String], NULL, 16);
        if (address == 0) {
            [symbolizedStack addObject:addressString];
            continue;
        }
        
        // 尝试获取符号信息
        Dl_info dlinfo;
        if (dladdr((void *)address, &dlinfo)) {
            NSString *symbolInfo;
            if (dlinfo.dli_sname) {
                // 有符号名称
                symbolInfo = [NSString stringWithFormat:@"%s + %ld (%s + %ld)",
                             dlinfo.dli_sname,
                             address - (unsigned long)dlinfo.dli_saddr,
                             dlinfo.dli_fname ?: "Unknown",
                             address - (unsigned long)dlinfo.dli_fbase];
            } else {
                // 只有文件名
                symbolInfo = [NSString stringWithFormat:@"%s + %ld",
                             dlinfo.dli_fname ?: "Unknown",
                             address - (unsigned long)dlinfo.dli_fbase];
            }
            [symbolizedStack addObject:symbolInfo];
        } else {
            // 无法符号化，保留原始地址
            [symbolizedStack addObject:[NSString stringWithFormat:@"0x%lx", address]];
        }
    }
    
    return [symbolizedStack copy];
}

- (NSString *)getCurrentDeviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

- (NSString *)getCurrentScreenNameSafe {
    @try {
        // 尝试获取当前屏幕信息
        if ([NSThread isMainThread]) {
            UIViewController *topViewController = [self getTopViewController];
            if (topViewController) {
                return NSStringFromClass([topViewController class]);
            }
        }
        return @"Background";
    } @catch (NSException *exception) {
        return @"Unknown";
    }
}

- (UIViewController *)getTopViewController {
    UIWindow *keyWindow = nil;
    
    // iOS 13+ 方式获取 keyWindow
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        keyWindow = window;
                        break;
                    }
                }
            }
        }
    }
    
    // 降级方案
    if (!keyWindow) {
        keyWindow = [UIApplication sharedApplication].keyWindow;
    }
    
    // 最终降级方案
    if (!keyWindow) {
        keyWindow = [UIApplication sharedApplication].windows.firstObject;
    }
    
    return [self topViewControllerFromViewController:keyWindow.rootViewController];
}

- (UIViewController *)topViewControllerFromViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)viewController;
        return [self topViewControllerFromViewController:navigationController.visibleViewController];
    } else if ([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)viewController;
        return [self topViewControllerFromViewController:tabBarController.selectedViewController];
    } else if (viewController.presentedViewController) {
        return [self topViewControllerFromViewController:viewController.presentedViewController];
    }
    return viewController;
}

- (void)updateCurrentScreenNameCache {
    @try {
        NSString *screenName = [self getCurrentScreenNameSafe];
        if (screenName && screenName.length > 0) {
            const char *screenNameCStr = [screenName UTF8String];
            strncpy(g_currentScreenName, screenNameCStr, sizeof(g_currentScreenName) - 1);
            g_currentScreenName[sizeof(g_currentScreenName) - 1] = '\0';
        }
    } @catch (NSException *exception) {
        // 如果获取失败，保持默认值
        strncpy(g_currentScreenName, "Unknown", sizeof(g_currentScreenName) - 1);
        g_currentScreenName[sizeof(g_currentScreenName) - 1] = '\0';
    }
}

@end 

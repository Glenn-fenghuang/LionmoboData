//
//  LionmoboDataCrashReport.m
//  LionmoboData
//
//  Created by LionmoboData on 2025/7/7.
//  Copyright © 2025 Lionmobo. All rights reserved.
//

#import "LionmoboDataCrashReport.h"
#import "../Logging/LionmoboDataLogger.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>

@implementation LionmoboDataCrashReport

+ (BOOL)supportsSecureCoding {
    return YES;
}

#pragma mark - 初始化方法

+ (instancetype)crashReportWithException:(NSException *)exception {
    LionmoboDataCrashReport *report = [[self alloc] init];
    report.appCrashedReason = [NSString stringWithFormat:@"Exception: %@ - %@", exception.name, exception.reason];
    report.crashTime = [[NSDate date] timeIntervalSince1970];
    report.screenName = [self currentScreenName];
    report.callStack = exception.callStackSymbols ?: @[];
    [report fillSystemInfo];
    return report;
}

+ (instancetype)crashReportWithSignal:(int)signal {
    LionmoboDataCrashReport *report = [[self alloc] init];
    report.appCrashedReason = [NSString stringWithFormat:@"Signal: %d (%@)", signal, [self signalName:signal]];
    report.crashTime = [[NSDate date] timeIntervalSince1970];
    report.screenName = [self currentScreenName];
    report.callStack = [NSThread callStackSymbols];
    [report fillSystemInfo];
    return report;
}

+ (instancetype)crashReportWithSignalSafe:(int)signal {
    // 在信号处理函数中创建崩溃报告，必须使用 async-signal-safe 函数
    LionmoboDataCrashReport *report = [[self alloc] init];
    
    // 使用信号安全的方式设置崩溃原因
    report.appCrashedReason = [NSString stringWithFormat:@"Signal: %d (%@)", signal, [self signalName:signal]];
    report.crashTime = [[NSDate date] timeIntervalSince1970];
    
    // 在信号处理函数中，避免复杂的UI遍历，使用简化版本
    report.screenName = [self currentScreenNameSafe];
    
    // 在信号处理函数中，避免获取完整堆栈，使用简化版本
    report.callStack = @[@"Signal handler context - full stack trace unavailable"];
    
    // 填充基本系统信息
    [report fillSystemInfoSafe];
    
    return report;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _reportId = [[NSUUID UUID] UUIDString];
        _createdAt = [NSDate date];
    }
    return self;
}

#pragma mark - 私有方法

- (void)fillSystemInfo {
    // 应用版本
    self.appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"Unknown";
    
    // 系统版本
    self.systemVersion = [[UIDevice currentDevice] systemVersion];
    
    // 设备型号
    self.deviceModel = [self deviceModelName];
}

- (void)fillSystemInfoSafe {
    // 在信号处理函数中安全填充系统信息
    @try {
        // 应用版本 - 这个通常是安全的
        self.appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"Unknown";
        
        // 系统版本 - 这个通常是安全的
        self.systemVersion = [[UIDevice currentDevice] systemVersion] ?: @"Unknown";
        
        // 设备型号 - 使用简化版本
        self.deviceModel = [self deviceModelNameSafe];
    } @catch (NSException *exception) {
        // 如果任何操作失败，使用默认值
        self.appVersion = @"Unknown_SignalContext";
        self.systemVersion = @"Unknown_SignalContext";
        self.deviceModel = @"Unknown_SignalContext";
    }
}

- (NSString *)deviceModelName {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

- (NSString *)deviceModelNameSafe {
    // 在信号处理函数中安全获取设备型号
    @try {
        struct utsname systemInfo;
        if (uname(&systemInfo) == 0) {
            return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding] ?: @"Unknown_Device";
        }
    } @catch (NSException *exception) {
        // uname 调用失败
    }
    return @"Unknown_Device_SignalContext";
}

+ (NSString *)signalName:(int)signal {
    switch (signal) {
        case SIGABRT: return @"SIGABRT";
        case SIGBUS: return @"SIGBUS";
        case SIGFPE: return @"SIGFPE";
        case SIGILL: return @"SIGILL";
        case SIGPIPE: return @"SIGPIPE";
        case SIGSEGV: return @"SIGSEGV";
        case SIGSYS: return @"SIGSYS";
        case SIGTRAP: return @"SIGTRAP";
        default: return @"Unknown Signal";
    }
}

+ (NSString *)currentScreenName {
    __block NSString *screenName = @"Unknown";
    
    if ([NSThread isMainThread]) {
        screenName = [self getCurrentScreenNameOnMainThread];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            screenName = [self getCurrentScreenNameOnMainThread];
        });
    }
    
    return screenName;
}

+ (NSString *)currentScreenNameSafe {
    // 在信号处理函数中，避免使用 dispatch_sync
    // 只在主线程时尝试获取屏幕名称，否则返回默认值
    if ([NSThread isMainThread]) {
        @try {
            return [self getCurrentScreenNameOnMainThread];
        } @catch (NSException *exception) {
            // 即使在主线程，也可能因为信号处理器中的限制而失败
            return @"MainThread_SignalContext";
        }
    } else {
        return @"BackgroundThread_SignalContext";
    }
}

+ (NSString *)getCurrentScreenNameOnMainThread {
    UIViewController *topViewController = [self topViewController];
    if (topViewController) {
        return NSStringFromClass([topViewController class]);
    }
    return @"Unknown";
}

+ (UIViewController *)topViewController {
    UIWindow *keyWindow = nil;
    
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
    } else {
        keyWindow = [UIApplication sharedApplication].keyWindow;
    }
    
    UIViewController *rootViewController = keyWindow.rootViewController;
    return [self findTopViewController:rootViewController];
}

+ (UIViewController *)findTopViewController:(UIViewController *)viewController {
    if (viewController.presentedViewController) {
        return [self findTopViewController:viewController.presentedViewController];
    }
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)viewController;
        return [self findTopViewController:navigationController.topViewController];
    }
    
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)viewController;
        return [self findTopViewController:tabBarController.selectedViewController];
    }
    
    return viewController;
}

#pragma mark - 数据转换

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (self.appCrashedReason) dict[@"app_crashed_reason"] = self.appCrashedReason;
    dict[@"crash_time"] = @(self.crashTime);
    if (self.screenName) dict[@"screen_name"] = self.screenName;
    if (self.appVersion) dict[@"app_version"] = self.appVersion;
    if (self.systemVersion) dict[@"system_version"] = self.systemVersion;
    if (self.deviceModel) dict[@"device_model"] = self.deviceModel;
    if (self.callStack) dict[@"call_stack"] = self.callStack;
    if (self.reportId) dict[@"report_id"] = self.reportId;
    if (self.createdAt) dict[@"created_at"] = @([self.createdAt timeIntervalSince1970]);
    
    return [dict copy];
}

+ (instancetype)crashReportFromDictionary:(NSDictionary *)dictionary {
    LionmoboDataCrashReport *report = [[self alloc] init];
    
    report.appCrashedReason = dictionary[@"app_crashed_reason"];
    report.crashTime = [dictionary[@"crash_time"] doubleValue];
    report.screenName = dictionary[@"screen_name"];
    report.appVersion = dictionary[@"app_version"];
    report.systemVersion = dictionary[@"system_version"];
    report.deviceModel = dictionary[@"device_model"];
    report.callStack = dictionary[@"call_stack"];
    report.reportId = dictionary[@"report_id"];
    
    NSTimeInterval createdAtInterval = [dictionary[@"created_at"] doubleValue];
    if (createdAtInterval > 0) {
        report.createdAt = [NSDate dateWithTimeIntervalSince1970:createdAtInterval];
    }
    
    return report;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.appCrashedReason forKey:@"appCrashedReason"];
    [coder encodeDouble:self.crashTime forKey:@"crashTime"];
    [coder encodeObject:self.screenName forKey:@"screenName"];
    [coder encodeObject:self.appVersion forKey:@"appVersion"];
    [coder encodeObject:self.systemVersion forKey:@"systemVersion"];
    [coder encodeObject:self.deviceModel forKey:@"deviceModel"];
    [coder encodeObject:self.callStack forKey:@"callStack"];
    [coder encodeObject:self.reportId forKey:@"reportId"];
    [coder encodeObject:self.createdAt forKey:@"createdAt"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _appCrashedReason = [coder decodeObjectOfClass:[NSString class] forKey:@"appCrashedReason"];
        _crashTime = [coder decodeDoubleForKey:@"crashTime"];
        _screenName = [coder decodeObjectOfClass:[NSString class] forKey:@"screenName"];
        _appVersion = [coder decodeObjectOfClass:[NSString class] forKey:@"appVersion"];
        _systemVersion = [coder decodeObjectOfClass:[NSString class] forKey:@"systemVersion"];
        _deviceModel = [coder decodeObjectOfClass:[NSString class] forKey:@"deviceModel"];
        _callStack = [coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [NSString class], nil] forKey:@"callStack"];
        _reportId = [coder decodeObjectOfClass:[NSString class] forKey:@"reportId"];
        _createdAt = [coder decodeObjectOfClass:[NSDate class] forKey:@"createdAt"];
    }
    return self;
}

#pragma mark - 描述

- (NSString *)description {
    return [NSString stringWithFormat:@"<LionmoboDataCrashReport: %p> {\n  reportId: %@\n  reason: %@\n  screen: %@\n  time: %@\n}", 
            self, self.reportId, self.appCrashedReason, self.screenName, self.createdAt];
}

@end 
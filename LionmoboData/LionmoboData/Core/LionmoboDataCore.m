//
//  LionmoboDataCore.m
//  LionmoboData
//
//  Created by lionmobo on 2025/7/7.
//

#import "LionmoboDataCore.h"
#import "LionmoboData.h"
#import "LionmoboDataConfig.h"
#import "../Logging/LionmoboDataLogger.h"
#import "../Notification/LionmoboDataNotificationManager.h"
#import "../CrashManager/LionmoboDataCrashManager.h"
#import "../PageTracking/LionmoboDataPageTracker.h"
#import "../PageTracking/LionmoboDataClickTracker.h"
#import "../PageTracking/LionmoboDataAppLaunchTracker.h"
#import "../Utils/LionmoboDataNetworkManager.h"
#import "../Utils/LionmoboDataTools.h"
#import "../Utils/DeviceInfo.h"
#import "../Utils/LionmoboKeyChainTool.h"
static LionmoboDataCore *_sharedInstance = nil;
static LionmoboDataConfig *_currentConfig = nil;

@interface LionmoboDataCore ()

@property (nonatomic, strong) LionmoboDataConfig *config;
@property (nonatomic, assign) BOOL isInitialized;

@end

@implementation LionmoboDataCore

#pragma mark - 单例模式

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isInitialized = NO;
    }
    return self;
}

#pragma mark - 公共方法

+ (void)startWithConfig:(LionmoboDataConfig *)config {
    if (!config) {
        LMBLogError(@"LionmoboData启动失败：appID不能为空");
        return;
    }
    
    // 首先设置日志系统，使用debugMode作为唯一的日志开关
    [LionmoboDataLogger setLogEnabled:config.debugMode];
    
    if (!config.appID || config.appID.length == 0) {
        LMBLogError(@"LionmoboData启动失败：appID不能为空");
        return;
    }
    if (!config.apiSecret || config.apiSecret.length == 0) {
        LMBLogError(@"LionmoboData启动失败：apiSecret不能为空");
        return;
    }
    if (!config.apiKey || config.apiKey.length == 0) {
        LMBLogError(@"LionmoboData启动失败：apiSecret不能为空");
        return;
    }
    
    LionmoboDataCore *instance = [self sharedInstance];
    instance.config = config;
    _currentConfig = config;
    LMBLog(@"LionmoboData SDK 开始初始化，App ID: %@", config.appID);
    // 设置网络日志是否开启，仅调试模式开启
    [instance setNetworkLogManager];
    
    // 上报设备信息
    [instance inputDeviceInfo];
    
    // 内部设置崩溃报告
    [instance setupCrashReporting];
    
    // 设置页面追踪
    [instance setupPageTracking];
    
    // 设置点击追踪
    [instance setupClickTracking];
    
    // 设置启动监控
    [instance setupLaunchTracking];
    
    // 设置初始化状态
    instance.isInitialized = YES;
    
    // 发送初始化成功通知
    [LionmoboDataNotificationManager postInitializeSuccessNotificationWithConfig:config];
    
    // 上传待上传的崩溃报告
    [instance uploadPendingCrashReportsIfNeeded];
    
    LMBLogSuccess(@"LionmoboData SDK 初始化成功！");
    
}

+ (void)setDeviceWithIdfa:(NSString *)idfa
{
    [[self sharedInstance] inputDeviceInfo];
}

+ (void)setUserID:(NSString *)userID
{
    [LionmoboKeyChainTool save:@"lionmobo_userID" data:userID];
    [[self sharedInstance] inputDeviceInfo];
}

+ (void)customEventName:(NSString *)eventName detail:(nullable NSDictionary *)detail
{
    NSMutableDictionary *customDicInfo = [NSMutableDictionary dictionaryWithDictionary:detail];
    [customDicInfo setValue:[LionmoboDataTools detail].user_id forKey:@"user_id"];
    NSArray *items = @[customDicInfo];
    NSDictionary *paramets = @{@"details":items};
    [[LionmoboDataNetworkManager sharedManager] requestWithURL:@"/api/sdkPutEvents" method:LionmoboHTTPMethodPOST parameters:paramets headers:nil success:^(NSData * _Nullable data, NSDictionary * _Nullable responseObject) {
        
        } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
            
        }];
}

+ (nullable LionmoboDataConfig *)currentConfig {
    return _currentConfig;
}

+ (BOOL)isInitialized {
    return [self sharedInstance].isInitialized;
}

+ (NSString *)sdkVersion {
    return LionmoboSDKVersion;
}

#pragma mark - 私有方法

- (void)setupCrashReporting {
    if (self.config.crashReportingEnabled) {
        LionmoboDataCrashManager *crashManager = [LionmoboDataCrashManager sharedManager];
        crashManager.enabled = _currentConfig.debugMode;
        [crashManager startCrashMonitoring];
        
        LMBLogSuccess(@"崩溃报告监控已启用");
    }
}

- (void)setupPageTracking {
    if (self.config.pageTrackingEnabled) {
        LionmoboDataPageTracker *pageTracker = [LionmoboDataPageTracker sharedTracker];
        pageTracker.enabled = YES;
        pageTracker.pathTrackingMode = (LionmoboDataPagePathTrackingMode)self.config.pagePathTrackingMode;
        [pageTracker startTracking];
        
        NSString *modeString = (self.config.pagePathTrackingMode == 0) ? @"完整历史模式" : @"导航栈模式";

        LMBLogSuccess(@"页面追踪已启用，路径追踪模式: %@", modeString);
    }
}

- (void)setupClickTracking {
    if (self.config.clickTrackingEnabled) {
        LionmoboDataClickTracker *clickTracker = [LionmoboDataClickTracker sharedTracker];
        clickTracker.enabled = YES;
        [clickTracker startTracking];
        
        LMBLogSuccess(@"点击追踪已启用");
    }
}

- (void)setupLaunchTracking {
    if (self.config.launchTrackingEnabled) {
        LionmoboDataAppLaunchTracker *launchTracker = [LionmoboDataAppLaunchTracker sharedTracker];
        launchTracker.hotStartTimeoutInterval = self.config.hotStartTimeoutInterval;
        [launchTracker startTracking];
        
        LMBLogSuccess(@"启动监控已启用，热启动超时: %.0f秒", self.config.hotStartTimeoutInterval);
    }
}

- (void)uploadPendingCrashReportsIfNeeded {
    // 当有未上传的崩溃报告时进行上传
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSArray *pendingReports = [[LionmoboDataCrashManager sharedManager] getPendingCrashReports];
        if (pendingReports.count > 0) {
            
            LMBLogWarning(@"发现 %ld 个待上传的崩溃报告，开始上传...", (long)pendingReports.count);
            [[LionmoboDataCrashManager sharedManager] uploadAllPendingCrashReportsWithCompletion:^(NSInteger successCount, NSInteger failureCount, NSArray<NSError *> *errors) {
                if (successCount > 0) {
                    LMBLogSuccess(@"成功上传 %ld 个崩溃报告", (long)successCount);
                }
                if (failureCount > 0) {
                    LMBLogWarning(@"上传 %ld 个崩溃报告失败，下次启动重新上传", (long)failureCount);
                }
            }];
        }
    });
}


- (void) setNetworkLogManager
{
    [LionmoboDataNetworkManager setLogEnabled:self.config.debugMode];
}


- (void) inputDeviceInfo
{
    NSDictionary *paramets = @{@"detail":[[LionmoboDataTools detail] toDictionary]};
    [[LionmoboDataNetworkManager sharedManager] requestWithURL:@"/api/sdkPutDevice" method:LionmoboHTTPMethodPOST parameters:paramets headers:nil success:^(NSData * _Nullable data, NSDictionary * _Nullable responseObject) {
        
        } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
                
        }];
}
@end

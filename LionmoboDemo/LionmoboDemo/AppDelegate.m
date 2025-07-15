//
//  AppDelegate.m
//  LionmoboDemo
//
//  Created by lionmobo on 2025/7/7.
//

#import "AppDelegate.h"
#import <LionmoboData/LionmoboData.h>

@interface AppDelegate ()

@property (nonatomic, assign) NSTimeInterval appLaunchTime;
@property (nonatomic, assign) NSTimeInterval backgroundTime;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 记录应用启动时间
    self.appLaunchTime = [[NSDate date] timeIntervalSince1970];
    
    NSLog(@"🚀 [应用启动] 应用开始启动，时间戳: %.3f", self.appLaunchTime);
    
    // 分析启动选项
    [self analyzeAppLaunchOptions:launchOptions];
    
    // 初始化 LionmoboData SDK
    [self initializeLionmoboDataSDK];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSTimeInterval activeTime = [[NSDate date] timeIntervalSince1970];
    NSLog(@"🔥 [应用生命周期] 应用变为活跃状态，时间戳: %.3f", activeTime);
    
    // 计算启动完成时间（仅在首次启动时）
    if (self.appLaunchTime > 0) {
        NSTimeInterval launchDuration = activeTime - self.appLaunchTime;
        NSLog(@"🚀 [应用启动] 应用启动完成，耗时: %.3f秒", launchDuration);
        
        // 发送应用启动完成事件
        [self sendAppLaunchCompletedEventWithDuration:launchDuration];
        
        // 重置启动时间，避免重复计算
        self.appLaunchTime = 0;
    }
    
    // 计算后台停留时间（从后台返回时）
    if (self.backgroundTime > 0) {
        NSTimeInterval backgroundDuration = activeTime - self.backgroundTime;
        NSLog(@"📱 [应用生命周期] 从后台返回，后台停留时间: %.3f秒", backgroundDuration);
        
        // 发送应用恢复事件
        [self sendAppResumeEventWithBackgroundDuration:backgroundDuration];
        
        // 重置后台时间
        self.backgroundTime = 0;
    }
    
    // 发送应用变为活跃事件
    [self sendAppBecomeActiveEvent];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSTimeInterval resignTime = [[NSDate date] timeIntervalSince1970];
    NSLog(@"⏸️ [应用生命周期] 应用即将失去活跃状态，时间戳: %.3f", resignTime);
    
    // 发送应用失去活跃状态事件
    [self sendAppWillResignActiveEvent];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    self.backgroundTime = [[NSDate date] timeIntervalSince1970];
    NSLog(@"🔙 [应用生命周期] 应用进入后台，时间戳: %.3f", self.backgroundTime);
    
    // 发送应用进入后台事件
    [self sendAppEnterBackgroundEvent];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSTimeInterval foregroundTime = [[NSDate date] timeIntervalSince1970];
    NSLog(@"📱 [应用生命周期] 应用即将进入前台，时间戳: %.3f", foregroundTime);
    
    // 发送应用即将进入前台事件
    [self sendAppWillEnterForegroundEvent];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSTimeInterval terminateTime = [[NSDate date] timeIntervalSince1970];
    NSLog(@"❌ [应用生命周期] 应用即将终止，时间戳: %.3f", terminateTime);
    
    // 发送应用终止事件
    [self sendAppWillTerminateEvent];
    
    // 清理资源
    [self cleanup];
}

#pragma mark - 启动选项分析

- (void)analyzeAppLaunchOptions:(NSDictionary *)launchOptions {
    if (!launchOptions || launchOptions.count == 0) {
        NSLog(@"🚀 [应用启动] 正常启动（用户点击图标）");
        return;
    }
    
    NSLog(@"🚀 [应用启动] 特殊启动，选项: %@", launchOptions);
    
    // 分析各种启动原因
    if (launchOptions[UIApplicationLaunchOptionsURLKey]) {
        NSURL *url = launchOptions[UIApplicationLaunchOptionsURLKey];
        NSLog(@"🔗 [应用启动] URL 启动: %@", url.absoluteString);
    }
    
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        NSDictionary *notification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        NSLog(@"📢 [应用启动] 推送通知启动: %@", notification);
    }
    
    if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]) {
        UILocalNotification *notification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
        NSLog(@"📱 [应用启动] 本地通知启动: %@", notification.alertBody);
    }
}

#pragma mark - LionmoboData SDK初始化

- (void)initializeLionmoboDataSDK {
    NSLog(@"🔧 [SDK 初始化] 开始初始化 LionmoboData SDK");
    
    // 创建SDK配置
    LionmoboDataConfig *config = [[LionmoboDataConfig alloc] init];
    config.appID = @"demo_app_001";
    config.serverURL = @"https://api.lionmobo.com";
    config.apiKey = @"demo_api_key_123";
    config.apiSecret = @"demo_api_secret_456";
    
    // 演示环境配置
    config.debugMode = YES; // 开启调试模式，显示详细日志
    config.timeoutInterval = 30.0;
    
    // 功能开关配置
    config.pageTrackingEnabled = YES; // 启用页面追踪
    config.clickTrackingEnabled = YES; // 启用点击追踪
    config.launchTrackingEnabled = YES; // 启用启动监控
    config.crashReportingEnabled = YES; // 启用崩溃报告
    config.networkLoggingEnabled = YES; // 启用网络日志
    
    // 高级配置
    config.pagePathTrackingMode = 0; // 完整历史模式
    config.hotStartTimeoutInterval = 30.0; // 热启动超时时间
    
    // 注册SDK通知监听
    [self registerSDKNotifications];
    
    // 启动SDK
    [LionmoboData startWithConfig:config];
    
    NSLog(@"🔧 [SDK 初始化] SDK初始化请求已发送");
}

#pragma mark - SDK通知管理

- (void)registerSDKNotifications {
    NSLog(@"🔔 [通知管理] 注册 SDK 通知监听");
    
    // 注册初始化成功通知
    [LionmoboDataNotificationManager addObserver:self
                                         selector:@selector(onSDKInitializeSuccess:)
                                             name:LionmoboDataDidInitializeNotification];
    
    // 注册初始化失败通知
    [LionmoboDataNotificationManager addObserver:self
                                         selector:@selector(onSDKInitializeFailure:)
                                             name:LionmoboDataDidFailToInitializeNotification];
    
    // 注册配置变更通知
    [LionmoboDataNotificationManager addObserver:self
                                         selector:@selector(onSDKConfigChanged:)
                                             name:LionmoboDataConfigDidChangeNotification];
    
    // 注册崩溃监控通知
    [LionmoboDataNotificationManager addObserver:self
                                         selector:@selector(onCrashMonitoringStarted:)
                                             name:LionmoboDataCrashMonitoringStartedNotification];
}

#pragma mark - SDK通知响应

- (void)onSDKInitializeSuccess:(NSNotification *)notification {
    NSLog(@"✅ [SDK 通知] 收到SDK初始化成功通知");
    
    // 从通知中获取信息
    LionmoboDataConfig *config = notification.userInfo[LionmoboDataNotificationConfigKey];
    NSNumber *timestamp = notification.userInfo[LionmoboDataNotificationTimestampKey];
    
    NSLog(@"🎉 [SDK 初始化] SDK初始化成功！");
    NSLog(@"⏰ [SDK 初始化] 初始化时间戳: %.3f", timestamp.doubleValue);
    NSLog(@"⚙️ [SDK 初始化] 当前配置 - App ID: %@", config.appID);
    NSLog(@"⚙️ [SDK 初始化] 当前配置 - 服务器地址: %@", config.serverURL);
    NSLog(@"⚙️ [SDK 初始化] 当前配置 - 调试模式: %@", config.debugMode ? @"开启" : @"关闭");
    
    // 验证初始化状态
    if ([LionmoboData isInitialized]) {
        NSLog(@"✅ [SDK 状态] SDK状态验证: 已成功初始化");
        NSString *version = [LionmoboData sdkVersion];
        NSLog(@"📱 [SDK 信息] SDK版本: %@", version);
        
        // 发送 SDK 初始化成功事件
        [self sendSDKInitializedEvent];
    } else {
        NSLog(@"❌ [SDK 状态] SDK状态验证: 初始化失败");
    }
}

- (void)onSDKInitializeFailure:(NSNotification *)notification {
    NSLog(@"❌ [SDK 通知] 收到SDK初始化失败通知");
    
    NSError *error = notification.userInfo[LionmoboDataNotificationErrorKey];
    NSNumber *timestamp = notification.userInfo[LionmoboDataNotificationTimestampKey];
    
    NSLog(@"💥 [SDK 初始化] SDK初始化失败！");
    NSLog(@"⏰ [SDK 初始化] 失败时间戳: %.3f", timestamp.doubleValue);
    NSLog(@"📝 [SDK 初始化] 错误信息: %@", error.localizedDescription);
    NSLog(@"🔍 [SDK 初始化] 失败原因: %@", error.localizedFailureReason ?: @"未知原因");
    NSLog(@"🔢 [SDK 初始化] 错误代码: %ld", (long)error.code);
}

- (void)onSDKConfigChanged:(NSNotification *)notification {
    NSLog(@"⚙️ [SDK 通知] 收到SDK配置变更通知");
    
    LionmoboDataConfig *config = notification.userInfo[LionmoboDataNotificationConfigKey];
    NSLog(@"🔄 [配置变更] 新配置 - App ID: %@", config.appID);
    NSLog(@"🔄 [配置变更] 新配置 - 调试模式: %@", config.debugMode ? @"开启" : @"关闭");
}

- (void)onCrashMonitoringStarted:(NSNotification *)notification {
    NSLog(@"🛡️ [SDK 通知] 崩溃监控已启动");
}

#pragma mark - 应用生命周期事件发送

- (void)sendAppLaunchCompletedEventWithDuration:(NSTimeInterval)duration {
    if (![LionmoboData isInitialized]) {
        return;
    }
    
    [LionmoboData customEventName:@"app_launch_completed" detail:@{
        @"launch_duration": @(duration),
        @"launch_time": @(self.appLaunchTime),
        @"completion_time": @([[NSDate date] timeIntervalSince1970]),
        @"app_version": [self getAppVersion],
        @"system_version": [[UIDevice currentDevice] systemVersion],
        @"device_model": [[UIDevice currentDevice] model]
    }];
    
    NSLog(@"📊 [事件发送] 应用启动完成事件已发送，耗时: %.3f秒", duration);
}

- (void)sendAppBecomeActiveEvent {
    if (![LionmoboData isInitialized]) {
        return;
    }
    
    [LionmoboData customEventName:@"app_become_active" detail:@{
        @"timestamp": @([[NSDate date] timeIntervalSince1970]),
        @"app_version": [self getAppVersion]
    }];
    
    NSLog(@"📊 [事件发送] 应用变为活跃事件已发送");
}

- (void)sendAppWillResignActiveEvent {
    if (![LionmoboData isInitialized]) {
        return;
    }
    
    [LionmoboData customEventName:@"app_will_resign_active" detail:@{
        @"timestamp": @([[NSDate date] timeIntervalSince1970]),
        @"app_version": [self getAppVersion]
    }];
    
    NSLog(@"📊 [事件发送] 应用失去活跃状态事件已发送");
}

- (void)sendAppEnterBackgroundEvent {
    if (![LionmoboData isInitialized]) {
        return;
    }
    
    [LionmoboData customEventName:@"app_enter_background" detail:@{
        @"timestamp": @(self.backgroundTime),
        @"app_version": [self getAppVersion]
    }];
    
    NSLog(@"📊 [事件发送] 应用进入后台事件已发送");
}

- (void)sendAppWillEnterForegroundEvent {
    if (![LionmoboData isInitialized]) {
        return;
    }
    
    [LionmoboData customEventName:@"app_will_enter_foreground" detail:@{
        @"timestamp": @([[NSDate date] timeIntervalSince1970]),
        @"app_version": [self getAppVersion]
    }];
    
    NSLog(@"📊 [事件发送] 应用即将进入前台事件已发送");
}

- (void)sendAppResumeEventWithBackgroundDuration:(NSTimeInterval)duration {
    if (![LionmoboData isInitialized]) {
        return;
    }
    
    [LionmoboData customEventName:@"app_resume_from_background" detail:@{
        @"background_duration": @(duration),
        @"background_start_time": @(self.backgroundTime),
        @"resume_time": @([[NSDate date] timeIntervalSince1970]),
        @"app_version": [self getAppVersion]
    }];
    
    NSLog(@"📊 [事件发送] 应用从后台恢复事件已发送，后台时长: %.3f秒", duration);
}

- (void)sendAppWillTerminateEvent {
    if (![LionmoboData isInitialized]) {
        return;
    }
    
    [LionmoboData customEventName:@"app_will_terminate" detail:@{
        @"timestamp": @([[NSDate date] timeIntervalSince1970]),
        @"app_version": [self getAppVersion]
    }];
    
    NSLog(@"📊 [事件发送] 应用终止事件已发送");
}

- (void)sendSDKInitializedEvent {
    [LionmoboData customEventName:@"sdk_initialized" detail:@{
        @"sdk_version": [LionmoboData sdkVersion],
        @"app_version": [self getAppVersion],
        @"initialization_time": @([[NSDate date] timeIntervalSince1970]),
        @"device_info": @{
            @"model": [[UIDevice currentDevice] model],
            @"system_version": [[UIDevice currentDevice] systemVersion],
            @"device_id": [[[UIDevice currentDevice] identifierForVendor] UUIDString]
        }
    }];
    
    NSLog(@"📊 [事件发送] SDK初始化事件已发送");
}

#pragma mark - 辅助方法

- (NSString *)getAppVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: @"Unknown";
}

- (void)cleanup {
    NSLog(@"🧹 [清理] 开始清理应用资源");
    
    // 移除所有通知监听
    [LionmoboDataNotificationManager removeObserver:self name:nil];
    
    NSLog(@"🧹 [清理] 已移除所有通知监听");
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    NSLog(@"🖥️ [Scene] 创建新的 Scene 会话");
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    NSLog(@"🖥️ [Scene] 丢弃 Scene 会话，数量: %lu", (unsigned long)sceneSessions.count);
}

- (void)dealloc {
    [self cleanup];
}

@end

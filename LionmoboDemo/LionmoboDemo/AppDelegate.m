//
//  AppDelegate.m
//  LionmoboDemo
//
//  Created by lionmobo on 2025/7/7.
//

#import "AppDelegate.h"
#import <LionmoboData/LionmoboData.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 初始化 LionmoboData SDK
    [self initializeLionmoboDataSDK];
    
    return YES;
}

#pragma mark - LionmoboData SDK初始化

- (void)initializeLionmoboDataSDK {
    // 创建SDK配置
    LionmoboDataConfig *config = [[LionmoboDataConfig alloc] init];
    config.appID = @"10002";
//    config.serverURL = @"http://biapi.ssp.lionmobo.com";  //生产环境
    config.serverURL = @"http://sz.lionmobo.net:8070";   //测试环境
    config.apiKey = @"UO7t2XFozGrWdzYG"; //  API签名秘钥
//    config.apiSecret = @"LKmJjcxonZA22dzA"; // 生产环境
    config.apiSecret = @"LKmJjcxonZA22dzAJKS"; // 测试环境
    config.debugMode = YES; // 演示应用开启调试模式，自动启用所有日志输出和崩溃报告
    config.timeoutInterval = 30.0;
    // 页面追踪配置
    config.pageTrackingEnabled = YES;
    // 默认使用完整历史模式
    config.pagePathTrackingMode = 0;
    // 启用崩溃追踪
    config.crashReportingEnabled = YES;
    // 点击追踪配置
    config.clickTrackingEnabled = YES;
    // 启动监控配置
//    config.launchTrackingEnabled = YES;
//    config.hotStartTimeoutInterval = 30.0; // 30秒热启动超时
    // 注册SDK通知监听
    [self registerSDKNotifications];
    
    // 启动SDK
    [LionmoboData startWithConfig:config];
    
    NSLog(@"[LionmoboData] AppDelegate - SDK初始化请求已发送");
}

#pragma mark - SDK通知管理

- (void)registerSDKNotifications {
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
}

- (void)onSDKInitializeSuccess:(NSNotification *)notification {
    NSLog(@"[LionmoboData] AppDelegate - 收到SDK初始化成功通知");
    
    // 从通知中获取配置信息
    LionmoboDataConfig *config = notification.userInfo[LionmoboDataNotificationConfigKey];
    NSNumber *timestamp = notification.userInfo[LionmoboDataNotificationTimestampKey];
    
    NSLog(@"[LionmoboData] AppDelegate - SDK初始化成功！");
    NSLog(@"[LionmoboData] AppDelegate - 初始化时间戳: %.0f", timestamp.doubleValue);
    NSLog(@"[LionmoboData] AppDelegate - 当前配置: %@", config);
    
    // 验证初始化状态
    if ([LionmoboData isInitialized]) {
        NSLog(@"[LionmoboData] AppDelegate - SDK状态验证: 已初始化");
    }
}

- (void)onSDKInitializeFailure:(NSNotification *)notification {
    NSLog(@"[LionmoboData] AppDelegate - 收到SDK初始化失败通知");
    
    NSError *error = notification.userInfo[LionmoboDataNotificationErrorKey];
    NSNumber *timestamp = notification.userInfo[LionmoboDataNotificationTimestampKey];
    
    NSLog(@"[LionmoboData] AppDelegate - SDK初始化失败！");
    NSLog(@"[LionmoboData] AppDelegate - 失败时间戳: %.0f", timestamp.doubleValue);
    NSLog(@"[LionmoboData] AppDelegate - 错误信息: %@", error.localizedDescription);
    NSLog(@"[LionmoboData] AppDelegate - 失败原因: %@", error.localizedFailureReason);
}

- (void)onSDKConfigChanged:(NSNotification *)notification {
    NSLog(@"[LionmoboData] AppDelegate - 收到SDK配置变更通知");
    
    LionmoboDataConfig *config = notification.userInfo[LionmoboDataNotificationConfigKey];
    NSLog(@"[LionmoboData] AppDelegate - 新配置: %@", config);
}

- (void)dealloc {
    // 移除所有通知监听
    [LionmoboDataNotificationManager removeObserver:self name:nil];
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end

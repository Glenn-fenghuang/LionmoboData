# LionmoboData SDK 使用文档

## 目录
1. [概述](#概述)
2. [系统要求](#系统要求)
3. [安装与集成](#安装与集成)
4. [快速开始](#快速开始)
5. [SDK配置](#sdk配置)
6. [核心功能](#核心功能)
7. [高级功能](#高级功能)
8. [通知系统](#通知系统)
9. [API参考](#api参考)
10. [最佳实践](#最佳实践)
11. [FAQ](#faq)

## 概述

LionmoboData SDK 是一个功能强大的 iOS 数据分析 SDK，专门用于收集应用内用户行为数据，包括页面访问、点击事件、应用启动、崩溃报告等。SDK 设计轻量化，易于集成，提供了丰富的数据追踪能力。

### 主要功能
- **用户行为追踪**: 自动追踪页面访问、点击事件
- **应用启动监控**: 监控冷启动/热启动性能
- **崩溃报告**: 自动收集和上报应用崩溃信息
- **自定义事件**: 支持自定义业务事件上报
- **日志系统**: 完善的分级日志输出
- **通知系统**: 实时的 SDK 状态通知

## 系统要求

- iOS 9.0 及以上版本
- Xcode 11.0 及以上版本
- 支持 Objective-C 和 Swift 项目

## 安装与集成

### 方式一：使用 CocoaPods（推荐）

1. 在 `Podfile` 中添加依赖：
```ruby
pod 'LionmoboData', :path => '你的SDK路径'
```

2. 执行安装命令：
```bash
pod install
```

### 方式二：手动集成

1. 将生成的 `LionmoboData.xcframework` 拖入项目
2. 在 Build Settings 中添加依赖框架：
   - Foundation.framework
   - UIKit.framework

### 方式三：直接添加源码

1. 将 `LionmoboData` 文件夹添加到项目中

## 快速开始

### 1. 导入头文件

**Objective-C:**
```objc
#import <LionmoboData/LionmoboData.h>
```

**Swift:**
```swift
import LionmoboData
```

### 2. 基础初始化

在 `AppDelegate.m` 的 `application:didFinishLaunchingWithOptions:` 方法中初始化 SDK：

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 创建配置对象
    LionmoboDataConfig *config = [[LionmoboDataConfig alloc] init];
    config.appID = @"你的应用ID（大数据平台分配）";
    config.serverURL = @"你的服务器地址";
    config.apiKey = @"你的API密钥（登录大数据平台，个人资料中获取）";
    config.apiSecret = @"你的apiSecret密钥（登录大数据平台，个人资料中获取）";
    config.debugMode = YES; // 开发阶段建议开启
    
    // 启动SDK
    [LionmoboData startWithConfig:config];
    
    return YES;
}
```

### 3. 设置用户信息

```objc
// 设置用户ID
[LionmoboData setUserID:@"user123"];

// 设置IDFA（需要用户授权后）
[LionmoboData setDeviceWithIdfa:@"IDFA字符串"];
```

### 4. 上报自定义事件

```objc
// 简单事件
[LionmoboData customEventName:@"button_click" detail:nil];

// 带参数事件
NSDictionary *detail = @{
    @"button_name": @"购买按钮",
    @"page": @"商品详情页",
    @"product_id": @"12345"
};
[LionmoboData customEventName:@"purchase_click" detail:detail];
```

## SDK配置

`LionmoboDataConfig` 类提供了丰富的配置选项：

### 必须配置项
```objc
config.appID = @"应用唯一标识";          // 必须
config.serverURL = @"数据上报服务器地址";  // 必须
config.apiKey = @"API签名密钥";         // 必须
config.apiSecret = @"API签名密钥";      // 必须
```

### 可选配置项
```objc
// 基础配置
config.debugMode = YES;                    // 调试模式，默认 NO
config.timeoutInterval = 30.0;             // 网络超时时间，默认 30 秒

// 功能开关
config.pageTrackingEnabled = YES;         // 页面追踪，默认 NO
config.clickTrackingEnabled = YES;        // 点击追踪，默认 NO
config.crashReportingEnabled = YES;       // 崩溃报告，默认 NO
config.launchTrackingEnabled = YES;       // 启动监控，默认 YES
config.networkLoggingEnabled = YES;       // 网络日志，默认 NO

// 高级配置
config.pagePathTrackingMode = 0;          // 页面路径追踪模式：0-完整历史，1-导航栈
config.hotStartTimeoutInterval = 30.0;    // 热启动判断超时时间，默认 30 秒
```

## 核心功能

### 1. 页面追踪

SDK 自动追踪 UIViewController 的生命周期：

```objc
// 启用页面追踪
config.pageTrackingEnabled = YES;

// 获取页面追踪器
LionmoboDataPageTracker *pageTracker = [LionmoboDataPageTracker sharedTracker];

// 手动追踪（通常不需要，SDK自动处理）
[pageTracker trackPageEnter:@"HomePage" pageTitle:@"首页"];
[pageTracker trackPageExit:@"HomePage"];
```

**追踪的数据包括：**
- 页面名称（类名）
- 页面标题
- 进入/退出时间
- 停留时长
- 页面路径（用户访问路径）

### 2. 点击追踪

自动捕获用户点击行为：

```objc
// 启用点击追踪
config.clickTrackingEnabled = YES;

// 获取点击追踪器
LionmoboDataClickTracker *clickTracker = [LionmoboDataClickTracker sharedTracker];

// 手动追踪点击（通常不需要）
[clickTracker trackClickOnElement:button pageName:@"HomePage"];
```

**追踪的数据包括：**
- 被点击元素的类型
- 元素内容（按钮文字等）
- 元素位置坐标
- 当前页面信息
- 点击时间戳

### 3. 应用启动监控

监控应用启动性能：

```objc
// 启用启动监控
config.launchTrackingEnabled = YES;
config.hotStartTimeoutInterval = 30.0; // 热启动判断时间

// 获取启动追踪器
LionmoboDataAppLaunchTracker *launchTracker = [LionmoboDataAppLaunchTracker sharedTracker];
```

**监控的数据包括：**
- 启动类型（冷启动/热启动）

### 4. 崩溃报告

自动收集应用崩溃信息：

```objc
// 启用崩溃报告
config.crashReportingEnabled = YES;

// 获取崩溃管理器
LionmoboDataCrashManager *crashManager = [LionmoboDataCrashManager sharedManager];

// 获取崩溃报告列表
NSArray *crashReports = [crashManager getAllCrashReports];

// 上传待上传的崩溃报告
[crashManager uploadAllPendingCrashReportsWithCompletion:^(NSInteger successCount, NSInteger failureCount, NSArray<NSError *> *errors) {
    NSLog(@"上传完成: 成功 %ld, 失败 %ld", successCount, failureCount);
}];
```

### 5. 日志系统

SDK 提供了完善的日志系统：

```objc
// 开启日志
[LionmoboDataLogger setLogEnabled:YES];

// 不同级别的日志
[LionmoboDataLogger logInfo:@"信息日志"];
[LionmoboDataLogger logSuccessInfo:@"成功日志"];
[LionmoboDataLogger logWarning:@"警告日志"];
[LionmoboDataLogger logError:@"错误日志"];
[LionmoboDataLogger logDebug:@"调试日志"];

// 使用便捷宏
LMBLog(@"普通日志");
LMBLogSuccess(@"成功日志");
LMBLogWarning(@"警告日志");
LMBLogError(@"错误日志");
LMBLogDebug(@"调试日志");
```

## 高级功能

### 1. SDK 状态检查

```objc
// 检查初始化状态
BOOL isInitialized = [LionmoboData isInitialized];

// 获取当前配置
LionmoboDataConfig *currentConfig = [LionmoboData currentConfig];

// 获取SDK版本
NSString *version = [LionmoboData sdkVersion];

// 获取单例对象
LionmoboDataCore *instance = [LionmoboData sharedInstance];
```

### 2. 自定义事件上报

```objc
// 业务事件示例
[LionmoboData customEventName:@"user_register" detail:@{
    @"register_type": @"mobile",
    @"channel": @"app_store",
    @"version": @"1.0.0"
}];

[LionmoboData customEventName:@"product_view" detail:@{
    @"product_id": @"12345",
    @"category": @"狮乐购牛脆片",
    @"price": @"999.00"
}];

[LionmoboData customEventName:@"order_complete" detail:@{
    @"order_id": @"ORD202507141102393021293",
    @"amount": @"29.00",
    @"payment_method": @"支付宝"
}];
```

### 3. 页面路径追踪模式

```objc
// 完整历史模式（默认）- 记录用户完整的页面访问历史
config.pagePathTrackingMode = LionmoboDataPagePathTrackingModeHistory;

// 导航栈模式 - 基于导航栈维护当前路径
config.pagePathTrackingMode = LionmoboDataPagePathTrackingModeStack;
```

## 通知系统

SDK 提供了丰富的通知机制，方便监听 SDK 状态：

### 1. 注册通知监听

```objc
// 注册初始化成功通知
[LionmoboDataNotificationManager addObserver:self
                                     selector:@selector(onSDKInitSuccess:)
                                         name:LionmoboDataDidInitializeNotification];

// 注册初始化失败通知
[LionmoboDataNotificationManager addObserver:self
                                     selector:@selector(onSDKInitFailure:)
                                         name:LionmoboDataDidFailToInitializeNotification];

// 注册配置变更通知
[LionmoboDataNotificationManager addObserver:self
                                     selector:@selector(onConfigChanged:)
                                         name:LionmoboDataConfigDidChangeNotification];
```

### 2. 处理通知

```objc
- (void)onSDKInitSuccess:(NSNotification *)notification {
    LionmoboDataConfig *config = notification.userInfo[LionmoboDataNotificationConfigKey];
    NSNumber *timestamp = notification.userInfo[LionmoboDataNotificationTimestampKey];
    NSLog(@"SDK初始化成功: %@", config);
}

- (void)onSDKInitFailure:(NSNotification *)notification {
    NSError *error = notification.userInfo[LionmoboDataNotificationErrorKey];
    NSLog(@"SDK初始化失败: %@", error.localizedDescription);
}

- (void)onConfigChanged:(NSNotification *)notification {
    LionmoboDataConfig *newConfig = notification.userInfo[LionmoboDataNotificationConfigKey];
    NSLog(@"配置已更新: %@", newConfig);
}
```

### 3. 移除通知监听

```objc
// 移除特定通知
[LionmoboDataNotificationManager removeObserver:self 
                                            name:LionmoboDataDidInitializeNotification];

// 移除所有通知
[LionmoboDataNotificationManager removeObserver:self name:nil];
```

### 4. 可用的通知类型

```objc
// SDK 初始化相关
LionmoboDataDidInitializeNotification           // 初始化成功
LionmoboDataDidFailToInitializeNotification     // 初始化失败
LionmoboDataConfigDidChangeNotification         // 配置变更

// 崩溃监控相关
LionmoboDataCrashMonitoringStartedNotification  // 崩溃监控开始
LionmoboDataCrashMonitoringStoppedNotification  // 崩溃监控停止
LionmoboDataCrashReportSavedNotification        // 崩溃报告保存
LionmoboDataCrashReportUploadedNotification     // 崩溃报告上传
LionmoboDataCrashReportDeletedNotification      // 崩溃报告删除
LionmoboDataAllCrashReportsUploadCompletedNotification  // 所有报告上传完成
LionmoboDataAllCrashReportsClearedNotification  // 所有报告清除
```

## API参考

### LionmoboDataCore

核心类提供 SDK 的主要功能：

```objc
// 初始化
+ (void)startWithConfig:(LionmoboDataConfig *)config;

// 用户信息设置
+ (void)setUserID:(NSString *)userID;
+ (void)setDeviceWithIdfa:(NSString *)idfa;

// 自定义事件
+ (void)customEventName:(NSString *)eventName detail:(nullable NSDictionary *)detail;

// 状态查询
+ (BOOL)isInitialized;
+ (nullable LionmoboDataConfig *)currentConfig;
+ (NSString *)sdkVersion;
+ (instancetype)sharedInstance;
```

### LionmoboDataConfig

配置类提供所有配置选项：

```objc
// 必需属性
@property (nonatomic, copy) NSString *appID;
@property (nonatomic, copy) NSString *serverURL;
@property (nonatomic, copy) NSString *apiKey;
@property (nonatomic, copy) NSString *apiSecret;

// 基础配置
@property (nonatomic, assign) BOOL debugMode;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

// 功能开关
@property (nonatomic, assign) BOOL pageTrackingEnabled;
@property (nonatomic, assign) BOOL clickTrackingEnabled;
@property (nonatomic, assign) BOOL crashReportingEnabled;
@property (nonatomic, assign) BOOL launchTrackingEnabled;
@property (nonatomic, assign) BOOL networkLoggingEnabled;

// 高级配置
@property (nonatomic, assign) NSInteger pagePathTrackingMode;
@property (nonatomic, assign) NSTimeInterval hotStartTimeoutInterval;
```

### LionmoboDataLogger

日志系统 API：

```objc
// 日志控制
+ (void)setLogEnabled:(BOOL)enabled;
+ (BOOL)isLogEnabled;

// 日志输出
+ (void)logInfo:(NSString *)format, ...;
+ (void)logSuccessInfo:(NSString *)format, ...;
+ (void)logWarning:(NSString *)format, ...;
+ (void)logError:(NSString *)format, ...;
+ (void)logDebug:(NSString *)format, ...;
```

## 最佳实践

### 1. 初始化时机

```objc
// ✅ 推荐：在 AppDelegate 中尽早初始化
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initializeLionmoboSDK];  // 尽早初始化
    return YES;
}

// ❌ 不推荐：延迟初始化
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [self initializeLionmoboSDK];  // 可能丢失启动数据
});
```

### 2. 配置管理

```objc
// ✅ 推荐：根据环境使用不同配置
- (void)initializeLionmoboSDK {
    LionmoboDataConfig *config = [[LionmoboDataConfig alloc] init];
    
#ifdef DEBUG
    config.serverURL = @"http://test-server.com";
    config.debugMode = YES;
#else
    config.serverURL = @"https://prod-server.com";
    config.debugMode = NO;
#endif
    
    [LionmoboData startWithConfig:config];
}
```

### 3. 错误处理

```objc
// ✅ 推荐：注册通知监听初始化结果
[LionmoboDataNotificationManager addObserver:self
                                     selector:@selector(onSDKInitFailure:)
                                         name:LionmoboDataDidFailToInitializeNotification];

- (void)onSDKInitFailure:(NSNotification *)notification {
    NSError *error = notification.userInfo[LionmoboDataNotificationErrorKey];
    // 记录错误日志或进行错误处理
    NSLog(@"SDK初始化失败: %@", error);
}
```

### 4. 性能优化

```objc
// ✅ 推荐：合理配置功能开关
config.pageTrackingEnabled = YES;    // 根据需要开启
config.clickTrackingEnabled = YES;   // 通常建议开启
config.crashReportingEnabled = YES;  // 生产环境建议开启
config.launchTrackingEnabled = NO;   // 性能要求高时可关闭

// ✅ 推荐：合理设置超时时间
config.timeoutInterval = 30.0;  // 网络环境差时可适当增加
```

### 5. 自定义事件规范

```objc
// ✅ 推荐：统一的事件命名规范
[LionmoboData customEventName:@"user_action_button_click" detail:@{
    @"button_name": @"购买",
    @"page_name": @"商品详情",
    @"product_id": @"12345"
}];

// ❌ 不推荐：随意命名
[LionmoboData customEventName:@"click" detail:@{@"btn": @"buy"}];
```

### 6. 内存管理

```objc
// ✅ 推荐：及时移除通知监听
- (void)dealloc {
    [LionmoboDataNotificationManager removeObserver:self name:nil];
}

// ✅ 推荐：在合适的时机清理数据
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    // 可以考虑清理旧的崩溃报告
    [[LionmoboDataCrashManager sharedManager] clearAllCrashReports];
}
```

## FAQ

### Q1: SDK 初始化失败怎么办？

**A:** 检查以下几点：
1. 确认 `appID`、`serverURL`、`apiKey`、`apiSecret` 配置正确
2. 检查网络连接是否正常
3. 查看初始化失败通知中的错误信息
4. 开启 `debugMode` 查看详细日志

### Q2: 页面追踪不生效？

**A:** 确认：
1. `config.pageTrackingEnabled = YES` 已设置
2. SDK 已成功初始化
3. 页面是 UIViewController 的子类
4. 检查是否被其他 Method Swizzling 影响

### Q3: 如何减少 SDK 对性能的影响？

**A:** 优化建议：
1. 根据实际需要开启功能开关
2. 合理设置网络超时时间
3. 在 Release 模式下关闭 `debugMode`
4. 定期清理崩溃报告数据

### Q4: 自定义事件什么时候上报？

**A:** SDK 采用批量上报机制：
1. 事件数量达到一定阈值时（最大：30）
2. 定时器触发时
3. 应用进入后台时
4. 应用终止时

### Q5: 崩溃报告如何处理？

**A:** 崩溃报告管理：
1. SDK 自动收集崩溃信息
2. 下次启动时尝试上报
3. 可手动调用上报接口
4. 定期清理过期报告（最大：30）

### Q6: 支持哪些版本的 iOS？

**A:** SDK 支持 iOS 9.0 及以上版本，兼容性良好。

### Q7: 如何在 Swift 项目中使用？

**A:** Swift 项目使用示例：
```swift
import LionmoboData

// 初始化
let config = LionmoboDataConfig()
config.appID = "your_app_id"
config.serverURL = "your_server_url"
config.apiKey = "your_api_key"
config.apiSecret = "your_api_secret"
config.debugMode = true

LionmoboData.start(with: config)

// 设置用户ID
LionmoboData.setUserID("user123")

// 自定义事件
LionmoboData.customEventName("button_click", detail: [
    "button_name": "购买按钮",
    "page": "商品页"
])
```

### Q8: SDK 会收集哪些数据？

**A:** SDK 收集的数据包括：
- 设备基础信息（型号、系统版本等）
- 应用信息（版本、Bundle ID 等）
- 用户行为数据（页面访问、点击事件等）
- 性能数据（启动时间、崩溃信息等）
- 用户设置的自定义数据

所有数据收集都严格遵循隐私政策，不会收集用户隐私信息。

---

## 技术支持

如有问题，请联系技术支持团队或查看项目 GitHub 仓库的 Issues 页面。

**SDK 版本**: 1.0.0  
**文档更新时间**: 2025年7月14日 
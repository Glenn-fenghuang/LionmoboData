//
//  ViewController.m
//  LionmoboDemo
//
//  Created by lionmobo on 2025/7/7.
//

#import "ViewController.h"
#import "SecondViewController.h"
#import <LionmoboData/LionmoboData.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupDemoData];
    [self setupNotifications];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"LionmoboData SDK演示";
    
    // SDK状态标签
    self.sdkStatusLabel = [[UILabel alloc] init];
    self.sdkStatusLabel.frame = CGRectMake(20, 100, self.view.frame.size.width - 40, 30);
    self.sdkStatusLabel.text = @"SDK状态: 未初始化";
    self.sdkStatusLabel.textColor = [UIColor redColor];
    self.sdkStatusLabel.font = [UIFont boldSystemFontOfSize:16];
    self.sdkStatusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.sdkStatusLabel];
    
    // 初始化按钮
    self.customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.customButton.frame = CGRectMake(20, 140, self.view.frame.size.width - 40, 44);
    self.customButton.backgroundColor = [UIColor systemBlueColor];
    [self.customButton setTitle:@"初始化 LionmoboData SDK" forState:UIControlStateNormal];
    [self.customButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.customButton.layer.cornerRadius = 8;
    [self.customButton addTarget:self action:@selector(initializeSDK) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.customButton];
    
    // 表格视图
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, self.view.frame.size.height - 200) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor systemBackgroundColor];
    [self.view addSubview:self.tableView];
}

- (void)setupDemoData {
    self.demoSections = @[
        @{
            @"title": @"👤 用户管理",
            @"items": @[
                @{@"title": @"设置用户ID", @"action": @"setUserID"},
                @{@"title": @"获取设备ID", @"action": @"getDeviceID"},
                @{@"title": @"请求IDFA权限", @"action": @"requestIDFA"},
                @{@"title": @"获取IDFA", @"action": @"getIDFA"}
            ]
        },
        @{
            @"title": @"📊 事件追踪",
            @"items": @[
                @{@"title": @"发送自定义事件", @"action": @"sendCustomEvent"},
                @{@"title": @"商品查看事件", @"action": @"sendProductView"},
                @{@"title": @"购买事件", @"action": @"sendPurchaseEvent"},
                @{@"title": @"页面跟踪演示", @"action": @"showPageTracking"}
            ]
        },
        @{
            @"title": @"📝 日志系统",
            @"items": @[
                @{@"title": @"Debug日志", @"action": @"logDebug"},
                @{@"title": @"Info日志", @"action": @"logInfo"},
                @{@"title": @"Warning日志", @"action": @"logWarning"},
                @{@"title": @"Error日志", @"action": @"logError"}
            ]
        },
        @{
            @"title": @"🔔 通知系统",
            @"items": @[
                @{@"title": @"SDK事件通知", @"action": @"showSDKNotifications"},
                @{@"title": @"数据上传通知", @"action": @"showUploadNotifications"},
                @{@"title": @"错误通知", @"action": @"showErrorNotifications"}
            ]
        },
        @{
            @"title": @"🔧 高级功能",
            @"items": @[
                @{@"title": @"模拟崩溃", @"action": @"simulateCrash"},
                @{@"title": @"网络状态监控", @"action": @"checkNetworkStatus"},
                @{@"title": @"设备信息", @"action": @"showDeviceInfo"},
                @{@"title": @"清除数据", @"action": @"clearData"}
            ]
        }
    ];
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSDKNotification:)
                                                 name:@"LionmoboDataEventSent"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSDKNotification:)
                                                 name:@"LionmoboDataError"
                                               object:nil];
}

#pragma mark - SDK初始化

- (void)initializeSDK {
    NSLog(@"🚀 开始初始化 LionmoboData SDK...");
    
    // 配置SDK
    LionmoboDataConfig *config = [[LionmoboDataConfig alloc] init];
    config.appID = @"10002";
    config.serverURL = @"http://sz.lionmobo.net:8070";
    config.enableAutoPageTracking = YES;
    config.enableAutoClickTracking = YES;
    config.enableCrashReporting = YES;
    config.logLevel = LionmoboDataLogLevelDebug;
    
    // 初始化SDK
    [[LionmoboDataCore sharedInstance] initializeWithConfig:config];
    
    // 更新UI状态
    self.sdkStatusLabel.text = @"SDK状态: 已初始化 ✅";
    self.sdkStatusLabel.textColor = [UIColor systemGreenColor];
    [self.customButton setTitle:@"SDK已初始化 ✅" forState:UIControlStateNormal];
    self.customButton.backgroundColor = [UIColor systemGreenColor];
    self.customButton.enabled = NO;
    
    NSLog(@"✅ LionmoboData SDK 初始化完成！");
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.demoSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *sectionData = self.demoSections[section];
    NSArray *items = sectionData[@"items"];
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"DemoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSDictionary *sectionData = self.demoSections[indexPath.section];
    NSArray *items = sectionData[@"items"];
    NSDictionary *item = items[indexPath.row];
    
    cell.textLabel.text = item[@"title"];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *sectionData = self.demoSections[section];
    return sectionData[@"title"];
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *sectionData = self.demoSections[indexPath.section];
    NSArray *items = sectionData[@"items"];
    NSDictionary *item = items[indexPath.row];
    NSString *action = item[@"action"];
    
    // 执行对应的演示功能
    SEL selector = NSSelectorFromString(action);
    if ([self respondsToSelector:selector]) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:selector];
        #pragma clang diagnostic pop
    }
}

#pragma mark - 用户管理演示

- (void)setUserID {
    NSString *userID = [NSString stringWithFormat:@"user_%ld", (long)[[NSDate date] timeIntervalSince1970]];
    [[LionmoboDataCore sharedInstance] setUserID:userID];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"用户ID设置"
                                                                   message:[NSString stringWithFormat:@"已设置用户ID: %@", userID]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    
    NSLog(@"👤 设置用户ID: %@", userID);
}

- (void)getDeviceID {
    NSString *deviceID = [[LionmoboDataCore sharedInstance] getDeviceID];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设备ID"
                                                                   message:[NSString stringWithFormat:@"设备ID: %@", deviceID]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    
    NSLog(@"📱 设备ID: %@", deviceID);
}

- (void)requestIDFA {
    if (@available(iOS 14.5, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *statusString = @"";
                switch (status) {
                    case ATTrackingManagerAuthorizationStatusAuthorized:
                        statusString = @"已授权";
                        break;
                    case ATTrackingManagerAuthorizationStatusDenied:
                        statusString = @"已拒绝";
                        break;
                    case ATTrackingManagerAuthorizationStatusNotDetermined:
                        statusString = @"未确定";
                        break;
                    case ATTrackingManagerAuthorizationStatusRestricted:
                        statusString = @"受限制";
                        break;
                }
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"IDFA权限请求"
                                                                               message:[NSString stringWithFormat:@"权限状态: %@", statusString]
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
                
                NSLog(@"🔐 IDFA权限状态: %@", statusString);
            });
        }];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"IDFA权限"
                                                                       message:@"iOS 14.5以下版本无需请求IDFA权限"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)getIDFA {
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"IDFA"
                                                                   message:[NSString stringWithFormat:@"IDFA: %@", idfa]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    
    NSLog(@"🆔 IDFA: %@", idfa);
}

#pragma mark - 事件追踪演示

- (void)sendCustomEvent {
    NSDictionary *properties = @{
        @"action": @"button_click",
        @"button_name": @"custom_event_demo",
        @"timestamp": @([[NSDate date] timeIntervalSince1970]),
        @"user_level": @"premium"
    };
    
    [[LionmoboDataCore sharedInstance] trackEvent:@"custom_event" properties:properties];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"自定义事件"
                                                                   message:@"已发送自定义事件 ✅"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    
    NSLog(@"📊 发送自定义事件: custom_event，属性: %@", properties);
}

- (void)sendProductView {
    NSDictionary *properties = @{
        @"product_id": @"lion_crispy_001",
        @"product_name": @"狮乐购牛脆片",
        @"category": @"零食",
        @"price": @29.9,
        @"currency": @"CNY"
    };
    
    [[LionmoboDataCore sharedInstance] trackEvent:@"product_view" properties:properties];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"商品查看事件"
                                                                   message:@"已记录商品查看: 狮乐购牛脆片 ✅"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    
    NSLog(@"🛍️ 商品查看事件: %@", properties);
}

- (void)sendPurchaseEvent {
    NSDictionary *properties = @{
        @"product_id": @"lion_crispy_001",
        @"product_name": @"狮乐购牛脆片",
        @"quantity": @2,
        @"total_amount": @59.8,
        @"currency": @"CNY",
        @"payment_method": @"alipay"
    };
    
    [[LionmoboDataCore sharedInstance] trackEvent:@"purchase" properties:properties];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"购买事件"
                                                                   message:@"已记录购买: 狮乐购牛脆片 x2 ✅"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    
    NSLog(@"💰 购买事件: %@", properties);
}

- (void)showPageTracking {
    SecondViewController *pageTrackingVC = [[SecondViewController alloc] init];
    [self.navigationController pushViewController:pageTrackingVC animated:YES];
}

#pragma mark - 日志系统演示

- (void)logDebug {
    [[LionmoboDataLogger sharedInstance] logWithLevel:LionmoboDataLogLevelDebug message:@"这是一条Debug级别的日志消息"];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Debug日志"
                                                                   message:@"已输出Debug日志 ✅\n请查看Xcode控制台"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)logInfo {
    [[LionmoboDataLogger sharedInstance] logWithLevel:LionmoboDataLogLevelInfo message:@"这是一条Info级别的日志消息"];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Info日志"
                                                                   message:@"已输出Info日志 ✅\n请查看Xcode控制台"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)logWarning {
    [[LionmoboDataLogger sharedInstance] logWithLevel:LionmoboDataLogLevelWarning message:@"这是一条Warning级别的日志消息"];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning日志"
                                                                   message:@"已输出Warning日志 ⚠️\n请查看Xcode控制台"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)logError {
    [[LionmoboDataLogger sharedInstance] logWithLevel:LionmoboDataLogLevelError message:@"这是一条Error级别的日志消息"];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error日志"
                                                                   message:@"已输出Error日志 ❌\n请查看Xcode控制台"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 通知系统演示

- (void)showSDKNotifications {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"SDK通知系统"
                                                                   message:@"SDK已注册通知监听:\n• LionmoboDataEventSent\n• LionmoboDataError\n\n执行其他操作时将收到通知"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showUploadNotifications {
    // 模拟数据上传通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LionmoboDataEventSent" 
                                                        object:nil 
                                                      userInfo:@{@"event": @"upload_demo", @"status": @"success"}];
}

- (void)showErrorNotifications {
    // 模拟错误通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LionmoboDataError" 
                                                        object:nil 
                                                      userInfo:@{@"error": @"网络连接失败", @"code": @"E001"}];
}

#pragma mark - 高级功能演示

- (void)simulateCrash {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"模拟崩溃"
                                                                   message:@"确定要触发崩溃测试吗？\n⚠️ 应用将会崩溃！"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定崩溃" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // 故意触发崩溃进行测试
        NSArray *array = @[];
        NSLog(@"崩溃测试: %@", array[10]); // 越界访问将导致崩溃
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)checkNetworkStatus {
    // 这里可以集成实际的网络监控功能
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"网络状态"
                                                                   message:@"网络状态: 已连接 ✅\n网络类型: WiFi\n信号强度: 强"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    
    NSLog(@"🌐 网络状态检查完成");
}

- (void)showDeviceInfo {
    UIDevice *device = [UIDevice currentDevice];
    NSString *deviceInfo = [NSString stringWithFormat:@"设备型号: %@\n系统版本: %@\n设备名称: %@\n电池电量: %.0f%%",
                           device.model,
                           device.systemVersion,
                           device.name,
                           device.batteryLevel * 100];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设备信息"
                                                                   message:deviceInfo
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    
    NSLog(@"📱 设备信息: %@", deviceInfo);
}

- (void)clearData {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"清除数据"
                                                                   message:@"确定要清除所有本地数据吗？"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // 这里可以调用SDK的数据清除方法
        NSLog(@"🗑️ 开始清除本地数据...");
        
        // 模拟清除过程
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:@"清除完成"
                                                                                   message:@"所有本地数据已清除 ✅"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
            [successAlert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:successAlert animated:YES completion:nil];
            
            NSLog(@"✅ 数据清除完成");
        });
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 通知处理

- (void)handleSDKNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *notificationName = notification.name;
        NSDictionary *userInfo = notification.userInfo;
        
        NSString *message = [NSString stringWithFormat:@"收到SDK通知:\n%@\n\n详情: %@", notificationName, userInfo];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"SDK通知"
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        
        NSLog(@"🔔 SDK通知: %@ - %@", notificationName, userInfo);
    });
}

#pragma mark - 生命周期

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"📄 主页面即将显示");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"📄 主页面已显示");
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"📄 主页面已消失");
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"🗑️ ViewController 已释放");
}

@end

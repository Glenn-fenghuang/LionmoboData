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

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, assign) BOOL isSDKInitialized;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"LionmoboData SDK 演示";
    
    // 初始化数据
    [self setupDemoData];
    
    // 设置UI
    [self setupUI];
    
    // 设置通知监听
    [self setupNotifications];
    
    // 检查SDK状态
    [self updateSDKStatus];
}

#pragma mark - 数据初始化

- (void)setupDemoData {
    self.demoSections = @[
        @{
            @"title": @"🚀 SDK 初始化",
            @"items": @[
                @{@"title": @"初始化 SDK", @"subtitle": @"配置并启动 SDK", @"action": @"initSDK"},
                @{@"title": @"获取 SDK 信息", @"subtitle": @"版本号、状态等", @"action": @"showSDKInfo"},
                @{@"title": @"配置 Debug 模式", @"subtitle": @"开启/关闭调试", @"action": @"toggleDebugMode"}
            ]
        },
        @{
            @"title": @"👤 用户管理",
            @"items": @[
                @{@"title": @"设置用户 ID", @"subtitle": @"设置当前用户标识", @"action": @"setUserID"},
                @{@"title": @"获取 IDFA 权限", @"subtitle": @"请求 IDFA 追踪权限", @"action": @"requestIDFA"},
                @{@"title": @"设置 IDFA", @"subtitle": @"上报设备 IDFA", @"action": @"setIDFA"}
            ]
        },
        @{
            @"title": @"📊 事件追踪",
            @"items": @[
                @{@"title": @"自定义事件", @"subtitle": @"发送自定义事件", @"action": @"sendCustomEvent"},
                @{@"title": @"页面跟踪演示", @"subtitle": @"进入页面跟踪演示", @"action": @"showPageTracking"},
                @{@"title": @"点击事件演示", @"subtitle": @"测试点击事件追踪", @"action": @"testClickTracking"}
            ]
        },
        @{
            @"title": @"🔧 日志系统",
            @"items": @[
                @{@"title": @"日志输出测试", @"subtitle": @"测试各级别日志", @"action": @"testLogging"},
                @{@"title": @"开启/关闭日志", @"subtitle": @"控制日志输出", @"action": @"toggleLogging"},
                @{@"title": @"查看日志状态", @"subtitle": @"当前日志配置", @"action": @"showLogStatus"}
            ]
        },
        @{
            @"title": @"🔔 通知系统",
            @"items": @[
                @{@"title": @"注册通知监听", @"subtitle": @"监听 SDK 通知", @"action": @"registerNotifications"},
                @{@"title": @"通知历史", @"subtitle": @"查看接收到的通知", @"action": @"showNotificationHistory"},
                @{@"title": @"模拟通知", @"subtitle": @"发送测试通知", @"action": @"simulateNotification"}
            ]
        },
        @{
            @"title": @"🧪 高级功能",
            @"items": @[
                @{@"title": @"崩溃测试", @"subtitle": @"测试崩溃报告功能", @"action": @"testCrash"},
                @{@"title": @"网络状态监控", @"subtitle": @"监控网络连接状态", @"action": @"monitorNetwork"},
                @{@"title": @"设备信息", @"subtitle": @"获取设备相关信息", @"action": @"showDeviceInfo"}
            ]
        }
    ];
}

#pragma mark - UI 设置

- (void)setupUI {
    // 头部状态视图
    [self setupHeaderView];
    
    // 表格视图
    [self setupTableView];
    
    // 约束设置
    [self setupConstraints];
}

- (void)setupHeaderView {
    self.headerView = [[UIView alloc] init];
    self.headerView.backgroundColor = [UIColor systemBlueColor];
    self.headerView.layer.cornerRadius = 12;
    self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.headerView];
    
    // SDK 状态标签
    self.sdkStatusLabel = [[UILabel alloc] init];
    self.sdkStatusLabel.text = @"🔴 SDK 未初始化";
    self.sdkStatusLabel.textColor = [UIColor whiteColor];
    self.sdkStatusLabel.font = [UIFont boldSystemFontOfSize:16];
    self.sdkStatusLabel.textAlignment = NSTextAlignmentCenter;
    self.sdkStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerView addSubview:self.sdkStatusLabel];
    
    // 初始化按钮
    self.customButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.customButton setTitle:@"立即初始化" forState:UIControlStateNormal];
    [self.customButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.customButton.backgroundColor = [UIColor systemOrangeColor];
    self.customButton.layer.cornerRadius = 8;
    self.customButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.customButton addTarget:self action:@selector(initSDK) forControlEvents:UIControlEventTouchUpInside];
    self.customButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerView addSubview:self.customButton];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];
}

- (void)setupConstraints {
    [NSLayoutConstraint activateConstraints:@[
        // 头部视图
        [self.headerView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:10],
        [self.headerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [self.headerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [self.headerView.heightAnchor constraintEqualToConstant:80],
        
        // SDK 状态标签
        [self.sdkStatusLabel.topAnchor constraintEqualToAnchor:self.headerView.topAnchor constant:12],
        [self.sdkStatusLabel.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor constant:16],
        [self.sdkStatusLabel.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor constant:-16],
        
        // 初始化按钮
        [self.customButton.topAnchor constraintEqualToAnchor:self.sdkStatusLabel.bottomAnchor constant:8],
        [self.customButton.centerXAnchor constraintEqualToAnchor:self.headerView.centerXAnchor],
        [self.customButton.widthAnchor constraintEqualToConstant:120],
        [self.customButton.heightAnchor constraintEqualToConstant:32],
        
        // 表格视图
        [self.tableView.topAnchor constraintEqualToAnchor:self.headerView.bottomAnchor constant:10],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

#pragma mark - 通知设置

- (void)setupNotifications {
    [LionmoboDataNotificationManager addObserver:self
                                         selector:@selector(onSDKInitialized:)
                                             name:LionmoboDataDidInitializeNotification];
    
    [LionmoboDataNotificationManager addObserver:self
                                         selector:@selector(onSDKInitializeFailed:)
                                             name:LionmoboDataDidFailToInitializeNotification];
    
    [LionmoboDataNotificationManager addObserver:self
                                         selector:@selector(onConfigChanged:)
                                             name:LionmoboDataConfigDidChangeNotification];
}

#pragma mark - SDK 状态更新

- (void)updateSDKStatus {
    self.isSDKInitialized = [LionmoboDataCore isInitialized];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isSDKInitialized) {
            self.sdkStatusLabel.text = @"🟢 SDK 已初始化";
            self.customButton.hidden = YES;
            self.headerView.backgroundColor = [UIColor systemGreenColor];
        } else {
            self.sdkStatusLabel.text = @"🔴 SDK 未初始化";
            self.customButton.hidden = NO;
            self.headerView.backgroundColor = [UIColor systemRedColor];
        }
    });
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *sectionData = self.demoSections[section];
    return sectionData[@"title"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"DemoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSDictionary *sectionData = self.demoSections[indexPath.section];
    NSArray *items = sectionData[@"items"];
    NSDictionary *item = items[indexPath.row];
    
    cell.textLabel.text = item[@"title"];
    cell.detailTextLabel.text = item[@"subtitle"];
    cell.detailTextLabel.textColor = [UIColor systemGrayColor];
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *sectionData = self.demoSections[indexPath.section];
    NSArray *items = sectionData[@"items"];
    NSDictionary *item = items[indexPath.row];
    
    NSString *action = item[@"action"];
    SEL selector = NSSelectorFromString(action);
    
    if ([self respondsToSelector:selector]) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:selector];
        #pragma clang diagnostic pop
    }
}

#pragma mark - SDK 功能演示方法

- (void)initSDK {
    LionmoboDataConfig *config = [[LionmoboDataConfig alloc] init];
    config.appID = @"demo_app_001";
    config.serverURL = @"https://api.lionmobo.com";
    config.apiKey = @"demo_api_key_123";
    config.apiSecret = @"demo_api_secret_456";
    config.debugMode = YES;
    config.crashReportingEnabled = YES;
    config.networkLoggingEnabled = YES;
    config.pageTrackingEnabled = YES;
    config.clickTrackingEnabled = YES;
    config.launchTrackingEnabled = YES;
    config.timeoutInterval = 30.0;
    config.pagePathTrackingMode = 0;
    config.hotStartTimeoutInterval = 30.0;
    
    [LionmoboDataCore startWithConfig:config];
    
    [self showAlert:@"SDK 初始化" message:@"正在初始化 SDK，请等待通知..."];
}

- (void)showSDKInfo {
    if (![LionmoboDataCore isInitialized]) {
        [self showAlert:@"错误" message:@"请先初始化 SDK"];
        return;
    }
    
    NSString *version = [LionmoboDataCore sdkVersion];
    LionmoboDataConfig *config = [LionmoboDataCore currentConfig];
    
    NSString *info = [NSString stringWithFormat:@"SDK 版本: %@\n应用 ID: %@\n服务器地址: %@\n调试模式: %@\n页面追踪: %@\n点击追踪: %@",
                     version,
                     config.appID,
                     config.serverURL,
                     config.debugMode ? @"开启" : @"关闭",
                     config.pageTrackingEnabled ? @"开启" : @"关闭",
                     config.clickTrackingEnabled ? @"开启" : @"关闭"];
    
    [self showAlert:@"SDK 信息" message:info];
}

- (void)toggleDebugMode {
    if (![LionmoboDataCore isInitialized]) {
        [self showAlert:@"错误" message:@"请先初始化 SDK"];
        return;
    }
    
    LionmoboDataConfig *config = [LionmoboDataCore currentConfig];
    config.debugMode = !config.debugMode;
    
    [self showAlert:@"调试模式" message:config.debugMode ? @"已开启调试模式" : @"已关闭调试模式"];
}

- (void)setUserID {
    if (![LionmoboDataCore isInitialized]) {
        [self showAlert:@"错误" message:@"请先初始化 SDK"];
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设置用户 ID"
                                                                   message:@"请输入用户 ID"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"user_12345";
        textField.text = @"demo_user_001";
    }];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
        UITextField *textField = alert.textFields.firstObject;
        NSString *userID = textField.text;
        
        if (userID.length > 0) {
            [LionmoboDataCore setUserID:userID];
            [self showAlert:@"成功" message:[NSString stringWithFormat:@"用户 ID 已设置为: %@", userID]];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [alert addAction:cancelAction];
    [alert addAction:confirmAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)requestIDFA {
    if (@available(iOS 14.5, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *statusString = @"";
                switch (status) {
                    case ATTrackingManagerAuthorizationStatusNotDetermined:
                        statusString = @"未确定";
                        break;
                    case ATTrackingManagerAuthorizationStatusRestricted:
                        statusString = @"受限";
                        break;
                    case ATTrackingManagerAuthorizationStatusDenied:
                        statusString = @"拒绝";
                        break;
                    case ATTrackingManagerAuthorizationStatusAuthorized:
                        statusString = @"已授权";
                        // 获取 IDFA
                        NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
                        [LionmoboDataCore setDeviceWithIdfa:idfa];
                        break;
                }
                
                [self showAlert:@"IDFA 权限请求" message:[NSString stringWithFormat:@"当前状态: %@", statusString]];
            });
        }];
    } else {
        // iOS 14.5 以下版本直接获取 IDFA
        NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        [LionmoboDataCore setDeviceWithIdfa:idfa];
        [self showAlert:@"IDFA" message:@"已自动获取并设置 IDFA"];
    }
}

- (void)setIDFA {
    if (![LionmoboDataCore isInitialized]) {
        [self showAlert:@"错误" message:@"请先初始化 SDK"];
        return;
    }
    
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    [LionmoboDataCore setDeviceWithIdfa:idfa];
    
    [self showAlert:@"IDFA 设置" message:[NSString stringWithFormat:@"已设置 IDFA: %@", idfa]];
}

- (void)sendCustomEvent {
    if (![LionmoboDataCore isInitialized]) {
        [self showAlert:@"错误" message:@"请先初始化 SDK"];
        return;
    }
    
    NSDictionary *eventDetail = @{
        @"product_name": @"狮乐购牛脆片",
        @"product_id": @"12345",
        @"price": @29.9,
        @"quantity": @2,
        @"category": @"零食",
        @"timestamp": @([[NSDate date] timeIntervalSince1970])
    };
    
    [LionmoboDataCore customEventName:@"product_purchase" detail:eventDetail];
    
    [self showAlert:@"自定义事件" message:@"已发送 'product_purchase' 事件"];
}

- (void)showPageTracking {
    SecondViewController *secondVC = [[SecondViewController alloc] init];
    [self.navigationController pushViewController:secondVC animated:YES];
}

- (void)testClickTracking {
    [self showAlert:@"点击事件" message:@"此弹窗的显示本身就是一个点击事件追踪的演示！"];
}

- (void)testLogging {
    [LionmoboDataLogger logInfo:@"这是一条信息日志"];
    [LionmoboDataLogger logSuccessInfo:@"这是一条成功日志"];
    [LionmoboDataLogger logWarning:@"这是一条警告日志"];
    [LionmoboDataLogger logError:@"这是一条错误日志"];
    [LionmoboDataLogger logDebug:@"这是一条调试日志"];
    
    [self showAlert:@"日志测试" message:@"已输出各级别日志，请查看控制台"];
}

- (void)toggleLogging {
    BOOL currentStatus = [LionmoboDataLogger isLogEnabled];
    [LionmoboDataLogger setLogEnabled:!currentStatus];
    
    NSString *message = [LionmoboDataLogger isLogEnabled] ? @"日志输出已开启" : @"日志输出已关闭";
    [self showAlert:@"日志状态" message:message];
}

- (void)showLogStatus {
    BOOL isEnabled = [LionmoboDataLogger isLogEnabled];
    NSString *status = isEnabled ? @"开启" : @"关闭";
    
    [self showAlert:@"日志状态" message:[NSString stringWithFormat:@"当前日志输出状态: %@", status]];
}

- (void)registerNotifications {
    // 已在 setupNotifications 中注册
    [self showAlert:@"通知注册" message:@"SDK 通知监听已注册，初始化 SDK 时将收到通知"];
}

- (void)showNotificationHistory {
    [self showAlert:@"通知历史" message:@"请查看控制台输出的通知接收记录"];
}

- (void)simulateNotification {
    // 模拟发送配置变更通知
    LionmoboDataConfig *config = [LionmoboDataCore currentConfig];
    if (config) {
        [LionmoboDataNotificationManager postConfigChangeNotificationWithConfig:config];
        [self showAlert:@"模拟通知" message:@"已发送配置变更通知"];
    } else {
        [self showAlert:@"模拟通知" message:@"请先初始化 SDK"];
    }
}

- (void)testCrash {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"崩溃测试"
                                                                   message:@"确定要触发测试崩溃吗？这将导致应用闪退。"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定崩溃"
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction *action) {
        // 故意触发崩溃
        NSArray *array = @[];
        NSLog(@"%@", array[10]); // 数组越界崩溃
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [alert addAction:cancelAction];
    [alert addAction:confirmAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)monitorNetwork {
    [self showAlert:@"网络监控" message:@"网络状态监控功能已在 SDK 内部运行\n请查看控制台输出的网络状态信息"];
}

- (void)showDeviceInfo {
    NSString *deviceInfo = [NSString stringWithFormat:@"设备型号: %@\n系统版本: %@\n应用版本: %@\n设备 ID: %@",
                           [[UIDevice currentDevice] model],
                           [[UIDevice currentDevice] systemVersion],
                           [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
                           [[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    
    [self showAlert:@"设备信息" message:deviceInfo];
}

#pragma mark - 通知响应

- (void)onSDKInitialized:(NSNotification *)notification {
    NSLog(@"🎉 收到 SDK 初始化成功通知");
    [self updateSDKStatus];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlert:@"初始化成功" message:@"SDK 已成功初始化！"];
    });
}

- (void)onSDKInitializeFailed:(NSNotification *)notification {
    NSError *error = notification.userInfo[LionmoboDataNotificationErrorKey];
    NSLog(@"❌ 收到 SDK 初始化失败通知: %@", error.localizedDescription);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlert:@"初始化失败" message:[NSString stringWithFormat:@"SDK 初始化失败: %@", error.localizedDescription]];
    });
}

- (void)onConfigChanged:(NSNotification *)notification {
    NSLog(@"⚙️ 收到配置变更通知");
    [self updateSDKStatus];
}

#pragma mark - 辅助方法

- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)dealloc {
    [LionmoboDataNotificationManager removeObserver:self name:nil];
}

@end

//
//  SecondViewController.m
//  LionmoboDemo
//
//  Created by lionmobo on 2025/7/7.
//

#import "SecondViewController.h"
#import <LionmoboData/LionmoboData.h>

@interface SecondViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UITableView *tableView;

// 页面停留时间相关
@property (nonatomic, assign) NSTimeInterval pageStartTime;
@property (nonatomic, strong) NSTimer *durationUpdateTimer;

// 演示数据
@property (nonatomic, strong) NSArray *trackingDemoItems;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"页面跟踪演示";
    
    // 初始化演示数据
    [self setupDemoData];
    
    // 设置UI
    [self setupUI];
    
    NSLog(@"📱 [页面跟踪] 页面加载: %@", NSStringFromClass([self class]));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"📱 [页面跟踪] 页面即将显示: %@", NSStringFromClass([self class]));
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 记录页面开始时间
    self.pageStartTime = [[NSDate date] timeIntervalSince1970];
    
    // 启动定时器，每秒更新一次停留时间显示
    self.durationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                target:self
                                                              selector:@selector(updateDurationDisplay)
                                                              userInfo:nil
                                                               repeats:YES];
    
    NSLog(@"📱 [页面跟踪] 页面已显示: %@，开始计算停留时间", NSStringFromClass([self class]));
    
    // 发送页面查看事件
    [self sendPageViewEvent];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"📱 [页面跟踪] 页面即将消失: %@", NSStringFromClass([self class]));
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 停止定时器
    if (self.durationUpdateTimer) {
        [self.durationUpdateTimer invalidate];
        self.durationUpdateTimer = nil;
    }
    
    // 计算最终停留时间并发送事件
    if (self.pageStartTime > 0) {
        NSTimeInterval finalDuration = [[NSDate date] timeIntervalSince1970] - self.pageStartTime;
        NSLog(@"📱 [页面跟踪] 页面已消失: %@，停留时间: %.1f秒", NSStringFromClass([self class]), finalDuration);
        
        // 发送页面离开事件
        [self sendPageLeaveEventWithDuration:finalDuration];
        
        self.pageStartTime = 0;
    }
}

#pragma mark - 数据初始化

- (void)setupDemoData {
    self.trackingDemoItems = @[
        @{
            @"title": @"🔄 刷新页面数据",
            @"subtitle": @"模拟页面内容刷新",
            @"action": @"refreshPageData"
        },
        @{
            @"title": @"🎯 点击追踪演示",
            @"subtitle": @"测试点击事件追踪",
            @"action": @"testClickEvent"
        },
        @{
            @"title": @"📊 发送页面事件",
            @"subtitle": @"手动发送页面相关事件",
            @"action": @"sendPageEvent"
        },
        @{
            @"title": @"🔀 跳转到子页面",
            @"subtitle": @"测试页面路径追踪",
            @"action": @"goToSubPage"
        },
        @{
            @"title": @"📱 弹出模态页面",
            @"subtitle": @"测试模态页面追踪",
            @"action": @"presentModalPage"
        },
        @{
            @"title": @"⚠️ 模拟页面错误",
            @"subtitle": @"测试页面错误追踪",
            @"action": @"simulatePageError"
        },
        @{
            @"title": @"📈 查看追踪统计",
            @"subtitle": @"显示当前页面追踪信息",
            @"action": @"showTrackingStats"
        }
    ];
}

#pragma mark - UI 设置

- (void)setupUI {
    // 头部信息视图
    [self setupHeaderView];
    
    // 表格视图
    [self setupTableView];
    
    // 设置约束
    [self setupConstraints];
}

- (void)setupHeaderView {
    self.headerView = [[UIView alloc] init];
    self.headerView.backgroundColor = [UIColor systemPurpleColor];
    self.headerView.layer.cornerRadius = 12;
    self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.headerView];
    
    // 标题标签
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"📊 页面跟踪演示";
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerView addSubview:self.titleLabel];
    
    // 停留时间显示标签
    self.durationLabel = [[UILabel alloc] init];
    self.durationLabel.text = @"⏱️ 页面停留时间: 0.0秒";
    self.durationLabel.textAlignment = NSTextAlignmentCenter;
    self.durationLabel.font = [UIFont systemFontOfSize:16];
    self.durationLabel.textColor = [UIColor systemYellowColor];
    self.durationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerView addSubview:self.durationLabel];
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
        
        // 标题标签
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.headerView.topAnchor constant:12],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor constant:16],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor constant:-16],
        
        // 停留时间标签
        [self.durationLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:8],
        [self.durationLabel.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor constant:16],
        [self.durationLabel.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor constant:-16],
        
        // 表格视图
        [self.tableView.topAnchor constraintEqualToAnchor:self.headerView.bottomAnchor constant:10],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.trackingDemoItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"TrackingDemoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSDictionary *item = self.trackingDemoItems[indexPath.row];
    
    cell.textLabel.text = item[@"title"];
    cell.detailTextLabel.text = item[@"subtitle"];
    cell.detailTextLabel.textColor = [UIColor systemGrayColor];
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *item = self.trackingDemoItems[indexPath.row];
    NSString *action = item[@"action"];
    SEL selector = NSSelectorFromString(action);
    
    if ([self respondsToSelector:selector]) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:selector];
        #pragma clang diagnostic pop
    }
}

#pragma mark - 页面跟踪功能演示

- (void)refreshPageData {
    [self showAlert:@"页面刷新" message:@"模拟页面数据刷新"];
    
    // 发送页面刷新事件
    if ([LionmoboDataCore isInitialized]) {
        [LionmoboDataCore customEventName:@"page_refresh" detail:@{
            @"page_name": NSStringFromClass([self class]),
            @"page_title": self.title ?: @"",
            @"refresh_time": @([[NSDate date] timeIntervalSince1970])
        }];
    }
}

- (void)testClickEvent {
    NSString *buttonTitle = @"测试按钮";
    [self showAlert:@"点击事件" message:[NSString stringWithFormat:@"您点击了：%@", buttonTitle]];
    
    // 发送点击事件
    if ([LionmoboDataCore isInitialized]) {
        [LionmoboDataCore customEventName:@"button_click" detail:@{
            @"button_title": buttonTitle,
            @"page_name": NSStringFromClass([self class]),
            @"click_time": @([[NSDate date] timeIntervalSince1970]),
            @"click_position": @"table_cell"
        }];
    }
}

- (void)sendPageEvent {
    if (![LionmoboDataCore isInitialized]) {
        [self showAlert:@"错误" message:@"请先初始化 SDK"];
        return;
    }
    
    NSTimeInterval currentDuration = self.pageStartTime > 0 ? [[NSDate date] timeIntervalSince1970] - self.pageStartTime : 0;
    
    [LionmoboDataCore customEventName:@"page_interaction" detail:@{
        @"page_name": NSStringFromClass([self class]),
        @"page_title": self.title ?: @"",
        @"interaction_type": @"manual_event",
        @"current_duration": @(currentDuration),
        @"timestamp": @([[NSDate date] timeIntervalSince1970])
    }];
    
    [self showAlert:@"页面事件" message:@"已发送页面交互事件"];
}

- (void)goToSubPage {
    UIViewController *subVC = [[UIViewController alloc] init];
    subVC.view.backgroundColor = [UIColor systemTealColor];
    subVC.title = @"子页面";
    
    // 添加内容到子页面
    UILabel *label = [[UILabel alloc] init];
    label.text = @"📱 这是一个子页面\n\n页面路径追踪：\n首页 → 页面跟踪演示 → 子页面\n\n这个页面的访问也会被 SDK 自动追踪";
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor whiteColor];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [subVC.view addSubview:label];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [backBtn setTitle:@"返回上级" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backBtn.backgroundColor = [UIColor systemRedColor];
    backBtn.layer.cornerRadius = 8;
    backBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [backBtn addTarget:self action:@selector(popSubPage) forControlEvents:UIControlEventTouchUpInside];
    backBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [subVC.view addSubview:backBtn];
    
    [NSLayoutConstraint activateConstraints:@[
        [label.centerXAnchor constraintEqualToAnchor:subVC.view.centerXAnchor],
        [label.centerYAnchor constraintEqualToAnchor:subVC.view.centerYAnchor],
        [label.leadingAnchor constraintEqualToAnchor:subVC.view.leadingAnchor constant:30],
        [label.trailingAnchor constraintEqualToAnchor:subVC.view.trailingAnchor constant:-30],
        
        [backBtn.centerXAnchor constraintEqualToAnchor:subVC.view.centerXAnchor],
        [backBtn.topAnchor constraintEqualToAnchor:label.bottomAnchor constant:40],
        [backBtn.widthAnchor constraintEqualToConstant:150],
        [backBtn.heightAnchor constraintEqualToConstant:44]
    ]];
    
    [self.navigationController pushViewController:subVC animated:YES];
}

- (void)presentModalPage {
    UIViewController *modalVC = [[UIViewController alloc] init];
    modalVC.view.backgroundColor = [UIColor systemIndigoColor];
    modalVC.title = @"模态页面";
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:modalVC];
    
    // 添加关闭按钮
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭"
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                 action:@selector(dismissModal)];
    modalVC.navigationItem.rightBarButtonItem = closeItem;
    
    // 添加内容
    UILabel *label = [[UILabel alloc] init];
    label.text = @"📱 这是一个模态页面\n\n模态页面的显示和关闭也会被 SDK 追踪\n\n模态页面通常用于：\n• 登录/注册流程\n• 设置页面\n• 详情查看";
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor whiteColor];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [modalVC.view addSubview:label];
    
    [NSLayoutConstraint activateConstraints:@[
        [label.centerXAnchor constraintEqualToAnchor:modalVC.view.centerXAnchor],
        [label.centerYAnchor constraintEqualToAnchor:modalVC.view.centerYAnchor],
        [label.leadingAnchor constraintEqualToAnchor:modalVC.view.leadingAnchor constant:30],
        [label.trailingAnchor constraintEqualToAnchor:modalVC.view.trailingAnchor constant:-30]
    ]];
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)simulatePageError {
    [self showAlert:@"页面错误" message:@"模拟页面加载失败"];
    
    // 发送页面错误事件
    if ([LionmoboDataCore isInitialized]) {
        [LionmoboDataCore customEventName:@"page_error" detail:@{
            @"page_name": NSStringFromClass([self class]),
            @"error_type": @"load_failure",
            @"error_message": @"模拟的页面加载错误",
            @"error_code": @"E001",
            @"timestamp": @([[NSDate date] timeIntervalSince1970])
        }];
    }
}

- (void)showTrackingStats {
    NSTimeInterval currentDuration = self.pageStartTime > 0 ? [[NSDate date] timeIntervalSince1970] - self.pageStartTime : 0;
    
    NSString *stats = [NSString stringWithFormat:@"📊 页面追踪统计\n\n页面名称: %@\n页面标题: %@\n当前停留时间: %.1f秒\n页面状态: %@\nSDK 状态: %@",
                      NSStringFromClass([self class]),
                      self.title ?: @"无标题",
                      currentDuration,
                      self.pageStartTime > 0 ? @"活跃" : @"未激活",
                      [LionmoboDataCore isInitialized] ? @"已初始化" : @"未初始化"];
    
    [self showAlert:@"追踪统计" message:stats];
}

- (void)popSubPage {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissModal {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 事件发送

- (void)sendPageViewEvent {
    if (![LionmoboDataCore isInitialized]) {
        return;
    }
    
    [LionmoboDataCore customEventName:@"page_view" detail:@{
        @"page_name": NSStringFromClass([self class]),
        @"page_title": self.title ?: @"",
        @"page_type": @"tracking_demo",
        @"view_time": @([[NSDate date] timeIntervalSince1970]),
        @"referrer_page": @"ViewController"
    }];
}

- (void)sendPageLeaveEventWithDuration:(NSTimeInterval)duration {
    if (![LionmoboDataCore isInitialized]) {
        return;
    }
    
    [LionmoboDataCore customEventName:@"page_leave" detail:@{
        @"page_name": NSStringFromClass([self class]),
        @"page_title": self.title ?: @"",
        @"duration": @(duration),
        @"leave_time": @([[NSDate date] timeIntervalSince1970]),
        @"leave_type": @"navigation"
    }];
}

#pragma mark - 停留时间更新

- (void)updateDurationDisplay {
    if (self.pageStartTime > 0) {
        NSTimeInterval currentDuration = [[NSDate date] timeIntervalSince1970] - self.pageStartTime;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.durationLabel.text = [NSString stringWithFormat:@"⏱️ 页面停留时间: %.1f秒", currentDuration];
        });
    }
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
    if (self.durationUpdateTimer) {
        [self.durationUpdateTimer invalidate];
        self.durationUpdateTimer = nil;
    }
    
    NSLog(@"📱 [页面跟踪] 页面销毁: %@", NSStringFromClass([self class]));
}

@end

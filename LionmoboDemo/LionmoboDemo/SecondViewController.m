//
//  SecondViewController.m
//  LionmoboDemo
//
//  Created by lionmobo on 2025/7/7.
//

#import "SecondViewController.h"
#import <LionmoboData/LionmoboData.h>

@interface SecondViewController ()

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *thirdPageButton;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UILabel *durationLabel;

// 页面停留时间相关
@property (nonatomic, assign) NSTimeInterval pageStartTime;
@property (nonatomic, strong) NSTimer *durationUpdateTimer;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemGreenColor];
    self.title = @"第二个页面";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    
    [self setupUI];
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
    [self updateDurationDisplay];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 停止定时器
    if (self.durationUpdateTimer) {
        [self.durationUpdateTimer invalidate];
        self.durationUpdateTimer = nil;
    }
    
    // 计算最终停留时间并显示
    if (self.pageStartTime > 0) {
        NSTimeInterval finalDuration = [[NSDate date] timeIntervalSince1970] - self.pageStartTime;
        NSLog(@"📊 [页面追踪] %@ 页面停留时间: %.1f秒", NSStringFromClass([self class]), finalDuration);
        self.pageStartTime = 0;
    }
}

- (void)setupUI {
    // 信息标签
    self.infoLabel = [[UILabel alloc] init];
    self.infoLabel.text = @"这是第二个页面\n\n页面追踪系统正在自动记录：\n• 页面名称: SecondViewController\n• 页面标题: 第二个页面\n• 页面路径\n• 停留时长";
    self.infoLabel.numberOfLines = 0;
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    self.infoLabel.font = [UIFont systemFontOfSize:16];
    self.infoLabel.textColor = [UIColor whiteColor];
    self.infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.infoLabel];
    
    // 停留时间显示标签
    self.durationLabel = [[UILabel alloc] init];
    self.durationLabel.text = @"⏱️ 页面停留时间: 0.0秒";
    self.durationLabel.textAlignment = NSTextAlignmentCenter;
    self.durationLabel.font = [UIFont boldSystemFontOfSize:18];
    self.durationLabel.textColor = [UIColor systemYellowColor];
    self.durationLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    self.durationLabel.layer.cornerRadius = 8;
    self.durationLabel.layer.masksToBounds = YES;
    self.durationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.durationLabel];
    
    // 跳转到第三个页面按钮
    self.thirdPageButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.thirdPageButton setTitle:@"跳转到第三个页面" forState:UIControlStateNormal];
    [self.thirdPageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.thirdPageButton.backgroundColor = [UIColor systemBlueColor];
    self.thirdPageButton.layer.cornerRadius = 8;
    self.thirdPageButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.thirdPageButton addTarget:self action:@selector(goToThirdPage) forControlEvents:UIControlEventTouchUpInside];
    self.thirdPageButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.thirdPageButton];
    
    // 返回按钮
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setTitle:@"返回首页" forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.backButton.backgroundColor = [UIColor systemRedColor];
    self.backButton.layer.cornerRadius = 8;
    self.backButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.backButton];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        [self.infoLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.infoLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:30],
        [self.infoLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:30],
        [self.infoLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-30],
        
        [self.durationLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.durationLabel.topAnchor constraintEqualToAnchor:self.infoLabel.bottomAnchor constant:30],
        [self.durationLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:50],
        [self.durationLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-50],
        [self.durationLabel.heightAnchor constraintEqualToConstant:44],
        
        [self.thirdPageButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.thirdPageButton.topAnchor constraintEqualToAnchor:self.durationLabel.bottomAnchor constant:40],
        [self.thirdPageButton.widthAnchor constraintEqualToConstant:200],
        [self.thirdPageButton.heightAnchor constraintEqualToConstant:50],
        
        [self.backButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.backButton.topAnchor constraintEqualToAnchor:self.thirdPageButton.bottomAnchor constant:30],
        [self.backButton.widthAnchor constraintEqualToConstant:200],
        [self.backButton.heightAnchor constraintEqualToConstant:50]
    ]];
}

- (void)goToThirdPage {
    UIViewController *thirdVC = [[UIViewController alloc] init];
    thirdVC.view.backgroundColor = [UIColor systemPurpleColor];
    thirdVC.title = @"第三个页面";
    
    // 添加一些内容到第三个页面
    UILabel *label = [[UILabel alloc] init];
    label.text = @"这是第三个页面\n\n测试页面路径追踪：\nViewController > SecondViewController > UIViewController";
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor whiteColor];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [thirdVC.view addSubview:label];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backBtn.backgroundColor = [UIColor systemRedColor];
    backBtn.layer.cornerRadius = 8;
    backBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [backBtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    backBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [thirdVC.view addSubview:backBtn];
    
    [NSLayoutConstraint activateConstraints:@[
        [label.centerXAnchor constraintEqualToAnchor:thirdVC.view.centerXAnchor],
        [label.centerYAnchor constraintEqualToAnchor:thirdVC.view.centerYAnchor],
        [label.leadingAnchor constraintEqualToAnchor:thirdVC.view.leadingAnchor constant:30],
        [label.trailingAnchor constraintEqualToAnchor:thirdVC.view.trailingAnchor constant:-30],
        
        [backBtn.centerXAnchor constraintEqualToAnchor:thirdVC.view.centerXAnchor],
        [backBtn.topAnchor constraintEqualToAnchor:label.bottomAnchor constant:50],
        [backBtn.widthAnchor constraintEqualToConstant:150],
        [backBtn.heightAnchor constraintEqualToConstant:50]
    ]];
    
    [self.navigationController pushViewController:thirdVC animated:YES];
}

- (void)popViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goBack {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - 停留时间更新

- (void)updateDurationDisplay {
    if (self.pageStartTime > 0) {
        NSTimeInterval currentDuration = [[NSDate date] timeIntervalSince1970] - self.pageStartTime;
        self.durationLabel.text = [NSString stringWithFormat:@"⏱️ 页面停留时间: %.1f秒", currentDuration];
    }
}

- (void)dealloc {
    if (self.durationUpdateTimer) {
        [self.durationUpdateTimer invalidate];
        self.durationUpdateTimer = nil;
    }
}

@end 

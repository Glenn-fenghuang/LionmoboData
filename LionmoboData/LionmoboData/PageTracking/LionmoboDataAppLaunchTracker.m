//
//  LionmoboDataAppLaunchTracker.m
//  LionmoboData
//
//  Created by LionmoboData SDK on 2025/1/9.
//  Copyright © 2025 LionmoboData. All rights reserved.
//

#import "LionmoboDataAppLaunchTracker.h"
#import <UIKit/UIKit.h>
#import "../Logging/LionmoboDataLogger.h"
#import "LionmoboDataAppLaunchEvent.h"
#import "../Utils/LionmoboDataNetworkManager.h"
// 上传地址常量
static NSString * const kAppLaunchEventUploadURL = @"/api/sdkPutEvents";

@interface LionmoboDataAppLaunchTracker ()


@end

@implementation LionmoboDataAppLaunchTracker

#pragma mark - 单例和初始化

#pragma mark - 单例和初始化

+ (instancetype)sharedTracker {
    static LionmoboDataAppLaunchTracker *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _enabled = NO;
    }
    return self;
}

#pragma mark - 公共方法

- (void)startTracking {
    if (self.enabled) {
        LMBLogDebug(@"[AppLaunchTracker] 启动监控已开启，跳过重复注册");
        return;
    }
    
    self.enabled = YES;
    
    // 注册应用生命周期通知
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(applicationDidBecomeActive:)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(applicationDidEnterBackground:)
                   name:UIApplicationDidEnterBackgroundNotification
                 object:nil];
    
    LMBLogDebug(@"[AppLaunchTracker] 启动监控已开启");
    
    
}

- (void)stopTracking {
    if (!self.enabled) {
        return;
    }
    
    self.enabled = NO;
    
    // 移除所有通知监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    LMBLogDebug(@"[AppLaunchTracker] 启动监控已停止");
}

- (void)trackAppLaunchWithBackground{
    
    LionmoboDataAppLaunchEvent *event = [LionmoboDataAppLaunchEvent launchEvent];
    
    LMBLogDebug(@"[AppLaunchTracker] 记录启动事件");
    
    // 实时上传
    [self uploadLaunchEvent:event completion:^(BOOL success, NSError *error) {
        if (success) {
            LMBLogDebug(@"[AppLaunchTracker] 启动事件上传成功");
        } else {
            LMBLogError(@"[AppLaunchTracker] 启动事件上传失败: %@", error.localizedDescription);
        }
    }];
}

- (void)trackAppTerminate {
    LionmoboDataAppLaunchEvent *event = [LionmoboDataAppLaunchEvent terminateEvent];
    
    LMBLogDebug(@"[AppLaunchTracker] 记录退出事件");
    
    // 实时上传
    [self uploadLaunchEvent:event completion:^(BOOL success, NSError *error) {
        if (success) {
            LMBLogDebug(@"[AppLaunchTracker] 退出事件上传成功");
        } else {
            LMBLogError(@"[AppLaunchTracker] 退出事件上传失败: %@", error.localizedDescription);
        }
    }];
}

#pragma mark - 应用生命周期通知处理

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    LMBLogDebug(@"[AppLaunchTracker] 应用变为活跃状态");
    
    // 如果还未追踪当前启动，现在追踪
    if (self.enabled) {
        [self trackAppLaunchWithBackground];
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    LMBLogDebug(@"[AppLaunchTracker] 应用进入后台");
    
    // 上报退出事件
    if (self.enabled) {
        [self trackAppTerminate];
    }
}


#pragma mark - 网络上传

- (void)uploadLaunchEvent:(LionmoboDataAppLaunchEvent *)event
               completion:(void(^)(BOOL success, NSError *error))completion {
    
    NSDictionary *eventData = [event toDictionary];
    NSArray *items = @[eventData];
    NSDictionary *paramets = @{@"details":items};
    [[LionmoboDataNetworkManager sharedManager] requestWithURL:@"/api/sdkPutEvents" method:LionmoboHTTPMethodPOST parameters:paramets headers:nil success:^(NSData * _Nullable data, NSDictionary * _Nullable responseObject) {
            
        } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
                
        }];
    
}

#pragma mark - dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end 

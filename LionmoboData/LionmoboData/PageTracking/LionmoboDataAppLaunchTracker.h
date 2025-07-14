//
//  LionmoboDataAppLaunchTracker.h
//  LionmoboData
//
//  Created by LionmoboData SDK on 2025/1/9.
//  Copyright © 2025 LionmoboData. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LionmoboDataAppLaunchEvent;
NS_ASSUME_NONNULL_BEGIN

/**
 * App启动监控管理器
 * 自动监控应用的启动和退出行为，判断启动类型并上报数据
 */
@interface LionmoboDataAppLaunchTracker : NSObject

/// 是否启用启动监控
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

/// 热启动判断的超时时间（秒），默认为30秒
/// 后台时间超过此值将被判定为冷启动
@property (nonatomic, assign) NSTimeInterval hotStartTimeoutInterval;

/**
 * 获取单例实例
 * @return 启动监控器实例
 */
+ (instancetype)sharedTracker;

/**
 * 开始监控
 * 注册应用生命周期通知，开始监控启动和退出事件
 */
- (void)startTracking;

/**
 * 停止监控
 * 移除应用生命周期通知监听
 */
- (void)stopTracking;

/**
 * 上传启动事件到服务器
 * @param event 启动事件数据
 * @param completion 完成回调
 */
- (void)uploadLaunchEvent:(LionmoboDataAppLaunchEvent *)event 
               completion:(nullable void(^)(BOOL success, NSError * _Nullable error))completion;





@end

NS_ASSUME_NONNULL_END 

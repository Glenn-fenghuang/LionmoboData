//
//  LionmoboDataClickTracker.h
//  LionmoboData
//
//  Created by LionmoboData SDK on 2025/1/9.
//  Copyright © 2025 LionmoboData. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class LionmoboDataClickEvent;
NS_ASSUME_NONNULL_BEGIN

/**
 * 点击事件追踪器
 * 自动捕获用户在应用内的点击行为并上报到服务器
 */
@interface LionmoboDataClickTracker : NSObject

/// 是否启用点击追踪
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

/**
 * 获取单例实例
 * @return 点击追踪器实例
 */
+ (instancetype)sharedTracker;

/**
 * 开始点击追踪
 * 启用方法交换，开始自动捕获点击事件
 */
- (void)startTracking;

/**
 * 停止点击追踪
 * 停止自动捕获点击事件
 */
- (void)stopTracking;

/**
 * 手动记录点击事件
 * @param element 被点击的UI元素
 * @param pageName 当前页面名称
 */
- (void)trackClickOnElement:(UIView *)element pageName:(NSString *)pageName;

/**
 * 上传点击事件到服务器
 * @param event 点击事件数据
 * @param completion 完成回调
 */
- (void)uploadClickEvent:(LionmoboDataClickEvent *)event completion:(nullable void(^)(BOOL success, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END 

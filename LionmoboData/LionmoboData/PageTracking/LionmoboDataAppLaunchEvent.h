//
//  LionmoboDataAppLaunchEvent.h
//  LionmoboData
//
//  Created by LionmoboData SDK on 2025/1/9.
//  Copyright © 2025 LionmoboData. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LionmoboData/LionmoboDataEvent.h>
NS_ASSUME_NONNULL_BEGIN

/**
 * App启动/退出事件数据模型
 * 用于记录应用的启动和退出行为
 */
@interface LionmoboDataAppLaunchEvent : LionmoboDataEvent


/// 自定义参数字段，可变字典
@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, assign) long long timestamp;

/**
 * 创建启动事件
 * @return 启动事件实例
 */
+ (instancetype)launchEvent;

/**
 * 创建退出事件
 * @return 退出事件实例
 */
+ (instancetype)terminateEvent;

@end

NS_ASSUME_NONNULL_END 

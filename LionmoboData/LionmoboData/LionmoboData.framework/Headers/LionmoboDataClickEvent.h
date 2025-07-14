//
//  LionmoboDataClickEvent.h
//  LionmoboData
//
//  Created by LionmoboData SDK on 2025/1/9.
//  Copyright © 2025 LionmoboData. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 点击事件数据模型
 * 用于记录用户在应用内的点击行为
 */
@interface LionmoboDataClickEvent : NSObject

/// 事件唯一标识符
@property (nonatomic, copy) NSString *eventId;

/// 当前页面名称
@property (nonatomic, copy) NSString *pageName;

/// 元素ID（如果有的话）
@property (nonatomic, copy, nullable) NSString *elementId;

/// 元素内容（按钮文字、标签文本等）
@property (nonatomic, copy, nullable) NSString *elementContent;

/// 元素类型（UIButton、UILabel、UITableViewCell等）
@property (nonatomic, copy) NSString *elementType;

/// 元素在屏幕上的位置坐标（格式："{x, y}"）
@property (nonatomic, copy) NSString *elementPosition;

/// 点击时间戳
@property (nonatomic, assign) NSTimeInterval timestamp;

/// 应用版本
@property (nonatomic, copy) NSString *appVersion;

/// 设备系统版本
@property (nonatomic, copy) NSString *systemVersion;

/// 设备型号
@property (nonatomic, copy) NSString *deviceModel;

/**
 * 便利构造方法
 * @param element 被点击的UI元素
 * @param pageName 当前页面名称
 * @return 点击事件实例
 */
+ (instancetype)eventWithElement:(UIView *)element pageName:(NSString *)pageName;

/**
 * 转换为字典格式，用于网络传输
 * @return 包含所有事件数据的字典
 */
- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END 
//
//  LionmoboDataPageEvent.h
//  LionmoboData
//
//  Created by lionmobo on 2025/7/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 页面访问事件数据模型
 */
@interface LionmoboDataPageEvent : NSObject

/// 页面名称（通常是类名）
@property (nonatomic, copy) NSString *screenName;

/// 页面标题
@property (nonatomic, copy, nullable) NSString *pageTitle;

/// 页面跳转路径（包含前面所有页面）
@property (nonatomic, copy) NSArray<NSString *> *pagePath;

/// 页面进入时间戳
@property (nonatomic, assign) NSTimeInterval enterTime;

/// 页面退出时间戳
@property (nonatomic, assign) NSTimeInterval exitTime;

/// 页面停留时长（秒）
@property (nonatomic, assign) NSTimeInterval duration;

/// 事件唯一标识符
@property (nonatomic, copy) NSString *eventId;

/// 事件创建时间
@property (nonatomic, strong) NSDate *createdAt;

/**
 * 创建页面进入事件
 */
+ (instancetype)pageEnterEventWithScreenName:(NSString *)screenName
                                   pageTitle:(nullable NSString *)pageTitle
                                    pagePath:(NSArray<NSString *> *)pagePath;

/**
 * 更新为页面退出事件
 */
- (void)markAsPageExitWithDuration:(NSTimeInterval)duration;

/**
 * 转换为字典格式（用于上传）
 */
- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END 
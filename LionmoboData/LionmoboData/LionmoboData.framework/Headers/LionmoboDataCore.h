//
//  LionmoboDataCore.h
//  LionmoboData
//
//  Created by lionmobo on 2025/7/7.
//

#import <Foundation/Foundation.h>

@class LionmoboDataConfig;

NS_ASSUME_NONNULL_BEGIN

/**
 * LionmoboData SDK核心类
 * 提供SDK的初始化和核心功能
 */
@interface LionmoboDataCore : NSObject

/**
 * 使用配置信息启动SDK
 * @param config 配置对象，包含appID、serverURL等信息
 */
+ (void)startWithConfig:(LionmoboDataConfig *)config;

/**
 * 获取当前配置信息
 * @return 当前使用的配置对象，如果未初始化则返回nil
 */
+ (nullable LionmoboDataConfig *)currentConfig;

/**
 * 检查SDK是否已初始化
 * @return YES表示已初始化，NO表示未初始化
 */
+ (BOOL)isInitialized;

/**
 * 获取SDK单例对象
 * @return SDK单例对象
 */
+ (instancetype)sharedInstance;

/**
 * 获取SDK版本号
 * @return SDK版本号字符串
 */
+ (NSString *)sdkVersion;

@end

NS_ASSUME_NONNULL_END





//
//  LionmoboDataLogger.h
//  LionmoboData
//
//  Created by lionmobo on 2025/7/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * LionmoboData SDK日志管理类
 */
@interface LionmoboDataLogger : NSObject

/**
 * 设置日志输出是否开启
 * @param enabled YES开启，NO关闭
 */
+ (void)setLogEnabled:(BOOL)enabled;

/**
 * 检查日志是否开启
 * @return YES已开启，NO已关闭
 */
+ (BOOL)isLogEnabled;

/**
 * 输出信息级别日志
 * @param format 格式化字符串
 */
+ (void)logInfo:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

/**
 * 输出成功级别日志
 * @param format 格式化字符串
 */
+ (void)logSuccessInfo:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

/**
 * 输出警告级别日志
 * @param format 格式化字符串
 */
+ (void)logWarning:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

/**
 * 输出错误级别日志
 * @param format 格式化字符串
 */
+ (void)logError:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

/**
 * 输出调试级别日志
 * @param format 格式化字符串
 */
+ (void)logDebug:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

@end

// 便捷宏定义
#define LMBLog(format, ...) [LionmoboDataLogger logInfo:format, ##__VA_ARGS__]
#define LMBLogSuccess(format, ...) [LionmoboDataLogger logSuccessInfo:format, ##__VA_ARGS__]
#define LMBLogWarning(format, ...) [LionmoboDataLogger logWarning:format, ##__VA_ARGS__]
#define LMBLogError(format, ...) [LionmoboDataLogger logError:format, ##__VA_ARGS__]
#define LMBLogDebug(format, ...) [LionmoboDataLogger logDebug:format, ##__VA_ARGS__]

NS_ASSUME_NONNULL_END 

//
//  LionmoboDataNotificationManager.h
//  LionmoboData
//
//  Created by lionmobo on 2025/7/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class LionmoboDataConfig;

/**
 * 通知名称常量
 */
FOUNDATION_EXPORT NSString * const LionmoboDataDidInitializeNotification;
FOUNDATION_EXPORT NSString * const LionmoboDataDidFailToInitializeNotification;
FOUNDATION_EXPORT NSString * const LionmoboDataConfigDidChangeNotification;

// 崩溃监控通知
FOUNDATION_EXPORT NSString * const LionmoboDataCrashMonitoringStartedNotification;
FOUNDATION_EXPORT NSString * const LionmoboDataCrashMonitoringStoppedNotification;

// 崩溃报告通知
FOUNDATION_EXPORT NSString * const LionmoboDataCrashReportSavedNotification;
FOUNDATION_EXPORT NSString * const LionmoboDataCrashReportUploadedNotification;
FOUNDATION_EXPORT NSString * const LionmoboDataCrashReportDeletedNotification;
FOUNDATION_EXPORT NSString * const LionmoboDataAllCrashReportsUploadCompletedNotification;
FOUNDATION_EXPORT NSString * const LionmoboDataAllCrashReportsClearedNotification;

/**
 * 键名常量
 */
FOUNDATION_EXPORT NSString * const LionmoboDataNotificationConfigKey;
FOUNDATION_EXPORT NSString * const LionmoboDataNotificationErrorKey;
FOUNDATION_EXPORT NSString * const LionmoboDataNotificationTimestampKey;

// 崩溃报告相关键名
FOUNDATION_EXPORT NSString * const LionmoboDataNotificationCrashReportKey;
FOUNDATION_EXPORT NSString * const LionmoboDataNotificationSuccessCountKey;
FOUNDATION_EXPORT NSString * const LionmoboDataNotificationFailureCountKey;

/**
 * LionmoboData SDK通知管理类
 */
@interface LionmoboDataNotificationManager : NSObject

/**
 * 发送SDK初始化成功通知
 * @param config 配置对象
 */
+ (void)postInitializeSuccessNotificationWithConfig:(LionmoboDataConfig *)config;

/**
 * 发送SDK初始化失败通知
 * @param error 错误信息
 */
+ (void)postInitializeFailureNotificationWithError:(NSError *)error;

/**
 * 发送配置变更通知
 * @param config 新的配置对象
 */
+ (void)postConfigChangeNotificationWithConfig:(LionmoboDataConfig *)config;

/**
 * 注册通知监听
 * @param observer 监听者
 * @param selector 回调方法
 * @param notificationName 通知名称
 */
+ (void)addObserver:(id)observer
           selector:(SEL)selector
               name:(NSString *)notificationName;

/**
 * 移除通知监听
 * @param observer 监听者
 * @param notificationName 通知名称，传nil则移除该监听者的所有通知
 */
+ (void)removeObserver:(id)observer 
                  name:(nullable NSString *)notificationName;

// 崩溃监控通知方法
+ (void)postCrashMonitoringStarted;
+ (void)postCrashMonitoringStopped;

// 崩溃报告通知方法
+ (void)postCrashReportSaved:(id)crashReport;
+ (void)postCrashReportUploaded:(id)crashReport;
+ (void)postCrashReportDeleted:(id)crashReport;
+ (void)postAllCrashReportsUploadCompleted:(NSInteger)successCount failures:(NSInteger)failureCount;
+ (void)postAllCrashReportsCleared;

@end

NS_ASSUME_NONNULL_END 

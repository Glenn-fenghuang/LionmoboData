//
//  LionmoboDataNotificationManager.m
//  LionmoboData
//
//  Created by lionmobo on 2025/7/7.
//

#import "LionmoboDataNotificationManager.h"
#import "../Core/LionmoboDataConfig.h"
#import "../Logging/LionmoboDataLogger.h"

// 通知名称常量
NSString * const LionmoboDataDidInitializeNotification = @"LionmoboDataDidInitializeNotification";
NSString * const LionmoboDataDidFailToInitializeNotification = @"LionmoboDataDidFailToInitializeNotification";
NSString * const LionmoboDataConfigDidChangeNotification = @"LionmoboDataConfigDidChangeNotification";

// 崩溃监控通知
NSString * const LionmoboDataCrashMonitoringStartedNotification = @"LionmoboDataCrashMonitoringStartedNotification";
NSString * const LionmoboDataCrashMonitoringStoppedNotification = @"LionmoboDataCrashMonitoringStoppedNotification";

// 崩溃报告通知
NSString * const LionmoboDataCrashReportSavedNotification = @"LionmoboDataCrashReportSavedNotification";
NSString * const LionmoboDataCrashReportUploadedNotification = @"LionmoboDataCrashReportUploadedNotification";
NSString * const LionmoboDataCrashReportDeletedNotification = @"LionmoboDataCrashReportDeletedNotification";
NSString * const LionmoboDataAllCrashReportsUploadCompletedNotification = @"LionmoboDataAllCrashReportsUploadCompletedNotification";
NSString * const LionmoboDataAllCrashReportsClearedNotification = @"LionmoboDataAllCrashReportsClearedNotification";

// 通知UserInfo键名常量
NSString * const LionmoboDataNotificationConfigKey = @"config";
NSString * const LionmoboDataNotificationErrorKey = @"error";
NSString * const LionmoboDataNotificationTimestampKey = @"timestamp";

// 崩溃报告相关键名
NSString * const LionmoboDataNotificationCrashReportKey = @"crashReport";
NSString * const LionmoboDataNotificationSuccessCountKey = @"successCount";
NSString * const LionmoboDataNotificationFailureCountKey = @"failureCount";

@implementation LionmoboDataNotificationManager

#pragma mark - 公共方法

+ (void)postInitializeSuccessNotificationWithConfig:(LionmoboDataConfig *)config {
    NSParameterAssert(config);
    
    NSDictionary *userInfo = @{
        LionmoboDataNotificationConfigKey: config,
        LionmoboDataNotificationTimestampKey: @([[NSDate date] timeIntervalSince1970])
    };
    
//    LMBLogSuccess(@"发送初始化成功通知");
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LionmoboDataDidInitializeNotification
                                                            object:nil
                                                          userInfo:userInfo];
    });
}

+ (void)postInitializeFailureNotificationWithError:(NSError *)error {
    NSParameterAssert(error);
    
    NSDictionary *userInfo = @{
        LionmoboDataNotificationErrorKey: error,
        LionmoboDataNotificationTimestampKey: @([[NSDate date] timeIntervalSince1970])
    };
    
//    LMBLogError(@"发送初始化失败通知: %@", error.localizedDescription);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LionmoboDataDidFailToInitializeNotification
                                                            object:nil
                                                          userInfo:userInfo];
    });
}

+ (void)postConfigChangeNotificationWithConfig:(LionmoboDataConfig *)config {
    NSParameterAssert(config);
    
    NSDictionary *userInfo = @{
        LionmoboDataNotificationConfigKey: config,
        LionmoboDataNotificationTimestampKey: @([[NSDate date] timeIntervalSince1970])
    };
    
//    LMBLogDebug(@"发送配置变更通知");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LionmoboDataConfigDidChangeNotification
                                                            object:nil
                                                          userInfo:userInfo];
    });
}

+ (void)addObserver:(id)observer
           selector:(SEL)selector
               name:(NSString *)notificationName {
    NSParameterAssert(observer);
    NSParameterAssert(selector);
    NSParameterAssert(notificationName);
    
//    LMBLogDebug(@"添加通知监听: %@ -> %@", notificationName, NSStringFromClass([observer class]));
    
    [[NSNotificationCenter defaultCenter] addObserver:observer
                                             selector:selector
                                                 name:notificationName
                                               object:nil];
}

+ (void)removeObserver:(id)observer 
                  name:(NSString *)notificationName {
    NSParameterAssert(observer);
    
    if (notificationName) {
//        LMBLogDebug(@"移除指定通知监听: %@ -> %@", notificationName, NSStringFromClass([observer class]));
        [[NSNotificationCenter defaultCenter] removeObserver:observer
                                                         name:notificationName
                                                       object:nil];
    } else {
//        LMBLogDebug(@"移除所有通知监听: %@", NSStringFromClass([observer class]));
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
}

#pragma mark - 崩溃监控通知方法

+ (void)postCrashMonitoringStarted {
    NSDictionary *userInfo = @{
        LionmoboDataNotificationTimestampKey: @([[NSDate date] timeIntervalSince1970])
    };
    
//    LMBLogSuccess(@"发送崩溃监控开始通知");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LionmoboDataCrashMonitoringStartedNotification
                                                            object:nil
                                                          userInfo:userInfo];
    });
}

+ (void)postCrashMonitoringStopped {
    NSDictionary *userInfo = @{
        LionmoboDataNotificationTimestampKey: @([[NSDate date] timeIntervalSince1970])
    };
    
//    LMBLogDebug(@"发送崩溃监控停止通知");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LionmoboDataCrashMonitoringStoppedNotification
                                                            object:nil
                                                          userInfo:userInfo];
    });
}

#pragma mark - 崩溃报告通知方法

+ (void)postCrashReportSaved:(id)crashReport {
    NSParameterAssert(crashReport);
    
    NSDictionary *userInfo = @{
        LionmoboDataNotificationCrashReportKey: crashReport,
        LionmoboDataNotificationTimestampKey: @([[NSDate date] timeIntervalSince1970])
    };
    
//    LMBLogDebug(@"发送崩溃报告保存通知");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LionmoboDataCrashReportSavedNotification
                                                            object:nil
                                                          userInfo:userInfo];
    });
}

+ (void)postCrashReportUploaded:(id)crashReport {
    NSParameterAssert(crashReport);
    
    NSDictionary *userInfo = @{
        LionmoboDataNotificationCrashReportKey: crashReport,
        LionmoboDataNotificationTimestampKey: @([[NSDate date] timeIntervalSince1970])
    };
    
//    LMBLogDebug(@"发送崩溃报告上传成功通知");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LionmoboDataCrashReportUploadedNotification
                                                            object:nil
                                                          userInfo:userInfo];
    });
}

+ (void)postCrashReportDeleted:(id)crashReport {
    NSParameterAssert(crashReport);
    
    NSDictionary *userInfo = @{
        LionmoboDataNotificationCrashReportKey: crashReport,
        LionmoboDataNotificationTimestampKey: @([[NSDate date] timeIntervalSince1970])
    };
    
//    LMBLogDebug(@"发送崩溃报告删除通知");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LionmoboDataCrashReportDeletedNotification
                                                            object:nil
                                                          userInfo:userInfo];
    });
}

+ (void)postAllCrashReportsUploadCompleted:(NSInteger)successCount failures:(NSInteger)failureCount {
    NSDictionary *userInfo = @{
        LionmoboDataNotificationSuccessCountKey: @(successCount),
        LionmoboDataNotificationFailureCountKey: @(failureCount),
        LionmoboDataNotificationTimestampKey: @([[NSDate date] timeIntervalSince1970])
    };
    
//    LMBLogDebug(@"发送所有崩溃报告上传完成通知 - 成功: %ld, 失败: %ld", (long)successCount, (long)failureCount);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LionmoboDataAllCrashReportsUploadCompletedNotification
                                                            object:nil
                                                          userInfo:userInfo];
    });
}

+ (void)postAllCrashReportsCleared {
    NSDictionary *userInfo = @{
        LionmoboDataNotificationTimestampKey: @([[NSDate date] timeIntervalSince1970])
    };
    
//    LMBLogDebug(@"发送所有崩溃报告清除通知");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LionmoboDataAllCrashReportsClearedNotification
                                                            object:nil
                                                          userInfo:userInfo];
    });
}

@end 

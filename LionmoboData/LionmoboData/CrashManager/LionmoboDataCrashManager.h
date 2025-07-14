//
//  LionmoboDataCrashManager.h
//  LionmoboData
//
//  Created by LionmoboData on 2025/7/7.
//  Copyright © 2025 Lionmobo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LionmoboDataCrashReport;

NS_ASSUME_NONNULL_BEGIN

/**
 * 崩溃日志上传回调
 */
typedef void(^LionmoboDataCrashUploadCompletion)(BOOL success, NSError * _Nullable error);

/**
 * 崩溃日志管理器
 */
@interface LionmoboDataCrashManager : NSObject

/// 单例实例
+ (instancetype)sharedManager;

/// 是否启用崩溃收集
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

/// 服务器上传地址
@property (nonatomic, strong, nullable) NSString *uploadURL;

/// 最大保存的崩溃报告数量
@property (nonatomic, assign) NSUInteger maxCrashReports;

/**
 * 开始崩溃监控
 */
- (void)startCrashMonitoring;

/**
 * 停止崩溃监控
 */
- (void)stopCrashMonitoring;

/**
 * 获取所有保存的崩溃报告
 */
- (NSArray<LionmoboDataCrashReport *> *)getAllCrashReports;

/**
 * 获取待上传的崩溃报告
 */
- (NSArray<LionmoboDataCrashReport *> *)getPendingCrashReports;

/**
 * 上传崩溃报告
 */
- (void)uploadCrashReport:(LionmoboDataCrashReport *)crashReport
               completion:(nullable LionmoboDataCrashUploadCompletion)completion;

/**
 * 上传所有待上传的崩溃报告
 */
- (void)uploadAllPendingCrashReportsWithCompletion:(nullable void(^)(NSInteger successCount, NSInteger failureCount, NSArray<NSError *> *errors))completion;

/**
 * 删除崩溃报告
 */
- (BOOL)deleteCrashReport:(LionmoboDataCrashReport *)crashReport;

/**
 * 清理所有崩溃报告
 */
- (void)clearAllCrashReports;

/**
 * 手动保存崩溃报告（用于测试）
 */
- (void)saveCrashReport:(LionmoboDataCrashReport *)crashReport;

/**
 * 立即保存崩溃报告（信号安全版本）
 * 此方法可在信号处理函数中安全调用，避免使用队列操作
 */
- (void)saveCrashReportImmediate:(LionmoboDataCrashReport *)crashReport;

/**
 * 安全地写入异常信息到文件
 * 此方法在异常处理函数中调用，收集详细的异常信息
 */
- (void)writeExceptionInfoSafe:(NSException *)exception;



@end

NS_ASSUME_NONNULL_END 

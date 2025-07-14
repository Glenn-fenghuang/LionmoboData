//
//  LionmoboDataCrashReport.h
//  LionmoboData
//
//  Created by LionmoboData on 2025/7/7.
//  Copyright © 2025 Lionmobo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 崩溃报告数据模型
 */
@interface LionmoboDataCrashReport : NSObject <NSCoding, NSSecureCoding>

/// 崩溃原因
@property (nonatomic, strong) NSString *appCrashedReason;

/// 崩溃时间戳
@property (nonatomic, assign) NSTimeInterval crashTime;

/// 崩溃时的页面文件名称
@property (nonatomic, strong) NSString *screenName;

/// 应用版本
@property (nonatomic, strong) NSString *appVersion;

/// 系统版本
@property (nonatomic, strong) NSString *systemVersion;

/// 设备型号
@property (nonatomic, strong) NSString *deviceModel;

/// 崩溃堆栈信息
@property (nonatomic, strong) NSArray<NSString *> *callStack;

/// 报告唯一标识符
@property (nonatomic, strong) NSString *reportId;

/// 创建时间
@property (nonatomic, strong) NSDate *createdAt;

/**
 * 使用异常信息创建崩溃报告
 */
+ (instancetype)crashReportWithException:(NSException *)exception;

/**
 * 使用信号信息创建崩溃报告
 */
+ (instancetype)crashReportWithSignal:(int)signal;

/**
 * 使用信号信息创建崩溃报告（信号安全版本）
 * 此方法仅使用 async-signal-safe 函数，可在信号处理函数中安全调用
 */
+ (instancetype)crashReportWithSignalSafe:(int)signal;

/**
 * 转换为字典格式
 */
- (NSDictionary *)toDictionary;

/**
 * 从字典创建崩溃报告
 */
+ (instancetype)crashReportFromDictionary:(NSDictionary *)dictionary;

/**
 * 获取当前顶层视图控制器名称
 */
+ (NSString *)currentScreenName;

@end

NS_ASSUME_NONNULL_END 
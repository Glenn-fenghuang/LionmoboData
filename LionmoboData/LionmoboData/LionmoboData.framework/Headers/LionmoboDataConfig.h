//
//  LionmoboDataConfig.h
//  LionmoboData
//
//  Created by lionmobo on 2025/7/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * LionmoboData SDK配置类
 */
@interface LionmoboDataConfig : NSObject

/**
 * 应用密钥，用于媒体验证
 */
@property (nonatomic, copy) NSString *appID;

/**
 * 服务器API地址
 */
@property (nonatomic, copy) NSString *serverURL;

/**
 * 是否启用调试模式，默认为NO
 * 调试模式开启时会输出所有日志信息和崩溃报告
 */
@property (nonatomic, assign) BOOL debugMode;

/**
 * 网络请求超时时间，默认为30秒
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 * 是否启用崩溃报告，默认为NO
 */
@property (nonatomic, assign) BOOL crashReportingEnabled;

/**
 * 是否启用网络日志，默认为NO
 */
@property (nonatomic, assign) BOOL networkLoggingEnabled;

/**
 * 是否启用页面追踪，默认为NO
 */
@property (nonatomic, assign) BOOL pageTrackingEnabled;

/**
 * 是否启用点击追踪，默认为NO
 */
@property (nonatomic, assign) BOOL clickTrackingEnabled;

/**
 * 是否启用启动监控，默认为NO
 */
@property (nonatomic, assign) BOOL launchTrackingEnabled;

/**
 * 页面路径追踪模式，默认为完整历史模式
 * 0: 完整历史模式 - 记录所有访问的页面
 * 1: 导航栈模式 - 基于导航栈状态维护路径
 */
@property (nonatomic, assign) NSInteger pagePathTrackingMode;

/**
 * 热启动判断超时时间（秒），默认为30秒
 * 后台时间超过此值将被判定为冷启动
 */
@property (nonatomic, assign) NSTimeInterval hotStartTimeoutInterval;

@end

NS_ASSUME_NONNULL_END 

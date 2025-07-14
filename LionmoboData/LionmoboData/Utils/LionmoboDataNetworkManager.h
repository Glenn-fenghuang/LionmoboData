//
//  LionmoboDataNetworkManager.h
//  LionmoboData
//
//  Created by lionmobo on 2025/7/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// HTTP请求方法枚举
typedef NS_ENUM(NSInteger, LionmoboHTTPMethod) {
    LionmoboHTTPMethodGET = 0,
    LionmoboHTTPMethodPOST,
    LionmoboHTTPMethodPUT,
    LionmoboHTTPMethodDELETE
};

// 网络请求成功回调
typedef void(^LionmoboNetworkSuccessBlock)(NSData * _Nullable data, NSDictionary * _Nullable responseObject);

// 网络请求失败回调
typedef void(^LionmoboNetworkFailureBlock)(NSError * _Nonnull error, NSInteger statusCode);

@interface LionmoboDataNetworkManager : NSObject

/// 获取共享实例
+ (instancetype)sharedManager;

/// 设置是否启用日志打印
/// @param enabled 是否启用日志
+ (void)setLogEnabled:(BOOL)enabled;

/// 发起网络请求
/// @param urlString 请求URL字符串
/// @param method HTTP请求方法
/// @param parameters 请求参数（支持字典、数组等各种类型）
/// @param headers 请求头（可选）
/// @param success 成功回调
/// @param failure 失败回调
- (void)requestWithURL:(NSString *)urlString
                method:(LionmoboHTTPMethod)method
            parameters:(NSDictionary * _Nullable)parameters
               headers:(NSDictionary * _Nullable)headers
               success:(LionmoboNetworkSuccessBlock _Nullable)success
               failure:(LionmoboNetworkFailureBlock _Nullable)failure;

/// 取消所有请求
- (void)cancelAllRequests;

/// 获取当前网络状态
- (BOOL)isNetworkAvailable;

/// 获取待发送请求队列大小
- (NSUInteger)pendingRequestsCount;

/// 清空待发送请求队列
- (void)clearPendingRequests;

/// 设置待发送请求超时时间（秒，默认300秒）
- (void)setPendingRequestTimeout:(NSTimeInterval)timeout;

@end

NS_ASSUME_NONNULL_END

//
//  LionmoboDataNetworkManager.m
//  LionmoboData
//
//  Created by lionmobo on 2025/7/14.
//

#import "LionmoboDataNetworkManager.h"
#import <CommonCrypto/CommonDigest.h>
#import "../Logging/LionmoboDataLogger.h"
#import "../Core/LionmoboDataConfig.h"
#import "../Core/LionmoboDataCore.h"
#import "../Utils/LionmoboDataTools.h"
#import "../Utils/DeviceInfo.h"
// 日志控制静态变量
static BOOL lionmoboLogEnabled = NO;

@interface LionmoboDataNetworkManager ()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableSet<NSURLSessionDataTask *> *activeTasks;
@property (nonatomic, strong) dispatch_queue_t requestQueue;

@end

@implementation LionmoboDataNetworkManager

#pragma mark - 单例模式

+ (instancetype)sharedManager {
    static LionmoboDataNetworkManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 创建URL会话配置
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = [LionmoboDataCore currentConfig].timeoutInterval;
        config.timeoutIntervalForResource = 60.0;
        
        // 创建URL会话
        self.session = [NSURLSession sessionWithConfiguration:config];
        
        // 创建活跃任务集合（线程安全）
        self.activeTasks = [NSMutableSet set];
        
        // 创建请求队列
        self.requestQueue = dispatch_queue_create("com.lionmobo.network.queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

#pragma mark - 公共方法

+ (void)setLogEnabled:(BOOL)enabled {
    lionmoboLogEnabled = enabled;
}

- (void)requestWithURL:(NSString *)urlString
                method:(LionmoboHTTPMethod)method
            parameters:(NSDictionary *)parameters
               headers:(NSDictionary *)headers
               success:(LionmoboNetworkSuccessBlock)success
               failure:(LionmoboNetworkFailureBlock)failure {
    
    // 参数验证
    if (!urlString || urlString.length == 0) {
        [self logMessage:@"LionmoboNetwork: URL不能为空"];
        if (failure) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = [NSError errorWithDomain:@"LionmoboNetworkError"
                                                     code:-1001
                                                 userInfo:@{NSLocalizedDescriptionKey: @"URL不能为空"}];
                failure(error, -1001);
            });
        }
        return;
    }
    
    // 在后台队列执行网络请求
    dispatch_async(self.requestQueue, ^{
        [self performRequestWithURL:urlString
                             method:method
                         parameters:parameters
                            headers:headers
                            success:success
                            failure:failure];
    });
}

- (void)cancelAllRequests {
    @synchronized (self.activeTasks) {
        [self logMessage:[NSString stringWithFormat:@"LionmoboNetwork: 取消 %lu 个活跃请求", (unsigned long)self.activeTasks.count]];
        for (NSURLSessionDataTask *task in self.activeTasks) {
            [task cancel];
        }
        [self.activeTasks removeAllObjects];
    }
}

#pragma mark - 私有方法

- (void)performRequestWithURL:(NSString *)urlString
                       method:(LionmoboHTTPMethod)method
                   parameters:(NSDictionary *)parameters
                      headers:(NSDictionary *)headers
                      success:(LionmoboNetworkSuccessBlock)success
                      failure:(LionmoboNetworkFailureBlock)failure {
    
    // 创建URL
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[LionmoboDataCore currentConfig].serverURL,urlString]];
    if (!url) {
        [self logMessage:[NSString stringWithFormat:@"LionmoboNetwork: 无效的URL: %@", urlString]];
        if (failure) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = [NSError errorWithDomain:@"LionmoboNetworkError"
                                                     code:-1002
                                                 userInfo:@{NSLocalizedDescriptionKey: @"无效的URL"}];
                failure(error, -1002);
            });
        }
        return;
    }
    
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = [self httpMethodString:method];
    
    // 设置默认请求头
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // 设置自定义请求头
    if (headers && headers.count > 0) {
        for (NSString *key in headers.allKeys) {
            [request setValue:headers[key] forHTTPHeaderField:key];
        }
    }
    
    // 生成特有body参数
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [mutableParams setValue:[LionmoboDataTools requireID] forKey:@"requireId"];
    [mutableParams setValue:[NSNumber numberWithLongLong:[LionmoboDataTools timestamp]] forKey:@"timestamp"];
    [mutableParams setValue:[LionmoboDataCore currentConfig].appID forKey:@"appId"];
    [mutableParams setValue:[LionmoboDataCore currentConfig].apiKey forKey:@"apiKey"];
    [mutableParams setValue:@"2.0" forKey:@"version"];
    [mutableParams setValue:[LionmoboDataTools deviceID] forKey:@"deviceId"];
    [mutableParams setValue:[NSNumber numberWithInteger:[LionmoboDataTools IDType]] forKey:@"idType"];
    // 生成签名
    NSString *sign = [self generateSignatureWithParameters:mutableParams apiSecret:[LionmoboDataCore currentConfig].apiSecret];
    [mutableParams setValue:sign forKey:@"sign"];
    
    
    // 处理请求参数
    if (parameters && parameters.count > 0) {
        if (method == LionmoboHTTPMethodGET) {
            // GET请求将参数拼接到URL
            NSString *queryString = [self buildQueryStringFromParameters:mutableParams];
            if (queryString.length > 0) {
                NSString *fullURLString = [NSString stringWithFormat:@"%@%@%@",
                                         urlString,
                                         [urlString containsString:@"?"] ? @"&" : @"?",
                                         queryString];
                url = [NSURL URLWithString:fullURLString];
                request.URL = url;
            }
        } else {
            // POST/PUT/DELETE请求将参数放在请求体
            NSError *jsonError;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutableParams
                                                             options:0
                                                               error:&jsonError];
            if (jsonError) {
                [self logMessage:[NSString stringWithFormat:@"LionmoboNetwork: 参数序列化失败: %@", jsonError.localizedDescription]];
                if (failure) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        failure(jsonError, -1003);
                    });
                }
                return;
            }
            request.HTTPBody = jsonData;
        }
    }
    
    [self logMessage:[NSString stringWithFormat:@"LionmoboNetwork: %@ %@", request.HTTPMethod, url.absoluteString]];
    if (parameters && parameters.count > 0) {
        [self logMessage:[NSString stringWithFormat:@"LionmoboNetwork: 请求参数: %@", mutableParams]];
    }
    
    // 创建数据任务
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                                  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // 从活跃任务集合中移除
        @synchronized (self.activeTasks) {
            [self.activeTasks removeObject:[NSURLSessionDataTask new]];
        }
        
        // 处理响应
        [self handleResponse:response data:data error:error success:success failure:failure];
    }];
    
    // 添加到活跃任务集合
    @synchronized (self.activeTasks) {
        [self.activeTasks addObject:task];
    }
    
    // 开始请求
    [task resume];
}

- (void)handleResponse:(NSURLResponse *)response
                  data:(NSData *)data
                 error:(NSError *)error
               success:(LionmoboNetworkSuccessBlock)success
               failure:(LionmoboNetworkFailureBlock)failure {
    
    // 检查网络错误
    if (error) {
        [self logMessage:[NSString stringWithFormat:@"LionmoboNetwork: 网络错误: %@", error.localizedDescription]];
        if (failure) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error, error.code);
            });
        }
        return;
    }
    
    // 检查HTTP响应
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = httpResponse.statusCode;
    
    [self logMessage:[NSString stringWithFormat:@"LionmoboNetwork: 响应状态码: %ld", (long)statusCode]];
    
    // 检查状态码
    if (statusCode < 200 || statusCode >= 300) {
        NSString *errorMessage = [NSString stringWithFormat:@"HTTP错误，状态码: %ld", (long)statusCode];
        [self logMessage:[NSString stringWithFormat:@"LionmoboNetwork: %@", errorMessage]];
        
        if (failure) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *httpError = [NSError errorWithDomain:@"LionmoboNetworkError"
                                                         code:statusCode
                                                     userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
                failure(httpError, statusCode);
            });
        }
        return;
    }
    
    // 解析响应数据
    NSDictionary *responseObject = nil;
    if (data && data.length > 0) {
        NSError *jsonError;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (jsonError) {
            [self logMessage:[NSString stringWithFormat:@"LionmoboNetwork: JSON解析失败: %@", jsonError.localizedDescription]];
            // JSON解析失败不算错误，返回原始数据
        } else if ([jsonObject isKindOfClass:[NSDictionary class]]) {
            responseObject = (NSDictionary *)jsonObject;
        }
        
        [self logMessage:[NSString stringWithFormat:@"LionmoboNetwork: 响应数据: %@", responseObject ?: @"非JSON格式数据"]];
    }
    
    // 成功回调
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            success(data, responseObject);
        });
    }
}

- (NSString *)httpMethodString:(LionmoboHTTPMethod)method {
    switch (method) {
        case LionmoboHTTPMethodGET:
            return @"GET";
        case LionmoboHTTPMethodPOST:
            return @"POST";
        case LionmoboHTTPMethodPUT:
            return @"PUT";
        case LionmoboHTTPMethodDELETE:
            return @"DELETE";
        default:
            return @"GET";
    }
}

- (NSString *)buildQueryStringFromParameters:(NSDictionary *)parameters {
    NSMutableArray *queryItems = [NSMutableArray array];
    
    for (NSString *key in parameters.allKeys) {
        id value = parameters[key];
        NSString *stringValue = [self stringFromParameterValue:value];
        if (stringValue) {
            NSString *encodedKey = [self urlEncode:key];
            NSString *encodedValue = [self urlEncode:stringValue];
            [queryItems addObject:[NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue]];
        }
    }
    
    return [queryItems componentsJoinedByString:@"&"];
}

- (NSString *)stringFromParameterValue:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        return (NSString *)value;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)value stringValue];
    } else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
        // 对于数组和字典，转换为JSON字符串
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value options:0 error:&error];
        if (!error && jsonData) {
            return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }
    return [value description];
}

- (NSString *)urlEncode:(NSString *)string {
    NSCharacterSet *allowedCharacters = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"];
    return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
}

- (void)logMessage:(NSString *)message {
    if (lionmoboLogEnabled) {
        LMBLogDebug(@"%@", message);
    }
}

- (NSString *)generateSignatureWithParameters:(NSDictionary *)parameters apiSecret:(NSString *)apiSecret {
    NSMutableDictionary *signParams = [parameters mutableCopy];
    
    // 移除不参与签名的参数
    [signParams removeObjectForKey:@"details"]; // details参数不参与签名
    [signParams removeObjectForKey:@"detail"]; // details参数不参与签名
    [signParams removeObjectForKey:@"sign"];   // sign本身不参与签名
    // 获取所有键并排序
    NSArray *sortedKeys = [[signParams allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    // 构建签名字符串
    NSMutableArray *paramArray = [NSMutableArray array];
    for (NSString *key in sortedKeys) {
        id value = signParams[key];
        NSString *valueString;
        
        // 处理不同类型的值
        if ([value isKindOfClass:[NSString class]]) {
            valueString = value;
        } else if ([value isKindOfClass:[NSNumber class]]) {
            valueString = [value stringValue];
        } else {
            // 对于复杂对象，使用JSON字符串
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value options:0 error:&error];
            if (!error && jsonData) {
                valueString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            } else {
                valueString = [value description];
            }
        }
        
        [paramArray addObject:[NSString stringWithFormat:@"%@=%@", key, valueString ?: @""]];
    }
    
    // 连接参数并追加apiSecret
    NSString *paramString = [paramArray componentsJoinedByString:@"&"];
    NSString *signString = [NSString stringWithFormat:@"%@%@", paramString, apiSecret];
    
    // 生成MD5签名
    NSString *md5Sign = [self md5String:signString];
    
    LMBLogDebug(@"[NetworkManager] 签名字符串: %@", signString);
    LMBLogDebug(@"[NetworkManager] MD5签名: %@", md5Sign);
    
    return md5Sign;
}

- (NSString *)md5String:(NSString *)string {
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return [result copy];
}

@end

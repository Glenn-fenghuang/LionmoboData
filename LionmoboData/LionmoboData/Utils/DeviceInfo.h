//
//  DeviceInfo.h
//  LionmoboData
//
//  Created by lionmobo on 2025/7/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceInfo : NSObject

/// 应用名称
@property (nonatomic, copy) NSString *name;
/// 应用包名
@property (nonatomic, copy) NSString *bundle;
/// 应用版本号
@property (nonatomic, copy) NSString *appVersion;
/// 设备类型
@property (nonatomic, assign) NSInteger deviceType;
/// 系统类型
@property (nonatomic, assign) NSInteger osType;
/// 系统版本号
@property (nonatomic, copy) NSString *osVersion;
/// 设备 idfa
/// *需要开启用户追踪授权*
@property (nonatomic, copy) NSString *idfa;
/// 设备 idfv
@property (nonatomic, copy) NSString *idfv;
/// 设备型号
@property (nonatomic, copy) NSString *model;
/// 品牌
@property (nonatomic, copy) NSString *brand;
/// 生产厂商
@property (nonatomic, copy) NSString *make;
/// 屏幕方向
@property (nonatomic, assign) NSInteger screenType;
/// 电量
@property (nonatomic, assign) NSInteger battery;
/// 屏幕宽度
@property (nonatomic, assign) CGFloat screenWidth;
/// 屏幕高度
@property (nonatomic, assign) CGFloat screenHeight;
/// 用户 id
@property (nonatomic, copy) NSString *user_id;
/// ua
@property (nonatomic, copy) NSString *ua;


/**
 * 转换为字典格式，用于网络传输
 * @return 包含所有事件数据的字典
 */
- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END

//
//  LionmoboDataTools.h
//  LionmoboData
//
//  Created by lionmobo on 2025/7/14.
//

#import <Foundation/Foundation.h>
@class DeviceInfo;
NS_ASSUME_NONNULL_BEGIN

@interface LionmoboDataTools : NSObject


/*! @brief 判断字符串是否为空
 *
 * @param str 需要判断的字符串 @"",nil
 */
+ (BOOL)isEmptyOrNull:(NSString *)str;
/*! @brief 随机生成请求id
 */
+ (NSString *) requireID;
/*! @brief 生成当前时间戳
 */
+ (long long) timestamp;
/*! @brief 生成设备唯一ID
 */
+ (NSString *) deviceID;
/*! @brief 当前设备唯一ID类型
 */
+ (NSInteger) IDType;
/*! @brief 当前设备详细信息
 */
+ (DeviceInfo *) detail;

/*! @brief 当前事件详情详细信息
 *
 * @return 封装后事件详情
 */
+ (NSMutableDictionary *) eventDetail:(NSMutableDictionary *)dicInfo;


/*! @brief 将模型对象转为 JSON 字符串
 *
 * @return 返回 字符串 json
 */
+ (NSString *)convertModelToJSONString:(id)model;

/*! @brief 将模型对象转为 object
 *
 * @return 返回 DicInfo
 */
+ (NSDictionary *)convertModelToDicInfo:(id)model;

/*! @brief 生成标准的iOS User-Agent字符串
 *
 * @return 返回构造的User-Agent字符串
 */
+ (NSString *)generateUserAgent;

@end

NS_ASSUME_NONNULL_END

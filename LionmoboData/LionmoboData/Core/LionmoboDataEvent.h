//
//  LionmoboDataEvent.h
//  LionmoboData
//
//  Created by lionmobo on 2025/7/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LionmoboDataEvent : NSObject



/**
 * 转换为字典格式，用于网络传输
 * @return 包含所有事件数据的字典
 */
- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END

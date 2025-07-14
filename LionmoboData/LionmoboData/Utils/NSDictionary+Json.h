//
//  NSDictionary+Json.h
//  LionmoboData
//
//  Created by lionmobo on 2025/7/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (Json)

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

- (NSString *)toJson;

@end

NS_ASSUME_NONNULL_END

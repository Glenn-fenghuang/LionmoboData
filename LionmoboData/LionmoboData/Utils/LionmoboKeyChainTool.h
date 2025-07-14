//
//  LionmoboKeyChainTool.h
//  LionmoboData
//
//  Created by lionmobo on 2025/7/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LionmoboKeyChainTool : NSObject

+ (void)save:(NSString *)service data:(id)data;

+ (id)load:(NSString *)service;

+ (void)deleteKeyData:(NSString *)service;


+ (void)keyChainSave:(NSString *)service data:(id)data;

+ (id)keyChainLoad:(NSString *)service;

+ (void)keyChainDeleteKeyData:(NSString *)service;


@end

NS_ASSUME_NONNULL_END

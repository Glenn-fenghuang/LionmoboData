//
//  NSObject+AutoDictionary.m
//  LionmoboData
//
//  Created by lionmobo on 2025/7/14.
//

#import "NSObject+AutoDictionary.h"
#import <objc/runtime.h>
@implementation NSObject (AutoDictionary)

- (NSDictionary *)autoToDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    Class cls = [self class];

    while (cls && cls != [NSObject class]) {
        unsigned int count;
        objc_property_t *properties = class_copyPropertyList(cls, &count);
        
        for (unsigned int i = 0; i < count; i++) {
            const char *propName = property_getName(properties[i]);
            if (propName) {
                NSString *key = [NSString stringWithUTF8String:propName];
                id value = [self valueForKey:key];
                if (value) {
                    dict[key] = value;
                } else {
                    dict[key] = [NSNull null];
                }
            }
        }

        free(properties);
        cls = class_getSuperclass(cls); // 继续遍历父类
    }

    return [dict copy];
}

@end

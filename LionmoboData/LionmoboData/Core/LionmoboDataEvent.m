//
//  LionmoboDataEvent.m
//  LionmoboData
//
//  Created by lionmobo on 2025/7/14.
//

#import "LionmoboDataEvent.h"
#import "NSObject+AutoDictionary.h"
#import "LionmoboDataTools.h"
#import "DeviceInfo.h"
@implementation LionmoboDataEvent



- (NSDictionary *)toDictionary {

    return [self autoToDictionary];
}

@end

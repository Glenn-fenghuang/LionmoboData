//
//  LionmoboDataAppLaunchEvent.m
//  LionmoboData
//
//  Created by LionmoboData SDK on 2025/1/9.
//  Copyright © 2025 LionmoboData. All rights reserved.
//

#import "LionmoboDataAppLaunchEvent.h"
#import "LionmoboDataTools.h"
#import "../Utils/DeviceInfo.h"
@implementation LionmoboDataAppLaunchEvent

+ (instancetype)launchEvent {
    LionmoboDataAppLaunchEvent *event = [[self alloc] init];
    // 基础信息
    event.eventName = @"Applaunch";
    event.timestamp = [LionmoboDataTools timestamp];
    event.user_id = [LionmoboDataTools detail].user_id;
    return event;
}
+ (instancetype)terminateEvent {
    LionmoboDataAppLaunchEvent *event = [[self alloc] init];
    event.eventName = @"AppExit";
    event.timestamp = [LionmoboDataTools timestamp];
    event.user_id = [LionmoboDataTools detail].user_id;
    return event;
}


@end 

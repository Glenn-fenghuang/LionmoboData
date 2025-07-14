//
//  LionmoboDataPageEvent.m
//  LionmoboData
//
//  Created by lionmobo on 2025/7/7.
//

#import "LionmoboDataPageEvent.h"
#import <UIKit/UIKit.h>

@implementation LionmoboDataPageEvent

+ (instancetype)pageEnterEventWithScreenName:(NSString *)screenName
                                   pageTitle:(NSString *)pageTitle
                                    pagePath:(NSArray<NSString *> *)pagePath {
    LionmoboDataPageEvent *event = [[self alloc] init];
    event.screenName = screenName;
    event.pageTitle = pageTitle;
    event.pagePath = pagePath;
    event.enterTime = [[NSDate date] timeIntervalSince1970];
    event.exitTime = 0;
    event.duration = 0;
    event.eventId = [[NSUUID UUID] UUIDString];
    event.createdAt = [NSDate date];
    return event;
}

- (void)markAsPageExitWithDuration:(NSTimeInterval)duration {
    self.exitTime = [[NSDate date] timeIntervalSince1970];
    self.duration = duration;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    // 基础信息
    dict[@"event_id"] = self.eventId;
    dict[@"screen_name"] = self.screenName ?: @"";
    dict[@"page_title"] = self.pageTitle ?: @"";
    dict[@"page_path"] = self.pagePath ?: @[];
    
    // 时间信息
    dict[@"enter_time"] = @(self.enterTime);
    dict[@"exit_time"] = @(self.exitTime);
    dict[@"duration"] = @(self.duration);
    dict[@"created_at"] = @([self.createdAt timeIntervalSince1970]);
    
    // 设备和应用信息
    dict[@"app_version"] = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"Unknown";
    dict[@"system_version"] = [[UIDevice currentDevice] systemVersion] ?: @"Unknown";
    
    // 页面路径字符串（便于分析）
    dict[@"page_path_string"] = [self.pagePath componentsJoinedByString:@" > "];
    
    return [dict copy];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<LionmoboDataPageEvent: screen=%@, title=%@, duration=%.2fs>", 
            self.screenName, self.pageTitle, self.duration];
}

@end 
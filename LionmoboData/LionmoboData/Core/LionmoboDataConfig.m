//
//  LionmoboDataConfig.m
//  LionmoboData
//
//  Created by lionmobo on 2025/7/7.
//

#import "LionmoboDataConfig.h"

@implementation LionmoboDataConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        // 设置默认值
        _debugMode = NO;
        _crashReportingEnabled = NO;
        _networkLoggingEnabled = NO;
        _timeoutInterval = 30.0;
        _pageTrackingEnabled = NO;
        _clickTrackingEnabled = NO;
        _launchTrackingEnabled = YES;
        _pagePathTrackingMode = 0; // 默认使用完整历史模式
        _hotStartTimeoutInterval = 30.0; // 默认30秒热启动超时
        _serverURL = @"http://biapi.ssp.lionmobo.com";
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"LionmoboDataConfig: {appID: %@, serverURL: %@, debugMode: %@, timeoutInterval: %.1f}", 
            self.appID, 
            self.serverURL, 
            self.debugMode ? @"YES" : @"NO",
            self.timeoutInterval];
}

@end 

//
//  LionmoboDataLogger.m
//  LionmoboData
//
//  Created by lionmobo on 2025/7/7.
//

#import "LionmoboDataLogger.h"

static BOOL _logEnabled = NO;

@implementation LionmoboDataLogger

#pragma mark - 公共方法

+ (void)setLogEnabled:(BOOL)enabled {
    _logEnabled = enabled;
}

+ (BOOL)isLogEnabled {
    return _logEnabled;
}

+ (void)logInfo:(NSString *)format, ... {
    if (!_logEnabled) return;
    
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSLog(@"[LionmoboData] %@", message);
}


+ (void)logSuccessInfo:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2)
{
    if (!_logEnabled) return;
    
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSLog(@"[LionmoboData] ✅ %@", message);
}

+ (void)logWarning:(NSString *)format, ... {
    if (!_logEnabled) return;
    
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSLog(@"[LionmoboData] ⚠️ %@", message);
}

+ (void)logError:(NSString *)format, ... {
    if (!_logEnabled) return;
    
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSLog(@"[LionmoboData] ❌ %@", message);
}

+ (void)logDebug:(NSString *)format, ... {
    if (!_logEnabled) return;
    
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSLog(@"[LionmoboData] 🐛 %@", message);
}

@end 

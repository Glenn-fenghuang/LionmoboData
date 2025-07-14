//
//  LionmoboData.h
//  LionmoboData
//
//  Created by lionmobo on 2025/7/7.
//

#import <Foundation/Foundation.h>

//! Project version number for LionmoboData.
FOUNDATION_EXPORT double LionmoboDataVersionNumber;

//! Project version string for LionmoboData.
FOUNDATION_EXPORT const unsigned char LionmoboDataVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <LionmoboData/PublicHeader.h>
#define LionmoboSDKVersion @"1.0.0"
// 核心模块
#import <LionmoboData/LionmoboDataCore.h>
#import <LionmoboData/LionmoboDataConfig.h>
// 日志系统
#import <LionmoboData/LionmoboDataLogger.h>
// 通知管理
#import <LionmoboData/LionmoboDataNotificationManager.h>





// Convenience alias for the main SDK class
typedef LionmoboDataCore LionmoboData;





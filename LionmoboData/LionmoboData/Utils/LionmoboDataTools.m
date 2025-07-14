//
//  LionmoboDataTools.m
//  LionmoboData
//
//  Created by lionmobo on 2025/7/14.
//

#import "LionmoboDataTools.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <sys/utsname.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/ASIdentifierManager.h>
#import "LionmoboKeyChainTool.h"
#import "DeviceInfo.h"


static NSString *lionmobo_deviceID = @"00000-00000-00000-00000";
static NSInteger lionmobo_idType = 12;
@implementation LionmoboDataTools

+ (BOOL)isEmptyOrNull:(NSString *)str
{
    if (![str isKindOfClass:[NSString class]]) {
        return TRUE;
    }else if (str==nil) {
        return TRUE;
    }else if(!str) {
        return TRUE;
    } else if(str==NULL) {
        return TRUE;
    } else if([str isEqualToString:@"NULL"]) {
        return TRUE;
    }else if([str isEqualToString:@"(null)"]){
        return TRUE;
    }else if([str isEqualToString:@"<null>"]){
        return TRUE;
    }else{
        NSString *trimedString = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([trimedString length] == 0) {
            return TRUE;
        } else {
            return FALSE;
        }
    }
}

+ (NSString *) requireID
{
    NSMutableString *randomString = [NSMutableString stringWithCapacity:32];
    for (int i = 0; i < 32; i++) {
        int randomType = arc4random_uniform(3); // 0: 大写字母, 1: 小写字母, 2: 数字
        char character;
        switch (randomType) {
            case 0:
                character = (char)('A' + arc4random_uniform(26)); // 大写字母
                break;
            case 1:
                character = (char)('a' + arc4random_uniform(26)); // 小写字母
                break;
            case 2:
                character = (char)('0' + arc4random_uniform(10)); // 数字
                break;
        }
        [randomString appendFormat:@"%c", character];
    }
    return randomString;
}
+ (long long) timestamp
{
    
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    long long timestampMs = (long long)(timestamp * 1000);
    return timestampMs;
}

+ (NSString *) deviceID
{
    __block NSString *deviceID = @"00000-00000-00000-00000";
    __block NSString *IDFA = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    deviceID = [self getUUID];
    [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
        if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
            IDFA = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
        } else {
            NSLog(@"当前设备未开启追踪服务授权");
        }
        // 释放信号量
        dispatch_semaphore_signal(semaphore);
    }];
    // 等待信号量
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if(![self isEmptyOrNull:IDFA]){
        deviceID = IDFA;
        lionmobo_idType = 1;
    }
    lionmobo_deviceID = deviceID;
    return deviceID;
}


+ (NSInteger)IDType{
    return lionmobo_idType;
}


+ (DeviceInfo *)detail{
    DeviceInfo *info = [[DeviceInfo alloc] init];
    //名称
    NSString *app_Name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    //包名
    NSString *bundle_Name = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey];
    //版本号
    NSString *versionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    //idfv
    NSString *idfv = [self getUUID];
    NSString *deivceID = [self deviceID];
    //当前电量
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    double deviceLevel = [UIDevice currentDevice].batteryLevel;
    //获取屏幕宽高
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGFloat screenScale = [mainScreen scale]; // 获取屏幕的缩放比例
    CGRect screenBounds = [mainScreen nativeBounds]; // 获取真实分辨率，以点为单位
    // 将真实分辨率转换为像素
    CGFloat screenWidthInPixels = CGRectGetWidth(screenBounds) * screenScale;
    CGFloat screenHeightInPixels = CGRectGetHeight(screenBounds) * screenScale;
    // 用户 id
    NSString *user_id = (NSString *)[LionmoboKeyChainTool load:@"lionmobo_userID"];
    // 构造标准的iOS User-Agent字符串
    NSString *ua = [self generateUserAgent];
    info.name = app_Name;
    info.bundle = bundle_Name;
    info.appVersion = versionStr;
    info.deviceType = 1;
    info.osType = 2;
    info.osVersion = [[UIDevice currentDevice] systemVersion];
    info.idfa = (lionmobo_idType == 1) ? lionmobo_deviceID : @"";
    info.idfv = idfv;
    info.model = [self getCurrentDeviceModel];
    info.brand = @"iPhone";
    info.make = @"Apple";
    info.screenType = 1;
    info.battery = deviceLevel*100;
    info.screenWidth = screenWidthInPixels;
    info.screenHeight = screenHeightInPixels;
    info.user_id = user_id ?:@"";
    info.ua = ua;
    return info;
}


+ (NSMutableDictionary *) eventDetail:(NSMutableDictionary *)dicInfo
{
    DeviceInfo *info  = [self detail];
    NSMutableDictionary *detailDicInfo = [NSMutableDictionary dictionaryWithDictionary:dicInfo];
    [detailDicInfo setValue:info.idfv forKey:@"idfv"];
    if (![self isEmptyOrNull:info.idfa]) {
        [detailDicInfo setValue:info.idfa forKey:@"idfa"];
    }
    [detailDicInfo setValue:[NSNumber numberWithInteger:2] forKey:@"osType"];
    return detailDicInfo;
}


+ (NSString *)getUUID
{
    NSString *UUID = @"";
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        // 获取vendor标识符
        NSUUID *vendorID = [[UIDevice currentDevice] identifierForVendor];
        UUID = [vendorID UUIDString];
    } else {
        UUID = (NSString *)[LionmoboKeyChainTool keyChainLoad:@"lionmobo_idfv"];
        if ([UUID isEqualToString:@""] || !UUID) {
            UUID = [UIDevice currentDevice].identifierForVendor.UUIDString;
            [LionmoboKeyChainTool keyChainSave:@"lionmobo_idfv" data:UUID];
        }
    }
    return UUID;
}
 
+ (NSString *)getCurrentDeviceModel{
    struct utsname systemInfo;
    uname(&systemInfo);
   
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    if ([deviceModel isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceModel isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceModel isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceModel isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceModel isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceModel isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceModel isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceModel isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceModel isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([deviceModel isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceModel isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([deviceModel isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([deviceModel isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([deviceModel isEqualToString:@"iPhone10,1"])   return @"iPhone_8";
    if ([deviceModel isEqualToString:@"iPhone10,4"])   return @"iPhone_8";
    if ([deviceModel isEqualToString:@"iPhone10,2"])   return @"iPhone_8_Plus";
    if ([deviceModel isEqualToString:@"iPhone10,5"])   return @"iPhone_8_Plus";
    if ([deviceModel isEqualToString:@"iPhone10,3"])   return @"iPhone X";
    if ([deviceModel isEqualToString:@"iPhone10,6"])   return @"iPhone X";
    if ([deviceModel isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    if ([deviceModel isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([deviceModel isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([deviceModel isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
    if ([deviceModel isEqualToString:@"iPhone12,1"])   return @"iPhone 11";
    if ([deviceModel isEqualToString:@"iPhone12,3"])   return @"iPhone 11 Pro";
    if ([deviceModel isEqualToString:@"iPhone12,5"])   return @"iPhone 11 Pro Max";
    if ([deviceModel isEqualToString:@"iPhone12,8"])   return @"iPhone SE2";
    if ([deviceModel isEqualToString:@"iPhone13,1"])   return @"iPhone 12 mini";
    if ([deviceModel isEqualToString:@"iPhone13,2"])   return @"iPhone 12";
    if ([deviceModel isEqualToString:@"iPhone13,3"])   return @"iPhone 12 Pro";
    if ([deviceModel isEqualToString:@"iPhone13,4"])   return @"iPhone 12 Pro Max";
    if ([deviceModel isEqualToString:@"iPhone14,4"])   return @"iPhone 13 mini";
    if ([deviceModel isEqualToString:@"iPhone14,5"])   return @"iPhone 13";
    if ([deviceModel isEqualToString:@"iPhone14,2"])   return @"iPhone 13 Pro";
    if ([deviceModel isEqualToString:@"iPhone14,3"])   return @"iPhone 13 Pro Max";
    if ([deviceModel isEqualToString:@"iPhone14,7"])   return @"iPhone 14";
    if ([deviceModel isEqualToString:@"iPhone14,8"])   return @"iPhone 14 Plus";
    if ([deviceModel isEqualToString:@"iPhone15,2"])   return @"iPhone 14 Pro";
    if ([deviceModel isEqualToString:@"iPhone15,3"])   return @"iPhone 14 Pro Max";
    if ([deviceModel isEqualToString:@"iPhone15,4"])   return @"iPhone 15";
    if ([deviceModel isEqualToString:@"iPhone15,5"])   return @"iPhone 15 Plus";
    if ([deviceModel isEqualToString:@"iPhone16,1"])   return @"iPhone 15 Pro";
    if ([deviceModel isEqualToString:@"iPhone16,2"])   return @"iPhone 15 Pro Max";
    if ([deviceModel isEqualToString:@"iPhone17,3"])   return @"iPhone 16";
    if ([deviceModel isEqualToString:@"iPhone17,4"])   return @"iPhone 16 Plus";
    if ([deviceModel isEqualToString:@"iPhone17,1"])   return @"iPhone 16 Pro";
    if ([deviceModel isEqualToString:@"iPhone17,2"])   return @"iPhone 16 Pro Max";
    if ([deviceModel isEqualToString:@"iPhone17,5"])   return @"iPhone 16e";
    if ([deviceModel isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceModel isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceModel isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceModel isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceModel isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    if ([deviceModel isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceModel isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceModel isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceModel isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceModel isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceModel isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceModel isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceModel isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceModel isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceModel isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceModel isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceModel isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceModel isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceModel isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceModel isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceModel isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceModel isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";

    if ([deviceModel isEqualToString:@"AppleTV2,1"])      return @"Apple TV 2";
    if ([deviceModel isEqualToString:@"AppleTV3,1"])      return @"Apple TV 3";
    if ([deviceModel isEqualToString:@"AppleTV3,2"])      return @"Apple TV 3";
    if ([deviceModel isEqualToString:@"AppleTV5,3"])      return @"Apple TV 4";

    if ([deviceModel isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceModel isEqualToString:@"x86_64"])       return @"Simulator";
    return deviceModel;
}


+ (NSString *)convertModelToJSONString:(id)model {
    if (!model) {
        NSLog(@"Model is nil");
        return nil;
    }

    // 使用 KVC 获取模型的所有属性键值对
    NSDictionary *modelDict = [model dictionaryWithValuesForKeys:[self getPropertyNamesForClass:[model class]]];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:modelDict options:0 error:&error];
    
    if (error) {
        NSLog(@"Error converting model to JSON: %@", error.localizedDescription);
        return nil;
    }

    // 转换为字符串并返回
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSDictionary *)convertModelToDicInfo:(id)model {
    if (!model) {
        NSLog(@"Model is nil");
        return nil;
    }

    // 使用 KVC 获取模型的所有属性键值对
    NSDictionary *modelDict = [model dictionaryWithValuesForKeys:[self getPropertyNamesForClass:[model class]]];

    // 转换为字符串并返回
    return modelDict;
}

/// 获取类的所有属性名
+ (NSArray *)getPropertyNamesForClass:(Class)cls {
    NSMutableArray *propertyNames = [NSMutableArray array];
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);

    for (unsigned int i = 0; i < propertyCount; i++) {
        const char *propertyName = property_getName(properties[i]);
        [propertyNames addObject:[NSString stringWithUTF8String:propertyName]];
    }
    free(properties);

    return [propertyNames copy];
}

/// 生成标准的iOS User-Agent字符串
+ (NSString *)generateUserAgent {
    // 获取系统版本并替换点号为下划线
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    NSString *osVersion = [systemVersion stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    
    // 获取设备型号
    NSString *deviceModel = [self getCurrentDeviceModel];
    
    // 获取应用版本
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (!appVersion) {
        appVersion = @"1.0";
    }
    
    // 构造User-Agent字符串
    // 格式: Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1
    NSString *userAgent;
    
    if ([deviceModel hasPrefix:@"iPad"]) {
        userAgent = [NSString stringWithFormat:@"Mozilla/5.0 (iPad; CPU OS %@ like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/%@ Mobile/15E148 Safari/604.1",
                     osVersion, appVersion];
    } else {
        userAgent = [NSString stringWithFormat:@"Mozilla/5.0 (iPhone; CPU iPhone OS %@ like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/%@ Mobile/15E148 Safari/604.1",
                     osVersion, appVersion];
    }
    
    return userAgent;
}

@end

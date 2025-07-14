//
//  LionmoboDataPageTracker.m
//  LionmoboData
//
//  Created by lionmobo on 2025/7/7.
//

#import "LionmoboDataPageTracker.h"
#import "LionmoboDataPageEvent.h"
#import "../Logging/LionmoboDataLogger.h"
#import "../Utils/LionmoboDataTools.h"
#import "../Utils/DeviceInfo.h"
#import "../Utils/LionmoboDataNetworkManager.h"
#import <objc/runtime.h>

// 运行时关联对象的key
static const void *kPageEventAssociatedKey = &kPageEventAssociatedKey;

// 页面事件上传地址（内部配置，不对外暴露）
static NSString * const kPageEventUploadURL = @"https://api.lionmobo.com/v1/page-events";

@interface LionmoboDataPageTracker ()


@property (nonatomic, strong) dispatch_queue_t trackingQueue;
@property (nonatomic, assign) BOOL isTracking;

@end

@implementation LionmoboDataPageTracker

#pragma mark - 单例

+ (instancetype)sharedTracker {
    static LionmoboDataPageTracker *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _enabled = YES;
        _isTracking = NO;
        _pagePath = [NSMutableArray array];
        _navigationStack = [NSMutableArray array];
        _activePageEvents = [NSMutableDictionary dictionary];
        _trackingQueue = dispatch_queue_create("LionmoboData.PageTracking", DISPATCH_QUEUE_SERIAL);
        _pathTrackingMode = LionmoboDataPagePathTrackingModeHistory; // 默认为完整历史模式
    }
    return self;
}

#pragma mark - 页面追踪控制

- (void)startTracking {
    if (!self.enabled || self.isTracking) {
        return;
    }
    
    dispatch_async(self.trackingQueue, ^{
        [self swizzleViewControllerMethods];
        self.isTracking = YES;
    });
}

- (void)stopTracking {
    if (!self.isTracking) {
        return;
    }
    
    dispatch_async(self.trackingQueue, ^{
        [self restoreViewControllerMethods];
        self.isTracking = NO;
        
        // 清理当前活动的页面事件
        [self.activePageEvents removeAllObjects];
        [self.pagePath removeAllObjects];
        [self.navigationStack removeAllObjects];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            LMBLog(@"停止页面追踪");
        });
    });
}

#pragma mark - Method Swizzling

- (void)swizzleViewControllerMethods {
    Class class = [UIViewController class];
    
    // Swizzle viewDidAppear:
    Method originalViewDidAppear = class_getInstanceMethod(class, @selector(viewDidAppear:));
    Method swizzledViewDidAppear = class_getInstanceMethod(class, @selector(lmb_viewDidAppear:));
    
    if (!class_addMethod(class, @selector(viewDidAppear:), method_getImplementation(swizzledViewDidAppear), method_getTypeEncoding(swizzledViewDidAppear))) {
        method_exchangeImplementations(originalViewDidAppear, swizzledViewDidAppear);
    }
    
    // Swizzle viewDidDisappear:
    Method originalViewDidDisappear = class_getInstanceMethod(class, @selector(viewDidDisappear:));
    Method swizzledViewDidDisappear = class_getInstanceMethod(class, @selector(lmb_viewDidDisappear:));
    
    if (!class_addMethod(class, @selector(viewDidDisappear:), method_getImplementation(swizzledViewDidDisappear), method_getTypeEncoding(swizzledViewDidDisappear))) {
        method_exchangeImplementations(originalViewDidDisappear, swizzledViewDidDisappear);
    }
}

- (void)restoreViewControllerMethods {
    Class class = [UIViewController class];
    
    // 恢复viewDidAppear:
    Method originalViewDidAppear = class_getInstanceMethod(class, @selector(viewDidAppear:));
    Method swizzledViewDidAppear = class_getInstanceMethod(class, @selector(lmb_viewDidAppear:));
    method_exchangeImplementations(swizzledViewDidAppear, originalViewDidAppear);
    
    // 恢复viewDidDisappear:
    Method originalViewDidDisappear = class_getInstanceMethod(class, @selector(viewDidDisappear:));
    Method swizzledViewDidDisappear = class_getInstanceMethod(class, @selector(lmb_viewDidDisappear:));
    method_exchangeImplementations(swizzledViewDidDisappear, originalViewDidDisappear);
}

#pragma mark - 手动追踪方法

- (void)trackPageEnter:(NSString *)screenName pageTitle:(NSString *)pageTitle {
    if (!self.enabled) {
        return;
    }
    
    dispatch_async(self.trackingQueue, ^{
        [self handlePageEnter:screenName pageTitle:pageTitle];
    });
}

- (void)trackPageExit:(NSString *)screenName {
    if (!self.enabled) {
        return;
    }
    
    dispatch_async(self.trackingQueue, ^{
        [self handlePageExit:screenName];
    });
}

#pragma mark - 页面事件处理

- (void)handlePageEnter:(NSString *)screenName pageTitle:(NSString *)pageTitle {
    NSArray<NSString *> *currentPath = nil;
    
    if (self.pathTrackingMode == LionmoboDataPagePathTrackingModeHistory) {
        // 完整历史模式：记录所有访问的页面
        [self.pagePath addObject:screenName];
        currentPath = [self.pagePath copy];
        
        LMBLogDebug(@"页面进入[历史模式]: %@, 完整访问历史: %@", screenName, [self.pagePath componentsJoinedByString:@" > "]);
        
    } else if (self.pathTrackingMode == LionmoboDataPagePathTrackingModeStack) {
        // 导航栈模式：模拟导航栈的行为
        [self.navigationStack addObject:screenName];
        currentPath = [self.navigationStack copy];
        
        LMBLogDebug(@"页面进入[栈模式]: %@, 当前导航栈: %@", screenName, [self.navigationStack componentsJoinedByString:@" > "]);
    }
    
    // 创建页面事件，包含当前的页面路径
    LionmoboDataPageEvent *event = [LionmoboDataPageEvent pageEnterEventWithScreenName:screenName
                                                                              pageTitle:pageTitle
                                                                               pagePath:currentPath];
    
    // 保存活动事件，使用唯一的key（页面名称+时间戳）
    NSString *eventKey = [NSString stringWithFormat:@"%@_%.0f", screenName, [[NSDate date] timeIntervalSince1970]];
    self.activePageEvents[eventKey] = event;
    
    // 也保存一个最新的映射，用于退出时查找
    self.activePageEvents[screenName] = event;
}

- (void)handlePageExit:(NSString *)screenName {
    LionmoboDataPageEvent *event = self.activePageEvents[screenName];
    if (!event) {
        return;
    }
    
    // 计算停留时长
    NSTimeInterval duration = [[NSDate date] timeIntervalSince1970] - event.enterTime;
    [event markAsPageExitWithDuration:duration];
    
    NSArray<NSString *> *currentPath = nil;
    
    if (self.pathTrackingMode == LionmoboDataPagePathTrackingModeHistory) {
        // 完整历史模式：页面路径保持不变，继续累积完整的访问历史
        currentPath = [self.pagePath copy];
        
        LMBLogDebug(@"页面退出[历史模式]: %@, 停留时长: %.2fs, 完整访问历史: %@", 
                    screenName, duration, [self.pagePath componentsJoinedByString:@" > "]);
                    
    } else if (self.pathTrackingMode == LionmoboDataPagePathTrackingModeStack) {
        // 导航栈模式：从栈中移除最后一个匹配的页面
        NSInteger lastIndex = [self.navigationStack indexOfObjectWithOptions:NSEnumerationReverse
                                                                  passingTest:^BOOL(NSString *obj, NSUInteger idx, BOOL *stop) {
            return [obj isEqualToString:screenName];
        }];
        
        if (lastIndex != NSNotFound) {
            [self.navigationStack removeObjectAtIndex:lastIndex];
        }
        
        currentPath = [self.navigationStack copy];
        
        LMBLogDebug(@"页面退出[栈模式]: %@, 停留时长: %.2fs, 当前导航栈: %@", 
                    screenName, duration, [self.navigationStack componentsJoinedByString:@" > "]);
    }
    
    // 更新事件的退出时页面路径
    event.pagePath = currentPath;
    
    // 实时上传页面事件
    [self uploadPageEvent:event completion:^(BOOL success, NSError *error) {
        if (success) {
            LMBLogSuccess(@"页面事件上传成功: %@", screenName);
        } else {
            LMBLogError(@"页面事件上传失败: %@, 错误: %@", screenName, error.localizedDescription);
        }
    }];
    
    // 从活动事件中移除
    [self.activePageEvents removeObjectForKey:screenName];
}

#pragma mark - 网络上传

- (void)uploadPageEvent:(LionmoboDataPageEvent *)event completion:(void(^)(BOOL success, NSError *error))completion {
    NSDictionary *eventData = [event toDictionary];
    
    NSString *userID = [LionmoboDataTools detail].user_id;
    
    NSDictionary *appCrashed = @{@"user_id":[LionmoboDataTools detail].user_id,
                                 @"pagePath":[event.pagePath componentsJoinedByString:@" > "],
                                 @"pageName":event.screenName,
                                 @"pageTitle":event.pageTitle,
                                 @"timestamp":[NSNumber numberWithLongLong:(long long)(event.exitTime * 1000)],
                                 @"eventName":@"AppPageView"};
    NSArray *items = @[appCrashed];
    NSDictionary *paramets = @{@"details":items};
    
    
    [[LionmoboDataNetworkManager sharedManager] requestWithURL:@"/api/sdkPutEvents" method:LionmoboHTTPMethodPOST parameters:paramets headers:nil success:^(NSData * _Nullable data, NSDictionary * _Nullable responseObject) {
        if (responseObject) {
            NSError *error = nil;
            NSInteger code = [NSString stringWithFormat:@"%@",responseObject[@"code"]].integerValue;
            if (code == 200) {
                completion(YES, nil);
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *userInfo = responseObject; // 确保 responseObject 是 NSDictionary
                    NSError *error = [NSError errorWithDomain:@"com.lionmobodata.domain"
                                                         code:code
                                                     userInfo:userInfo];
                    completion(NO, error);
                });
            }
        }
    } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
        if (completion) {
            completion(NO, error);
        }
    }];
}

#pragma mark - 获取页面信息

- (NSString *)getPageTitle:(UIViewController *)viewController {
    // 尝试获取页面标题
    if (viewController.title && viewController.title.length > 0) {
        return viewController.title;
    }
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)viewController;
        return [self getPageTitle:nav.visibleViewController];
    }
    
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *)viewController;
        return [self getPageTitle:tab.selectedViewController];
    }
    
    return nil;
}

- (BOOL)shouldTrackViewController:(UIViewController *)viewController {
    // 过滤掉系统的ViewController
    NSString *className = NSStringFromClass([viewController class]);
    
    // 过滤系统类
    if ([className hasPrefix:@"UI"] || 
        [className hasPrefix:@"_UI"] ||
        [className hasPrefix:@"SB"] ||
        [className containsString:@"NavigationController"] ||
        [className containsString:@"TabBarController"]) {
        return NO;
    }
    
    return YES;
}

@end

#pragma mark - UIViewController Category

@implementation UIViewController (LionmoboDataPageTracking)

- (void)lmb_viewDidAppear:(BOOL)animated {
    // 调用原始方法
    [self lmb_viewDidAppear:animated];
    
    // 页面追踪逻辑
    LionmoboDataPageTracker *tracker = [LionmoboDataPageTracker sharedTracker];
    if (tracker.enabled && [tracker shouldTrackViewController:self]) {
        NSString *screenName = NSStringFromClass([self class]);
        NSString *pageTitle = [tracker getPageTitle:self];
        
        [tracker trackPageEnter:screenName pageTitle:pageTitle];
    }
}

- (void)lmb_viewDidDisappear:(BOOL)animated {
    // 调用原始方法
    [self lmb_viewDidDisappear:animated];
    
    // 页面追踪逻辑
    LionmoboDataPageTracker *tracker = [LionmoboDataPageTracker sharedTracker];
    if (tracker.enabled && [tracker shouldTrackViewController:self]) {
        NSString *screenName = NSStringFromClass([self class]);
        
        [tracker trackPageExit:screenName];
    }
}

@end 

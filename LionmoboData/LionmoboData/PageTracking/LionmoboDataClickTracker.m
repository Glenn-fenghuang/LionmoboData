//
//  LionmoboDataClickTracker.m
//  LionmoboData
//
//  Created by LionmoboData SDK on 2025/1/9.
//  Copyright © 2025 LionmoboData. All rights reserved.
//

#import "LionmoboDataClickTracker.h"
#import "../Logging/LionmoboDataLogger.h"
#import "../Utils/LionmoboDataTools.h"
#import "../Utils/DeviceInfo.h"
#import "../Utils/LionmoboDataNetworkManager.h"
#import "../PageTracking/LionmoboDataClickEvent.h"
#import <objc/runtime.h>



@interface LionmoboDataClickTracker ()

@property (nonatomic, strong) dispatch_queue_t uploadQueue;
@property (nonatomic, assign) BOOL hasSwizzled;

@end

@implementation LionmoboDataClickTracker

+ (instancetype)sharedTracker {
    static LionmoboDataClickTracker *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LionmoboDataClickTracker alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _enabled = NO;
        _hasSwizzled = NO;
        _uploadQueue = dispatch_queue_create("com.lionmobodata.click.upload", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)startTracking {
    if (!self.enabled) {
        return;
    }
    
    if (!self.hasSwizzled) {
        [self swizzleClickMethods];
        self.hasSwizzled = YES;
        
    }
}

- (void)stopTracking {
    // 注意：实际项目中可能需要考虑如何恢复原始方法
    // 这里简单设置enabled为NO
    self.enabled = NO;
    LMBLog(@"点击追踪已停用");
}

#pragma mark - Method Swizzling

- (void)swizzleClickMethods {
    // Hook UIButton的点击事件
    [self swizzleUIControlMethods];
    
    // Hook UIGestureRecognizer的点击事件
    [self swizzleGestureRecognizerMethods];
    
    // Hook UITableView和UICollectionView的选择事件
    [self swizzleTableViewMethods];
    [self swizzleCollectionViewMethods];
}

- (void)swizzleUIControlMethods {
    Class class = [UIControl class];
    
    SEL originalSelector = @selector(sendAction:to:forEvent:);
    SEL swizzledSelector = @selector(ld_sendAction:to:forEvent:);
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)swizzleGestureRecognizerMethods {
    Class class = [UIGestureRecognizer class];
    
    SEL originalSelector = @selector(setState:);
    SEL swizzledSelector = @selector(ld_setState:);
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)swizzleTableViewMethods {
    Class class = [UITableView class];
    
    SEL originalSelector = @selector(setDelegate:);
    SEL swizzledSelector = @selector(ld_setDelegate:);
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    if (originalMethod && swizzledMethod) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
        
    }
}

- (void)swizzleCollectionViewMethods {
    Class class = [UICollectionView class];
    
    SEL originalSelector = @selector(setDelegate:);
    SEL swizzledSelector = @selector(ld_setCollectionDelegate:);
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    if (originalMethod && swizzledMethod) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
        
    }
}

#pragma mark - Track Methods

- (void)trackClickOnElement:(UIView *)element pageName:(NSString *)pageName {
    if (!self.enabled) {
        return;
    }
    
    // 创建点击事件
    LionmoboDataClickEvent *event = [LionmoboDataClickEvent eventWithElement:element pageName:pageName];
    
    LMBLogDebug(@"捕获点击事件: %@ (页面: %@)", event.elementType, pageName);
    
    // 异步上传
    dispatch_async(self.uploadQueue, ^{
        [self uploadClickEvent:event completion:^(BOOL success, NSError *error) {
            if (success) {
                LMBLogSuccess(@"点击事件上传成功: %@", event.eventId);
            } else {
                LMBLogError(@"点击事件上传失败: %@, 错误: %@", event.eventId, error.localizedDescription);
            }
        }];
    });
}

- (NSString *)getCurrentPageName {
    // 获取当前显示的ViewController
    UIViewController *topViewController = [self topViewController];
    return NSStringFromClass([topViewController class]);
}

- (UIViewController *)topViewController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    if ([topController isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)topController topViewController];
    } else if ([topController isKindOfClass:[UITabBarController class]]) {
        return [(UITabBarController *)topController selectedViewController];
    }
    
    return topController;
}

#pragma mark - Upload

- (void)uploadClickEvent:(LionmoboDataClickEvent *)event completion:(void(^)(BOOL success, NSError *error))completion {
    NSDictionary *eventData = [event toDictionary];
    NSString *userID = [LionmoboDataTools detail].user_id;
    
    NSDictionary *appCrashed = @{@"user_id":[LionmoboDataTools isEmptyOrNull:userID] ? @"":userID,
                                 @"pagePath":event.pagePath,
                                 @"pageName":event.pageName,
                                 @"pageTitle":event.pageTitle,
                                 @"timestamp":[NSNumber numberWithLongLong:(long long)(event.timestamp * 1000)],
                                 @"viewId":event.elementId,
                                 @"viewText":event.elementContent?:@"",
                                 @"viewType":event.elementType,
                                 @"viewPositionX":[NSString stringWithFormat:@"%@",event.elementPositionX],
                                 @"viewPositionY":[NSString stringWithFormat:@"%@",event.elementPositionY],
                                 @"eventName":@"AppClick"};
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

@end

#pragma mark - UIControl Category

@implementation UIControl (LionmoboDataClickTracking)

- (void)ld_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    // 调用原始方法
    [self ld_sendAction:action to:target forEvent:event];
    
    // 追踪点击事件
    LionmoboDataClickTracker *tracker = [LionmoboDataClickTracker sharedTracker];
    if (tracker.enabled) {
        NSString *pageName = [tracker getCurrentPageName];
        [tracker trackClickOnElement:self pageName:pageName];
    }
}

@end

#pragma mark - UIGestureRecognizer Category

@implementation UIGestureRecognizer (LionmoboDataClickTracking)

- (void)ld_setState:(UIGestureRecognizerState)state {
    // 调用原始方法
    [self ld_setState:state];
    
    // 只追踪Tap手势的结束状态
    if (state == UIGestureRecognizerStateEnded && [self isKindOfClass:[UITapGestureRecognizer class]]) {
        LionmoboDataClickTracker *tracker = [LionmoboDataClickTracker sharedTracker];
        if (tracker.enabled && self.view) {
            NSString *pageName = [tracker getCurrentPageName];
            [tracker trackClickOnElement:self.view pageName:pageName];
        }
    }
}

@end

#pragma mark - UITableView Category

@implementation UITableView (LionmoboDataClickTracking)

- (void)ld_setDelegate:(id<UITableViewDelegate>)delegate {
    // 调用原始方法
    [self ld_setDelegate:delegate];
    
    // 这里可以进一步hook delegate的方法，比如didSelectRowAtIndexPath
    // 为了简化，暂时不实现
}

@end

#pragma mark - UICollectionView Category

@implementation UICollectionView (LionmoboDataClickTracking)

- (void)ld_setCollectionDelegate:(id<UICollectionViewDelegate>)delegate {
    // 调用原始方法
    [self ld_setCollectionDelegate:delegate];
    
    // 这里可以进一步hook delegate的方法
    // 为了简化，暂时不实现
}

@end 

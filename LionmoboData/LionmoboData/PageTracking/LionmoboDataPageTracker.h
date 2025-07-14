//
//  LionmoboDataPageTracker.h
//  LionmoboData
//
//  Created by lionmobo on 2025/7/7.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class LionmoboDataPageEvent;

NS_ASSUME_NONNULL_BEGIN

/**
 * 页面路径追踪模式
 */
typedef NS_ENUM(NSInteger, LionmoboDataPagePathTrackingMode) {
    LionmoboDataPagePathTrackingModeHistory = 0,     // 完整历史模式：记录所有访问页面
    LionmoboDataPagePathTrackingModeStack = 1,       // 导航栈模式：基于导航栈状态
};

/**
 * 页面追踪管理器
 * 自动追踪UIViewController的生命周期，收集页面访问行为数据
 */
@interface LionmoboDataPageTracker : NSObject

/// 单例实例
+ (instancetype)sharedTracker;

@property (nonatomic, strong) NSMutableArray<NSString *> *pagePath;
@property (nonatomic, strong) NSMutableArray<NSString *> *navigationStack; // 导航栈模式使用
@property (nonatomic, strong) NSMutableDictionary<NSString *, LionmoboDataPageEvent *> *activePageEvents;

/// 是否启用页面追踪
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

/// 页面路径追踪模式，默认为完整历史模式
@property (nonatomic, assign) LionmoboDataPagePathTrackingMode pathTrackingMode;

/**
 * 开始页面追踪
 * 使用方法交换（Method Swizzling）自动hook UIViewController生命周期
 */
- (void)startTracking;

/**
 * 停止页面追踪
 * 恢复UIViewController原始方法
 */
- (void)stopTracking;

/**
 * 手动记录页面进入事件（可选，通常自动追踪就够了）
 */
- (void)trackPageEnter:(NSString *)screenName pageTitle:(nullable NSString *)pageTitle;

/**
 * 手动记录页面退出事件（可选，通常自动追踪就够了）
 */
- (void)trackPageExit:(NSString *)screenName;

/**
 * 上传页面事件到服务器
 */
- (void)uploadPageEvent:(LionmoboDataPageEvent *)event completion:(nullable void(^)(BOOL success, NSError *error))completion;



@end

NS_ASSUME_NONNULL_END 

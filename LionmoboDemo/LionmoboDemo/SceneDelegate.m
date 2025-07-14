//
//  SceneDelegate.m
//  LionmoboDemo
//
//  Created by lionmobo on 2025/7/7.
//

#import "SceneDelegate.h"
#import "ViewController.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // 手动创建窗口和导航控制器
    if ([scene isKindOfClass:[UIWindowScene class]]) {
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        
        // 创建窗口
        self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
        
        // 创建主视图控制器
        ViewController *mainViewController = [[ViewController alloc] init];
        
        // 创建导航控制器
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
        navigationController.navigationBar.prefersLargeTitles = YES;
        
        // 设置根视图控制器
        self.window.rootViewController = navigationController;
        
        // 显示窗口
        [self.window makeKeyAndVisible];
        
        NSLog(@"[LionmoboData] SceneDelegate - 手动创建了导航控制器和窗口");
    }
}


- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}


@end

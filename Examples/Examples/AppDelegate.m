//
//  AppDelegate.m
//  Examples
//
//  Created by 李传格 on 2017/6/27.
//  Copyright © 2017年 fanmei. All rights reserved.
//

#import "AppDelegate.h"
#import "UrlRouter.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UrlRouter sharedInstance] registerPage:@"page1" forViewControllerClass:ViewController.class isUrlExported:YES];
    [[UrlRouter sharedInstance] registerPage:@"page2" forViewControllerClass:ViewController.class isUrlExported:YES];
    [[UrlRouter sharedInstance] registerPage:@"page3" forViewControllerClass:ViewController.class isUrlExported:YES];
    
    UrlRouterConfig *config = [[UrlRouterConfig alloc] init];
    config.mode = UrlRouterContainerModeNavigationAndTabBar;
    config.navigationControllerClass = UINavigationController.class;
    config.tabBarControllerClass = UITabBarController.class;
    config.webContainerClass = ViewController.class;
    config.nativeUrlScheme = @"NativePages";
    config.nativeUrlHostName = nil;
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.windowLevel = UIWindowLevelNormal;
    self.window.rootViewController = [[UrlRouter sharedInstance] startupWithConfig:config andInitialPages:@[@"page2", @"page2", @"page2"]];
    [self.window makeKeyAndVisible];
    
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"tableview"];
    [[UrlRouter sharedInstance].navigationController pushViewController:vc animated:NO];
    
//    [[UrlRouter sharedInstance] openPage:@"page1" withParams:nil animated:NO];
//    [[UrlRouter sharedInstance] openPage:@"page3" withParams:nil animated:NO];
//    [[UrlRouter sharedInstance] openPage:@"page2" withParams:nil animated:NO];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end

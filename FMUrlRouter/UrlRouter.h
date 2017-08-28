//
//  UrlRouter.h
//  MyDemo
//
//  Created by chuange.lcg on 16/3/29.
//  Copyright © 2016年 lcg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UrlRouterConfig.h"
#import "UIViewController+UrlRouter.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Native pages or H5 pages can decoupled by `UrlRouter` based on url or page name.
 */
@interface UrlRouter : NSObject

+ (instancetype)sharedInstance;

#pragma mark - Setup

/**
 Register native page meta.

 @param pageName page name
 @param clazz view controller class meta
 @param isUrlExported whether page can opened by url
 */
- (void)registerPage:(NSString *)pageName forViewControllerClass:(Class)clazz isUrlExported:(BOOL)isUrlExported;

/**
 Start up

 @param config configurations
 @param pageNames intial pages will created auto by the names, and names must registered.
 @return instance of root container
 */
- (UIViewController *)startupWithConfig:(UrlRouterConfig *)config andInitialPages:(NSArray *)pageNames;

#pragma mark - Container instance

@property (nullable, nonatomic, strong, readonly) UINavigationController *navigationController;

@property (nullable, nonatomic, strong, readonly) UITabBarController *tabBarController;

#pragma mark - Others

/**
 *  根据页面名称判断页面是否存在
 */
- (BOOL)isPageExists:(NSString *)pageName;

/**
 *  顶部页面名称
 */
- (NSString *)topPageName;

/**
 判断视图控制器是否在顶部
 */
- (BOOL)isViewControllerAtTop:(UIViewController *)viewController;

#pragma mark - Open native pages by name

- (void)openPage:(NSString *)pageName;
- (void)openPage:(NSString *)pageName withParams:(NSDictionary *__nullable)params;
- (void)openPage:(NSString *)pageName withParams:(NSDictionary *__nullable)params animated:(BOOL)animated;
- (BOOL)openPage:(NSString *)pageName withParams:(NSDictionary *__nullable)params callback:(FMUrlPopedCallback __nullable)callback animated:(BOOL)animated;
+ (void)openPage:(NSString *)pageName;
+ (void)openPage:(NSString *)pageName withParams:(NSDictionary *__nullable)params;
+ (void)openPage:(NSString *)pageName withParams:(NSDictionary *__nullable)params animated:(BOOL)animated;
+ (void)openPage:(NSString *)pageName withParams:(NSDictionary *__nullable)params withCallback:(FMUrlPopedCallback __nullable)callback;

#pragma mark - Open pages by url

- (BOOL)canOpenUrl:(NSURL *)url;

- (BOOL)openPageWithUrl:(NSURL *)url;
- (BOOL)openPageWithUrl:(NSURL *)url animated:(BOOL)animated;
- (BOOL)openPageWithUrl:(NSURL *)url params:(NSDictionary *__nullable)params callback:(FMUrlPopedCallback __nullable)callback animated:(BOOL)animated;

#pragma mark - Close

- (void)closePageWithResult:(NSDictionary *__nullable)result animated:(BOOL)animated;

/**
 *  关闭页面
 */
+ (void)closePage;

/**
 *  关闭页面
 *
 *  @param result 响应数据
 */
+ (void)closePageWithResult:(NSDictionary *)result;

/**
 *  关闭当前页面以及其它页面
 */
- (void)closeSelfAndOtherPages:(NSArray<NSString *> *)otherPages;

/**
 返回到指定页面

 @param pageName pageName
 */
+ (void)closeToPage:(NSString *)pageName;

@end

NS_ASSUME_NONNULL_END

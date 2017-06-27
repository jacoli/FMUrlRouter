//
//  UrlRouter.h
//  MyDemo
//
//  Created by chuange.lcg on 16/3/29.
//  Copyright © 2016年 lcg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UrlRouterConfig.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  页面Pop的Callback回调
 */
typedef void (^FMUrlPopedCallback)(NSDictionary * _Nullable result);

@interface UIViewController (UrlRouter)

/**
 *  当前页面名称，不为空
 */
@property (nonatomic, copy, readonly) NSString *vcPageName;

/**
 *  额外参数，可选
 */
@property (nonatomic, strong, readonly) NSDictionary *urlParams;

/**
 *  上个页面名称，必选
 */
@property (nonatomic, copy, readonly) NSString *fromPage;

/**
 *  url链接地址，可选
 */
@property (nonatomic, copy, readonly) NSString *h5Url;

/**
 *  回调Block，可选
 */
@property (nonatomic, copy, readonly) FMUrlPopedCallback urlCallback;

/**
 *  是否允许在导航栈中存在多个实例
 */
+ (BOOL)isSingletonPage;

@end

/**
 Native pages or H5 pages can decoupled by `UrlRouter` based on url.
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
- (UIViewController *)startupWithConfig:(UrlRouterConfig *_Nonnull)config andInitialPages:(NSArray *)pageNames;

#pragma mark - Container instance

@property (nullable, nonatomic, strong, readonly) UINavigationController *navigationController;

@property (nullable, nonatomic, strong, readonly) UITabBarController *tabBarController;

#pragma mark - Others

/**
 *  处理App Url跳转
 *
 *  @return 成功处理返回YES，否则返回NO
 */
- (BOOL)handleApplicationUrl:(NSURL *)url;

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
- (void)openPage:(NSString *)pageName withParams:(NSDictionary *)params;
- (void)openPage:(NSString *)pageName withParams:(NSDictionary *)params animated:(BOOL)animated;
- (BOOL)openPage:(NSString *)pageName withParams:(NSDictionary *)params callback:(FMUrlPopedCallback)callback animated:(BOOL)animated;

/**
 *  打开Native页面
 */
+ (void)openPage:(NSString *)pageName;
+ (void)openPage:(NSString *)pageName withParams:(NSDictionary *)params;
+ (void)openPage:(NSString *)pageName withParams:(NSDictionary *)params animated:(BOOL)animated;
+ (void)openPage:(NSString *)pageName withParams:(NSDictionary *)params withCallback:(FMUrlPopedCallback)callback;

#pragma mark - Open pages by url

- (BOOL)canOpenUrl:(NSURL *)url;

/**
 *  打开Url链接
 */
+ (BOOL)openUrl:(NSURL *)url;
+ (BOOL)openUrl:(NSURL *)url animated:(BOOL)animated;
+ (BOOL)openUrl:(NSURL *)url animated:(BOOL)animated withCallback:(FMUrlPopedCallback)callback;
+ (BOOL)openUrl:(NSURL *)url withParams:(NSDictionary *)params animated:(BOOL)animated withCallback:(FMUrlPopedCallback)callback;

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

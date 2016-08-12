//
//  UrlRouter.h
//  MyDemo
//
//  Created by chuange.lcg on 16/3/29.
//  Copyright © 2016年 lcg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+UrlRouter.h"

/**
 *  页面统一跳转管理器，使用标准的URL规范，支持Http、Https、本地页面Scheme等协议
 *  用于页面间的强解藕
 *  TODO 没有参数校验机制，增加对tabcontroller的支持
 */
@interface UrlRouter : NSObject

+ (instancetype)sharedInstance;

/**
 *  初始化
 *
 *  @param navigationController 导航控制器
 *  @param webContainerClass    H5容器类
 *  @param nativeUrlScheme      Native页面Url的Scheme
 */
- (void)startupWithNavController:(UINavigationController *)navigationController
               webContainerClass:(Class)webContainerClass
                 nativeUrlScheme:(NSString *)nativeUrlScheme;

/**
 *  处理App Url跳转
 *
 *  @return 成功处理返回YES，否则返回NO
 */
- (BOOL)handleApplicationUrl:(NSURL *)url;

/**
 *  注册Native页面
 */
+ (void)registerPage:(NSString *)pageName forViewControllerClass:(Class)clazz;

/**
 *  页面是否存在
 */
- (BOOL)isPageExists:(NSString *)pageName;

/**
 *  当前顶部页面名称
 */
- (NSString *)currentPageName;

#pragma mark - Open

/**
 *  打开Native页面
 */
+ (void)openPage:(NSString *)pageName;
+ (void)openPage:(NSString *)pageName withParams:(NSDictionary *)params;
+ (BOOL)openPage:(NSString *)pageName withparams:(NSDictionary *)params animated:(BOOL)animated;
+ (void)openPage:(NSString *)pageName withParams:(NSDictionary *)params withCallback:(UrlCallback)callback;

/**
 *  打开Url链接
 */
+ (BOOL)openUrl:(NSURL *)url;
+ (BOOL)openUrl:(NSURL *)url withParams:(NSDictionary *)params;
+ (BOOL)openUrl:(NSURL *)url animated:(BOOL)animated;
+ (BOOL)openUrl:(NSURL *)url animated:(BOOL)animated withCallback:(UrlCallback)callback;

#pragma mark - Close

/**
 *  关闭页面
 */
+ (void)closePage;

/**
 *  关闭当前页面以及其它页面
 */
+ (void)closeSelfAndOtherPages:(NSArray<NSString *> *)otherPages;

/**
 *  关闭页面
 *
 *  @param result 响应数据
 */
+ (void)closePageWithResult:(NSDictionary *)result;

@end

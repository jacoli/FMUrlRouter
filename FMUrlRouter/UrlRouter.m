//
//  UrlRouter.m
//  MyDemo
//
//  Created by chuange.lcg on 16/3/29.
//  Copyright © 2016年 lcg. All rights reserved.
//

#import "UrlRouter.h"
#import "UrlRouterUtils.h"
#import <objc/runtime.h>
#import "UIViewController+UrlRouterPrivate.h"

@interface UrlRouter ()

/**
 Configurations of router.
 */
@property (nonatomic, strong) UrlRouterConfig *config;

/**
 Instances of root container, kind of UINavigationController, must not nil after startup.
 */
@property (nonatomic, strong) UINavigationController *navigationController;

/**
 Instances of sub root container, kind of UITabBarController, may nil if config.mode is UrlRouterContainerModeOnlyNavigation.
 */
@property (nonatomic, strong) UITabBarController *tabBarController;

/**
 Supported schemes, including user defined native scheme.
 */
@property (nonatomic, strong) NSMutableArray *supportedSchemes;

/**
 Meta of native pages, key is page name, kind of NSString, value is view controller class, kind of NSString.
 */
@property (nonatomic, strong) NSMutableDictionary *nativePages;

/**
 Native pages can opened by url, default is NO.
 */
@property (nonatomic, strong) NSMutableArray *urlExportedNativePages;

@end

@implementation UrlRouter

+ (instancetype)sharedInstance {
    static UrlRouter *__sharedInstance;
    static dispatch_once_t __once;
    dispatch_once(&__once, ^{
        __sharedInstance = [[UrlRouter alloc] init];
    });
    return __sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.supportedSchemes = [[NSMutableArray alloc] init];
        self.nativePages = [[NSMutableDictionary alloc] init];
        self.urlExportedNativePages = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Utils

- (Class)classForPageName:(NSString *)pageName {
    if (pageName.length > 0) {
        NSString *pageClassName = self.nativePages[pageName];
        if (pageClassName.length > 0) {
            Class pageClass = NSClassFromString(pageClassName);
            return pageClass;
        }
    }
    return nil;
}

#define ClassForPageName(pageName) ([self classForPageName:(pageName)])

- (NSString *)localPageNameFromUrl:(NSURL *)url {
    if (!url) {
        return nil;
    }
    
    NSString *pageName;
    
    if (self.config.nativeUrlHostName.length > 0) {
        if (![url.host isEqualToString:self.config.nativeUrlHostName]) {
            return nil;
        }
        
        pageName = url.path;
    }
    else {
        pageName = url.host;
    }
    
    if ([pageName hasPrefix:@"/"]) {
        pageName = [pageName substringFromIndex:1];
    }
    
    if (pageName.length == 0) {
        return nil;
    }
    
    return pageName;
}

- (BOOL)checkValidOfPageName:(NSString *)pageName className:(NSString *)className {
    if (pageName.length == 0 || className.length == 0) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Setup

- (void)registerPage:(NSString *)pageName forViewControllerClass:(Class)clazz isUrlExported:(BOOL)isUrlExported {
    NSString *className = NSStringFromClass(clazz);
    if ([self checkValidOfPageName:pageName className:className]) {
        self.nativePages[pageName] = className;
        if (isUrlExported) {
            [self.urlExportedNativePages addObject:pageName];
        }
    }
}

- (UIViewController *)startupWithConfig:(UrlRouterConfig *)config andInitialPages:(NSArray *)pageNames {
    [self.supportedSchemes removeAllObjects];
    
    if (config.webContainerClass) {
        [self.supportedSchemes addObject:@"http"];
        [self.supportedSchemes addObject:@"https"];
    }
    
    if (config.nativeUrlScheme.length > 0) {
        [self.supportedSchemes addObject:config.nativeUrlScheme];
    }
    
    self.config = config;
    
    return [self startupWithInitialPages:pageNames];
}

- (UIViewController *)startupWithInitialPages:(NSArray *)pageNames {
#if defined(DEBUG) && DEBUG
    NSLog(@"Registered %@ pages total.", @(self.nativePages.count));
    [self.nativePages enumerateKeysAndObjectsUsingBlock:^(NSString *pageName, NSString *className, BOOL * _Nonnull stop) {
        NSLog(@"Page(%@) registered with class [%@].", pageName, className);
    }];
#endif
    
    if (!pageNames) {
        return nil;
    }
    
    if (self.config.mode == UrlRouterContainerModeOnlyNavigation) {
        Class initialPageClass = nil;
        NSString *pageName = nil;
        if (pageNames.count > 0) {
            pageName = pageNames.firstObject;
            initialPageClass = ClassForPageName(pageName);
        }
        
        if (self.config.navigationControllerClass && initialPageClass) {
            UIViewController *contentVC = [[initialPageClass alloc] init];
            contentVC.vcPageName = pageName;
            self.navigationController = [[self.config.navigationControllerClass alloc] initWithRootViewController:contentVC];
            return self.navigationController;
        }
    } else if (self.config.mode == UrlRouterContainerModeNavigationAndTabBar) {
        if (self.config.navigationControllerClass && self.config.tabBarControllerClass) {
            self.tabBarController = [[self.config.tabBarControllerClass alloc] init];
            self.navigationController = [[self.config.navigationControllerClass alloc] initWithRootViewController:self.tabBarController];
            
            NSMutableArray *contentVCs = [[NSMutableArray alloc] init];
            if (pageNames.count > 0) {
                [pageNames enumerateObjectsUsingBlock:^(NSString *pageName, NSUInteger idx, BOOL * _Nonnull stop) {
                    Class pageClass = ClassForPageName(pageName);
                    if (pageClass) {
                        UIViewController *vc = [[pageClass alloc] init];
                        vc.vcPageName = pageName;
                        [contentVCs addObject:vc];
                    }
                }];
            }
            self.tabBarController.viewControllers = contentVCs;
            
            return self.navigationController;
        }
    }
    
    return nil;
}

#pragma mark - Others

- (BOOL)isPageExists:(NSString *)pageName {
    if (pageName.length == 0) {
        return NO;
    }
    
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc.vcPageName isEqualToString:pageName]) {
            return YES;
        }
    }
    
    for (UIViewController *vc in self.tabBarController.viewControllers) {
        if ([vc.vcPageName isEqualToString:pageName]) {
            return YES;
        }
    }
    
    return NO;
}

- (UIViewController *)viewControllerMatchedWithPageName:(NSString *)pageName {
    if (pageName.length == 0) {
        return nil;
    }
    
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc.vcPageName isEqualToString:pageName]) {
            return vc;
        }
    }
    
    for (UIViewController *vc in self.tabBarController.viewControllers) {
        if ([vc.vcPageName isEqualToString:pageName]) {
            return vc;
        }
    }
    
    return nil;
}

- (NSString *)topPageName {
    if ([self.navigationController.topViewController isEqual:self.tabBarController]) {
        return self.tabBarController.selectedViewController.vcPageName;
    } else {
        return self.navigationController.topViewController.vcPageName;
    }
}

- (BOOL)isViewControllerAtTop:(UIViewController *)viewController {
    if ([self.navigationController.topViewController isEqual:self.tabBarController]) {
        return [self.tabBarController.selectedViewController isEqual:viewController];
    } else {
        return [self.navigationController.topViewController isEqual:viewController];
    }
}

#pragma mark - Open native pages by name

- (void)configVCBeforePush:(UIViewController *)vc params:(NSDictionary *)params callback:(FMUrlPopedCallback)callback {
    vc.urlCallback = callback;
    vc.urlParams = params;
    [vc parseInputParams];
    vc.fromPage = self.navigationController.topViewController.vcPageName;
}

- (BOOL)openPage:(NSString *)pageName withParams:(NSDictionary * __nullable)params callback:(FMUrlPopedCallback __nullable)callback animated:(BOOL)animated {
    if (!self.navigationController) return NO;
    Class cls = ClassForPageName(pageName);
    if (!cls) return NO;
    
    if ([cls isSingletonPage]) {
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc.vcPageName isEqualToString:pageName]) {
                // pop to the singleton page
                [self configVCBeforePush:vc params:params callback:callback];
                [self popToViewController:vc animated:animated];
                return YES;
            }
        }
        
        if (self.tabBarController) {
            __block BOOL isContainedInTabBarController = NO;
            __block NSInteger index = 0;
            [self.tabBarController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.vcPageName isEqualToString:pageName]) {
                    isContainedInTabBarController = YES;
                    index = idx;
                    *stop = YES;
                }
            }];
            
            if (isContainedInTabBarController) {
                self.tabBarController.selectedIndex = index;
                [self configVCBeforePush:self.tabBarController.viewControllers[index] params:params callback:callback];
                [self popToViewController:self.tabBarController animated:animated];
                return YES;
            }
        }
    }
    
    // push a new page
    UIViewController *vc = [[cls alloc] init];
    vc.vcPageName = pageName;
    [self configVCBeforePush:vc params:params callback:callback];
    [self.navigationController pushViewController:vc animated:animated];
    
    return YES;
}

- (void)openPage:(NSString *)pageName {
    [self openPage:pageName withParams:nil callback:nil animated:YES];
}

- (void)openPage:(NSString *)pageName withParams:(NSDictionary *__nullable)params {
    [self openPage:pageName withParams:params callback:nil animated:YES];
}

- (void)openPage:(NSString *)pageName withParams:(NSDictionary *__nullable)params animated:(BOOL)animated {
    [self openPage:pageName withParams:params callback:nil animated:animated];
}

+ (void)openPage:(NSString *)pageName {
    [[UrlRouter sharedInstance] openPage:pageName withParams:nil callback:nil animated:YES];
}

+ (void)openPage:(NSString *)pageName withParams:(NSDictionary *__nullable)params {
    [[UrlRouter sharedInstance] openPage:pageName withParams:params callback:nil animated:YES];
}

+ (void)openPage:(NSString *)pageName withParams:(NSDictionary *__nullable)params animated:(BOOL)animated {
    [[UrlRouter sharedInstance] openPage:pageName withParams:params callback:nil animated:animated];
}

+ (void)openPage:(NSString *)pageName withParams:(NSDictionary *__nullable)params withCallback:(FMUrlPopedCallback __nullable)callback {
    [[UrlRouter sharedInstance] openPage:pageName withParams:params callback:callback animated:YES];
}

#pragma mark - Open pages by url

- (BOOL)canOpenUrl:(NSURL *)url {
    if ([self.supportedSchemes containsObject:url.scheme]) {
        if ([url.scheme isEqualToString:self.config.nativeUrlScheme]) {
            // local url
            NSString *pageName = [self localPageNameFromUrl:url];
            return pageName && [self.urlExportedNativePages containsObject:pageName];
        } else {
            // http/https url
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)_openLocalUrl:(NSURL *)url
          withParams:(NSDictionary *)params
            animated:(BOOL)animated
        withCallback:(FMUrlPopedCallback)callback {
    NSString *pageName = [self localPageNameFromUrl:url];
    if (![self.urlExportedNativePages containsObject:pageName]) {
        return NO;
    }
    
    // URL Params
    NSMutableDictionary *allParams = [[NSMutableDictionary alloc] init];
    NSDictionary *queryParams = [url urlRouter_params];
    if (queryParams) {
        [allParams addEntriesFromDictionary:queryParams];
    }
    
    if (params) {
        [allParams addEntriesFromDictionary:params];
    }
    
    return [self openPage:pageName withParams:allParams callback:callback animated:animated];
}

- (BOOL)_openH5Url:(NSURL *)url withParams:(NSDictionary *)params animated:(BOOL)animated withCallback:(FMUrlPopedCallback)callback {
    if (self.config.webContainerClass && self.navigationController) {
        UIViewController *vc = [[self.config.webContainerClass alloc] init];
        vc.vcPageName = [[url absoluteString] urlRouter_toBaseUrl];
        vc.h5Url = [url absoluteString];
        [self configVCBeforePush:vc params:params callback:callback];
        [self.navigationController pushViewController:vc animated:animated];
        
        return YES;
    }
    
    return NO;
}

- (BOOL)_openPageWithUrl:(NSURL *)url params:(NSDictionary *__nullable)params callback:(FMUrlPopedCallback __nullable)callback animated:(BOOL)animated {
    if ([self.supportedSchemes containsObject:url.scheme]) {
        if ([url.scheme isEqualToString:self.config.nativeUrlScheme]) {
            return [self _openLocalUrl:url withParams:params animated:animated withCallback:callback];
        } else {
            return [self _openH5Url:url withParams:params animated:animated withCallback:callback];
        }
    }
    
    return NO;
}

- (BOOL)openPageWithUrl:(NSURL *)url {
    return [self _openPageWithUrl:url params:nil callback:nil animated:YES];
}

- (BOOL)openPageWithUrl:(NSURL *)url animated:(BOOL)animated {
    return [self _openPageWithUrl:url params:nil callback:nil animated:animated];
}

- (BOOL)openPageWithUrl:(NSURL *)url params:(NSDictionary *__nullable)params callback:(FMUrlPopedCallback __nullable)callback animated:(BOOL)animated {
    return [self _openPageWithUrl:url params:params callback:callback animated:YES];
}

#pragma mark - Close

+ (void)invokePopedCallback:(FMUrlPopedCallback)callback withResult:(NSDictionary *)result shouldDelay:(BOOL)shouldDelay {
    if (callback) {
        if (shouldDelay) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                callback(result);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(result);
            });
        }
    }
}

- (void)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (viewController) {
        if ([viewController isEqual:self.navigationController.topViewController]) {
            return;
        }
        
        NSArray *popedVCs = [self.navigationController popToViewController:viewController animated:animated];
        for (UIViewController *vc in popedVCs) {
            [UrlRouter invokePopedCallback:vc.urlCallback withResult:nil shouldDelay:animated];
        }
    }
}

- (void)closePageWithResult:(NSDictionary *)result animated:(BOOL)animated {
    UIViewController *vc = [self.navigationController popViewControllerAnimated:animated];
    [UrlRouter invokePopedCallback:vc.urlCallback withResult:result shouldDelay:animated];
}

+ (void)closePageWithResult:(NSDictionary *__nullable)result animated:(BOOL)animated {
    [[UrlRouter sharedInstance] closePageWithResult:result animated:animated];
}

+ (void)closePage {
    [[UrlRouter sharedInstance] closePageWithResult:nil animated:YES];
}

+ (void)closePageWithResult:(NSDictionary *)result {
    [[UrlRouter sharedInstance] closePageWithResult:result animated:YES];
}

- (void)closeSelfAndOtherPages:(NSArray<NSString *> *)otherPages {
    if (otherPages && otherPages.count > 0) {
        UINavigationController *navController = self.navigationController;
        
        // 检查下导航栈中是否有需要被移除的VC
        NSMutableArray *vcs = [[NSMutableArray alloc] initWithArray:navController.viewControllers];
        for (NSInteger index = vcs.count - 2; index >= 0; --index) {
            UIViewController *vc = vcs[index];
            
            if ([otherPages containsObject:vc.vcPageName]) {
                [vcs removeObjectAtIndex:index];
            }
        }
        if (vcs.count != navController.viewControllers.count) {
            [navController setViewControllers:vcs];
        }
    }
    
    [UrlRouter closePage];
}

+ (void)closeToPage:(NSString *)pageName {
    UIViewController *viewController = [[UrlRouter sharedInstance] viewControllerMatchedWithPageName:pageName];
    [[UrlRouter sharedInstance] popToViewController:viewController animated:YES];
}

@end

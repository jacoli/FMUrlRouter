//
//  UrlRouter.m
//  MyDemo
//
//  Created by chuange.lcg on 16/3/29.
//  Copyright © 2016年 lcg. All rights reserved.
//

#import "UrlRouter.h"
#import "NSURL+UrlRouter.h"

@interface UIViewController (UrlRouter_inner)

- (void)parseInputParams;

@end

@implementation UIViewController (UrlRouter_inner)

- (void)parseInputParams {
    if (self.urlParams) {
        [self.urlParams enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, id obj, BOOL *stop) {
            [self setValue:obj forKeyPath:propertyName];
        }];
    }
}

- (void)setValue:(nullable id)value forUndefinedKey:(NSString *)key {
}

@end

@interface UrlRouter ()

@property (nonatomic, strong) Class h5ContainerClass;
@property (nonatomic, weak) UINavigationController *navigationController;

/**
 *  Native页面配置，key为页面名称kind of NSString，value为类名kind of NSString
 */
@property (nonatomic, strong) NSMutableDictionary *nativePages;

/**
 *  schemes
 */
@property (nonatomic, strong) NSMutableArray *supportedSchemes;

/**
 *  Native页面Url的Scheme
 */
@property (nonatomic, copy) NSString *nativeUrlScheme;

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
        self.supportedSchemes = [[NSMutableArray alloc] initWithArray:@[@"http", @"https"]];
    }
    return self;
}

- (void)startupWithNavController:(UINavigationController *)navigationController
               webContainerClass:(Class)webContainerClass
                 nativeUrlScheme:(NSString *)nativeUrlScheme {
    self.navigationController = navigationController;
    self.h5ContainerClass = webContainerClass;
    
    if (nativeUrlScheme) {
        [self.supportedSchemes addObject:nativeUrlScheme];
        self.nativeUrlScheme = nativeUrlScheme;
    }
    
    NSLog(@"Registered %@ pages total.", @(self.nativePages.count));
    [self.nativePages enumerateKeysAndObjectsUsingBlock:^(NSString *pageName, NSString *className, BOOL * _Nonnull stop) {
        NSLog(@"Page(%@) registered with class [%@].", pageName, className);
    }];
}

- (BOOL)handleApplicationUrl:(NSURL *)url {
    NSLog(@"Handle url %@", url.absoluteString);
    if ([self openUrl:url withParams:nil animated:YES withCallback:nil]) {
        return YES;
    }
    else {
        NSLog(@"Failed response to url.");
        return NO;
    }
}

- (NSMutableDictionary *)nativePages {
    if (!_nativePages) {
        _nativePages = [[NSMutableDictionary alloc] init];
    }
    
    return _nativePages;
}

- (BOOL)checkValidOfPageName:(NSString *)pageName className:(NSString *)className {
    if (pageName.length == 0 || className.length == 0) {
        return NO;
    }
    
    return YES;
}

- (void)registerPage:(NSString *)pageName forViewControllerClass:(Class)clazz {
    if (pageName.length > 0 && clazz != nil) {
        NSString *className = NSStringFromClass(clazz);
        if ([self checkValidOfPageName:pageName className:className]) {
            self.nativePages[pageName] = className;
        }
    }
}

+ (void)registerPage:(NSString *)pageName forViewControllerClass:(Class)clazz {
    [[UrlRouter sharedInstance] registerPage:pageName forViewControllerClass:clazz];
}

/**
 *  页面是否存在
 */
- (BOOL)isPageExists:(NSString *)pageName {
    if (pageName.length == 0) {
        return NO;
    }
    
    // 检查下导航栈中是否有VC
    NSMutableArray *vcs = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
    for (NSInteger index = vcs.count - 1; index >= 0; --index) {
        UIViewController *vc = vcs[index];
        
        if ([pageName isEqualToString:[vc pageName]]) {
            return YES;
        }
    }
    
    return NO;
}

- (NSString *)currentPageName {
    return [self.navigationController.topViewController pageName];
}

#pragma mark - Open

- (NSString *)pageNameFromUrl:(NSString *)urlString {
    if (urlString.length > 0) {
        NSRange searchedRange = [urlString rangeOfString:@"://"];
        if (searchedRange.length > 0) {
            urlString = [urlString substringFromIndex:searchedRange.location + searchedRange.length];
        }
        
        searchedRange = [urlString rangeOfString:@"?"];
        if (searchedRange.length > 0) {
            urlString = [urlString substringToIndex:searchedRange.location];
        }
        
        return urlString;
    }
    
    return nil;
}

// 打开本地页面
- (BOOL)openPage:(NSString *)pageName
      withParams:(NSDictionary *)params
        callback:(UrlCallback)callback
        animated:(BOOL)animated {
    if (pageName.length == 0) return NO;
    
    NSString *className = self.nativePages[pageName];
    if (className.length == 0) return NO;
    
    Class cls = NSClassFromString(className);
    if (!cls) return NO;
    
    if (!self.navigationController) return NO;
    
    if ([cls isSingletonPage]) {
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([[vc pageName] isEqualToString:pageName]) {
                [self configVCBeforePush:vc params:params callback:callback];
                [self.navigationController popToViewController:vc animated:animated];
                return YES;
            }
        }
    }
    
    UIViewController *vc = [[cls alloc] init];
    [self configVCBeforePush:vc params:params callback:callback];
    [self.navigationController pushViewController:vc animated:animated];
    return YES;
}

- (void)configVCBeforePush:(UIViewController *)vc
                    params:(NSDictionary *)params
                  callback:(UrlCallback)callback {
    vc.urlCallback = callback;
    vc.urlParams = params;
    [vc parseInputParams];
    vc.fromPage = [self.navigationController.topViewController pageName];
}

+ (void)openPage:(NSString *)pageName {
    [[UrlRouter sharedInstance] openPage:pageName withParams:nil callback:nil animated:YES];
}

+ (void)openPage:(NSString *)pageName withParams:(NSDictionary *)params {
    [[UrlRouter sharedInstance] openPage:pageName withParams:params callback:nil animated:YES];
}

+ (void)openPage:(NSString *)pageName withParams:(NSDictionary *)params withCallback:(UrlCallback)callback {
    [[UrlRouter sharedInstance] openPage:pageName withParams:params callback:callback animated:YES];
}

- (BOOL)openLocalUrl:(NSURL *)url
          withParams:(NSDictionary *)params
            animated:(BOOL)animated
        withCallback:(UrlCallback)callback {
    if (!url) {
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
    
    NSString *pageName = [self pageNameFromUrl:[url absoluteString]];
    return [self openPage:pageName withParams:allParams callback:callback animated:animated];
}

- (BOOL)openH5Url:(NSURL *)url withParams:(NSDictionary *)params animated:(BOOL)animated withCallback:(UrlCallback)callback {
    if (self.h5ContainerClass && self.navigationController) {
        UIViewController *vc = [[self.h5ContainerClass alloc] init];
        vc.h5Url = [url absoluteString];
        [self configVCBeforePush:vc params:params callback:callback];
        [self.navigationController pushViewController:vc animated:animated];
    }
    
    return NO;
}

- (BOOL)openUrl:(NSURL *)url
     withParams:(NSDictionary *)params
       animated:(BOOL)animated
   withCallback:(UrlCallback)callback {
    if (!url) {
        return NO;
    }
    
    NSString *scheme = url.scheme;
    
    if (![self.supportedSchemes containsObject:scheme]) {
        return NO;
    }
    
    // local url
    if ([scheme isEqualToString:self.nativeUrlScheme]) {
        return [self openLocalUrl:url withParams:params animated:animated withCallback:callback];
    }
    // http/https url
    else {
        return [self openH5Url:url withParams:params animated:animated withCallback:callback];
    }
}

+ (BOOL)openUrl:(NSURL *)url {
    return [self openUrl:url withParams:nil animated:YES withCallback:nil];
}

+ (BOOL)openUrl:(NSURL *)url animated:(BOOL)animated {
    return [self openUrl:url withParams:nil animated:animated withCallback:nil];
}

+ (BOOL)openPage:(NSString *)pageName withparams:(NSDictionary *)params animated:(BOOL)animated {
    return [[UrlRouter sharedInstance] openPage:pageName withParams:params callback:nil animated:animated];
}

+ (BOOL)openUrl:(NSURL *)url animated:(BOOL)animated withCallback:(UrlCallback)callback {
    return [self openUrl:url withParams:nil animated:animated withCallback:callback];
}

+ (BOOL)openUrl:(NSURL *)url withParams:(NSDictionary *)params {
    return [self openUrl:url withParams:params animated:YES withCallback:nil];
}

+ (BOOL)openUrl:(NSURL *)url withParams:(NSDictionary *)params animated:(BOOL)animated withCallback:(UrlCallback)callback {
    return [[UrlRouter sharedInstance] openUrl:url withParams:params animated:animated withCallback:callback];
}

#pragma mark - Close

/**
 *  延迟执行返回Callback
 */
+ (void)invokeReturnCallbackAfterWithResult:(NSDictionary *)result ofViewController:(UIViewController *)viewController {
    if (viewController) {
        UrlCallback callback = viewController.urlCallback;
        if (callback) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                callback(result);
            });
        }
    }
}

+ (void)closePage {
    [self invokeReturnCallbackAfterWithResult:nil ofViewController:[UrlRouter sharedInstance].navigationController.topViewController];
    [[UrlRouter sharedInstance].navigationController popViewControllerAnimated:YES];
}

+ (void)closeSelfAndOtherPages:(NSArray<NSString *> *)otherPages {
    if (otherPages && otherPages.count > 0) {
        UINavigationController *navController = [UrlRouter sharedInstance].navigationController;
        
        // 检查下导航栈中是否有需要被移除的VC
        NSMutableArray *vcs = [[NSMutableArray alloc] initWithArray:navController.viewControllers];
        for (NSInteger index = vcs.count - 2; index >= 0; --index) {
            UIViewController *vc = vcs[index];
            
            if ([otherPages containsObject:[vc pageName]]) {
                [vcs removeObjectAtIndex:index];
                break;
            }
        }
        if (vcs.count != navController.viewControllers.count) {
            [navController setViewControllers:vcs];
        }
    }
    
    [self closePage];
}

+ (void)closePageWithResult:(NSDictionary *)result {
    [self invokeReturnCallbackAfterWithResult:result  ofViewController:[UrlRouter sharedInstance].navigationController.topViewController];
    [[UrlRouter sharedInstance].navigationController popViewControllerAnimated:YES];
}

@end

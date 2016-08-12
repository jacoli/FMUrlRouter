//
//  UIViewController+UrlRouter.m
//  Fanmei
//
//  Created by 李传格 on 16/4/20.
//  Copyright © 2016年 Fanmei. All rights reserved.
//

#import "UIViewController+UrlRouter.h"
#import <objc/runtime.h>
#import "NSString+UrlRouter.h"

@implementation UIViewController (UrlRouter)

+ (NSString *)pageName {
    return nil;
}

- (NSString *)pageName {
    if (self.h5Url) {
        return [self.h5Url urlRouter_toBaseUrl];
    }
    else {
        return [self.class pageName];
    }
}

static int kUrlParams;
- (NSDictionary *)urlParams {
    NSDictionary *params = objc_getAssociatedObject(self, &kUrlParams);
    return params ?: @{};
}

- (void)setUrlParams:(NSDictionary *)urlParams {
    objc_setAssociatedObject(self, &kUrlParams, urlParams, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static int kFromPage;
- (NSString *)fromPage {
    return objc_getAssociatedObject(self, &kFromPage);
}

- (void)setFromPage:(NSString *)fromPage {
    objc_setAssociatedObject(self, &kFromPage, fromPage, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

static int kUrlCallback;
- (UrlCallback)urlCallback {
    return objc_getAssociatedObject(self, &kUrlCallback);
}

- (void)setUrlCallback:(UrlCallback)urlCallback {
    objc_setAssociatedObject(self, &kUrlCallback, urlCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

static int kH5Url;
- (NSString *)h5Url {
    return objc_getAssociatedObject(self, &kH5Url);
}

- (void)setH5Url:(NSString *)h5Url {
    if (h5Url && ![h5Url isKindOfClass:[NSString class]]) {
        if ([h5Url isKindOfClass:[NSURL class]]) {
            h5Url = [((NSURL *)h5Url) absoluteString];
        }
        else {
            return;
        }
    }
    
    objc_setAssociatedObject(self, &kH5Url, h5Url, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (BOOL)isSingletonPage {
    return NO;
}

@end

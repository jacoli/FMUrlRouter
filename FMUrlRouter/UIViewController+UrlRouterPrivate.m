//
//  UIViewController+UrlRouterPrivate.m
//  Fanmei
//
//  Created by 李传格 on 2017/6/27.
//  Copyright © 2017年 Fanmei. All rights reserved.
//

#import "UIViewController+UrlRouterPrivate.h"
#import <objc/runtime.h>

@implementation UIViewController (UrlRouterPrivate)

static int kVCPageName;
- (NSString *)vcPageName {
    return objc_getAssociatedObject(self, &kVCPageName);
}

- (void)setVcPageName:(NSString *)vcPageName {
    objc_setAssociatedObject(self, &kVCPageName, vcPageName, OBJC_ASSOCIATION_COPY_NONATOMIC);
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
- (FMUrlPopedCallback)urlCallback {
    return objc_getAssociatedObject(self, &kUrlCallback);
}

- (void)setUrlCallback:(FMUrlPopedCallback)urlCallback {
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

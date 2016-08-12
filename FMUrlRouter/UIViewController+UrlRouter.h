//
//  UIViewController+UrlRouter.h
//  Fanmei
//
//  Created by 李传格 on 16/4/20.
//  Copyright © 2016年 Fanmei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UrlCallback)(NSDictionary *userInfo);

@interface UIViewController (UrlRouter)

// 页面名称，默认为nil，to be override
+ (NSString *)pageName;

/**
 *  页面名称，如果h5Url有值则返回h5Url，默认返回`+[self.class pageName]`，to be override
 */
- (NSString *)pageName;

/**
 *  额外参数，可选
 */
@property (nonatomic, strong) NSDictionary *urlParams;

/**
 *  上个页面名称，必选
 */
@property (nonatomic, copy) NSString *fromPage;

/**
 *  url链接地址，可选
 */
@property (nonatomic, copy) NSString *h5Url;

/**
 *  回调Block，可选
 */
@property (nonatomic, copy) UrlCallback urlCallback;

/**
 *  是否允许在导航栈中存在多个实例
 */
+ (BOOL)isSingletonPage;

@end

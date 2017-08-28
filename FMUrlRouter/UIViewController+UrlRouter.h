//
//  UIViewController+UrlRouter.h
//  Fanmei
//
//  Created by 李传格 on 2017/6/27.
//  Copyright © 2017年 Fanmei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UrlRouterDefines.h"

NS_ASSUME_NONNULL_BEGIN

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

NS_ASSUME_NONNULL_END

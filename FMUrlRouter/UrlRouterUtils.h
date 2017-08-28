//
//  UrlRouterUtils.h
//  Examples
//
//  Created by 李传格 on 2017/8/28.
//  Copyright © 2017年 fanmei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UrlRouter)

/**
 *  返回Url中"?"之前的字符串
 */
- (NSString *)urlRouter_toBaseUrl;

@end

@interface NSURL (UrlRouter)

/**
 *  返回Url Query参数
 */
- (NSDictionary *)urlRouter_params;

@end

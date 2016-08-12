//
//  NSString+UrlRouter.h
//  Fanmei
//
//  Created by 李传格 on 16/8/10.
//  Copyright © 2016年 Fanmei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UrlRouter)

/**
 *  返回Url中"?"之前的字符串
 */
- (NSString *)urlRouter_toBaseUrl;

@end

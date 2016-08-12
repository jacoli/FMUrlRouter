//
//  NSURL+UrlRouter.h
//  Fanmei
//
//  Created by 李传格 on 16/8/10.
//  Copyright © 2016年 Fanmei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (UrlRouter)

/**
 *  返回Url Query参数
 */
- (NSDictionary *)urlRouter_params;

@end

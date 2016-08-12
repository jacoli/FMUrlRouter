//
//  NSString+UrlRouter.m
//  Fanmei
//
//  Created by 李传格 on 16/8/10.
//  Copyright © 2016年 Fanmei. All rights reserved.
//

#import "NSString+UrlRouter.h"

@implementation NSString (UrlRouter)

- (NSString *)urlRouter_toBaseUrl {
    NSRange rangeOfString = [self rangeOfString:@"?"];
    if (rangeOfString.length > 0) {
        return [self substringToIndex:rangeOfString.location];
    }
    else {
        return self;
    }
}

@end

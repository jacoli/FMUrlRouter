//
//  NSURL+UrlRouter.m
//  Fanmei
//
//  Created by 李传格 on 16/8/10.
//  Copyright © 2016年 Fanmei. All rights reserved.
//

#import "NSURL+UrlRouter.h"

@implementation NSURL (UrlRouter)

- (NSDictionary *)urlRouter_params {
    NSString *query = [self query];
    if (query.length > 0) {
        query = [query stringByRemovingPercentEncoding];
        
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        
        // Handle & or ; as separators, as per W3C recommendation
        NSCharacterSet *seperatorChars = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
        NSArray *keyValues = [query componentsSeparatedByCharactersInSet:seperatorChars];
        NSEnumerator *theEnum = [keyValues objectEnumerator];
        NSString *keyValuePair;
        
        while (nil != (keyValuePair = [theEnum nextObject]) )
        {
            NSRange whereEquals = [keyValuePair rangeOfString:@"="];
            if (NSNotFound != whereEquals.location)
            {
                NSString *key = [keyValuePair substringToIndex:whereEquals.location];
                NSString *value = [keyValuePair substringFromIndex:whereEquals.location+1];
                [result setValue:value forKey:key];
            }
        }
        return result;
    }
    
    return @{};
}

@end

//
//  UrlRouterConfig.h
//  Fanmei
//
//  Created by 李传格 on 2017/6/21.
//  Copyright © 2017年 Fanmei. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UrlRouterContainerMode) {
    UrlRouterContainerModeOnlyNavigation = 0,
    UrlRouterContainerModeNavigationAndTabBar
};

@interface UrlRouterConfig : NSObject

#pragma mark - container

@property (nonatomic, assign) UrlRouterContainerMode mode;
@property (nonatomic, strong) Class navigationControllerClass;
@property (nonatomic, strong) Class tabBarControllerClass;

#pragma mark - schemes

@property (nonatomic, strong) Class webContainerClass;
@property (nonatomic, copy) NSString *nativeUrlScheme;
@property (nonatomic, copy) NSString *nativeUrlHostName;

@end

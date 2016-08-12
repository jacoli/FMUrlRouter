# FMUrlRouter
![Version](https://img.shields.io/badge/pod-1.0.0-yellow.svg)
![License](https://img.shields.io/badge/License-MIT-blue.svg)
![Platform](https://img.shields.io/badge/Platform-iOS-orange.svg)
![Platform](https://img.shields.io/badge/Build-Passed-green.svg)

* A simple way to manage page route of native or h5. 页面统一跳转管理器


## Installation

With [CocoaPods](http://cocoapods.org/), add this line to your `Podfile`.

```
pod 'FMUrlRouter'
```

and run `pod install`, then you're all done!

Or copy `*.h *.m` files in `FMUrlRouter` folder to your project.

## How to use

* Setup

Setup in `AppDelegate`

```
	#define URL_ROUTER_LOCAL_SCHEME (@"fanmei")

    [[UrlRouter sharedInstance] startupWithNavController:(UINavigationController *)rootVC
                                       	webContainerClass:FMWebViewController.class
                                         	nativeUrlScheme:URL_ROUTER_LOCAL_SCHEME];
```

Setup in UIViewController subclass

```
+ (void)load {
    [UrlRouter registerPage:self.pageName forViewControllerClass:self.class];
}

+ (NSString *)pageName {
    return @"about_us";
}

```


* Use

Open native page

```
	[UrlRouter openPage:@"about_us"];

```

Open page with callback

```
    WS(weakSelf)
    [UrlRouter openPage:@"comments_list" withParams:@{@"_id":self.activityId} withCallback:^(NSDictionary *userInfo) {
        [weakSelf getComments];
    }];
```

Open native url

```
	    NSString *query = @"placeName=江户前寿司（黄龙店）&placeAddr=曙光路49号（至尊鲨鱼边）&placeLocation=120.14334,30.26593";
    query = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *urlStr = [NSString stringWithFormat:@"fanmei://detail_address?%@", query];
    [UrlRouter openUrl:[NSURL URLWithString:urlStr]];

```

Open url

```
	NSString *url = "https://github.com/jacoli/FMUrlRouter";
	[UrlRouter openUrl:[NSURL URLWithString:url]];

```



## Requirements

* iOS 7.0+ 
* ARC
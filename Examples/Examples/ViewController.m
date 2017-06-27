//
//  ViewController.m
//  Examples
//
//  Created by 李传格 on 2017/6/27.
//  Copyright © 2017年 fanmei. All rights reserved.
//

#import "ViewController.h"
#import "UrlRouter.h"

@interface ViewController ()

@end

@implementation ViewController

- (instancetype)init {
    if (self = [super init]) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemRecents tag:0];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = self.vcPageName;
    
    self.view.backgroundColor = [UIColor grayColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"open page" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    btn.frame = CGRectMake(100, 100, 100, 50);
}

- (void)onClicked {
    [UrlRouter openPage:@"page1"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

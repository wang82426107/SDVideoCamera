//
//  AppDelegate.m
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/26.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    ViewController *viewController = [[ViewController alloc] init];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    

    
    return YES;
}


@end

//
//  SDVideoController.h
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/18.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDVideoConfig.h"
#import "SDVideoCameraController.h"

@interface SDVideoController : UINavigationController

// SDVideoController 是仿写抖音录制一个库

- (instancetype)initWithCameraConfig:(SDVideoConfig *)config;

@property(nonatomic,strong)SDVideoCameraController *cameraController;

@end


//
//  SDVideoCameraController.h
//  FamilyClassroom
//
//  Created by 王巍栋 on 2020/1/13.
//  Copyright © 2020 Dong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDVideoConfig.h"
#import "SDVideoCameraMenuView.h"

@interface SDVideoCameraController : UIViewController

// SDVideoCameraController 是录制的控制器

- (instancetype)initWithCameraConfig:(SDVideoConfig *)config;

// 控制层视图,方便开发者自己定制
@property(nonatomic,strong)SDVideoCameraMenuView *menuView;

@end


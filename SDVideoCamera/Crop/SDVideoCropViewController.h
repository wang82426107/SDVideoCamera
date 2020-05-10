//
//  SDVideoCropViewController.h
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/19.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDVideoConfig.h"
#import <AVFoundation/AVFoundation.h>

@interface SDVideoCropViewController : UIViewController

// SDVideoCropViewController 是视频裁剪的主体功能类

- (instancetype)initWithCameraConfig:(SDVideoConfig *)config videoAssetArray:(NSArray <AVAsset *>*)videoAssetArray;

@end

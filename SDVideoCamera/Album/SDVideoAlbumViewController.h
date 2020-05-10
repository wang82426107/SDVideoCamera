//
//  SDVideoAlbumViewController.h
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/19.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDVideoConfig.h"

@protocol SDVideoAlbumViewControllerDelegate <NSObject>

@optional

- (void)userFinishSelectWithVideoAssetArray:(NSArray <AVAsset *>*)videoAssetArray;

@end


@interface SDVideoAlbumViewController : UIViewController

// SDVideoAlbumViewController 是相册选择的控制器

- (instancetype)initWithCameraConfig:(SDVideoConfig *)config;

@property(nonatomic,weak)id <SDVideoAlbumViewControllerDelegate>delegate;

@property(nonatomic,assign)BOOL isFinishReturn;

@end

//
//  SDVideoPreviewViewController.h
//  FamilyClassroom
//
//  Created by 王巍栋 on 2020/1/15.
//  Copyright © 2020 Dong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDVideoConfig.h"

@interface SDVideoPreviewViewController : UIViewController

// SDVideoPreviewViewController是视频预览界面的控制器,没有合成功能,只是顺序播放

- (instancetype)initWithCameraConfig:(SDVideoConfig *)config
                            playItem:(AVPlayerItem *)playItem
                     videoAssetArray:(NSArray <AVAsset *>*)videoAssetArray
                       playTimeRange:(CMTimeRange)playTimeRange;

@end

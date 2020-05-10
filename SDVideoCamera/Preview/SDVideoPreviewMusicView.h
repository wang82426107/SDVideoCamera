//
//  SDVideoPreviewMusicView.h
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/30.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDVideoConfig.h"

@class SDVideoMusicModel;

@protocol SDVideoMusicDelegate <NSObject>

@optional

- (void)userSelectbackgroundMusicWithDataModel:(SDVideoMusicModel *)dataModel musicVolume:(CGFloat)musicVolume;

- (void)userChangeOriginalVolume:(CGFloat)originalVolume musicVolume:(CGFloat)musicVolume;

@end


@interface SDVideoPreviewMusicView : UIView

// SDVideoPreviewMusicView 是配乐选择的视图

- (instancetype)initWithFrame:(CGRect)frame config:(SDVideoConfig *)config superViewController:(UIViewController *)superViewController;

- (void)showViewAction;

- (void)dismissViewAction;

@property(nonatomic,weak)id <SDVideoMusicDelegate>delegate;

@end

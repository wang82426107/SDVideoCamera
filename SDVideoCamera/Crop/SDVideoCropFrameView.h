//
//  SDVideoCropFrameView.h
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/22.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDVideoCropHeader.h"
#import "SDVideoCropDataManager.h"

@interface SDVideoCropFrameView : UIView

// SDVideoCropFrameView 是视频截取显示帧图的视图

- (instancetype)initWithFrame:(CGRect)frame dataManager:(SDVideoCropDataManager *)dataManager;

- (void)reloadPlayTimeRangeAction;

@property(nonatomic,weak)id <SDVideoCropVideoDragDelegate>delegate;

@end


//
//  SDVideoCropItemListView.h
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/27.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDVideoCropDataManager.h"

@interface SDVideoCropItemListView : UIView

// SDVideoCropItemView 是视频媒体列表视图

- (instancetype)initWithFrame:(CGRect)frame dataManager:(SDVideoCropDataManager *)dataManager;


@end

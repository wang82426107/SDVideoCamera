//
//  SDVideoCropBottomView.h
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/20.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDVideoCropHeader.h"
#import "SDVideoCropDataManager.h"

@interface SDVideoCropBottomView : UIView

// SDVideoCropBottomView 是合成预览底部视图

- (instancetype)initWithFrame:(CGRect)frame dataManager:(SDVideoCropDataManager *)dataManager;

@property(nonatomic,weak)id <SDVideoCropVideoDragDelegate>delegate;

@end

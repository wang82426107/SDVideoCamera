//
//  SDVideoCameraAuthoView.h
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/29.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDVideoCameraAuthoView.h"

@protocol SDVideoCameraAuthoDelegate <NSObject>

@optional

/// 用户打开了所有的权限
- (void)userOpenAllDerviceAuthoAction;

@end

@interface SDVideoCameraAuthoView : UIView

// SDVideoCameraAuthoView 是相机权限展示视图

@property(nonatomic,weak)id <SDVideoCameraAuthoDelegate>delegate;

/// 检测权限状态,更改UI
- (void)testAuthoStateAction;

@end

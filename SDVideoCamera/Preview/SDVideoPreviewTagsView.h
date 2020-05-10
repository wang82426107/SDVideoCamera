//
//  SDVideoPreviewTagsView.h
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/5/5.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDVideoConfig.h"
#import "SDVideoPreviewEffectModel.h"

@protocol SDVideoPreviewTagsDelegate <NSObject>

@optional

- (void)userFinishSelectTagWithDataModel:(SDVideoPreviewEffectModel *)dataModel;

@end

@interface SDVideoPreviewTagsView : UIView

// SDVideoPreviewTagsView 是预览界面的贴纸视图.

- (instancetype)initWithFrame:(CGRect)frame config:(SDVideoConfig *)config;

- (void)showViewAction;

- (void)dismissViewAction;

@property(nonatomic,weak)id <SDVideoPreviewTagsDelegate>delegate;

@end


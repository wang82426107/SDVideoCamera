//
//  SDVideoPreviewTextView.h
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/5/1.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDVideoConfig.h"
#import "SDVideoPreviewEffectModel.h"

@protocol SDVideoPreviewTextDelegate <NSObject>

@optional

- (void)userFinishInputTextWithDataModel:(SDVideoPreviewEffectModel *)dataModel;

@end

@interface SDVideoPreviewTextView : UIView

// SDVideoPreviewTextView 是文本输入的视图

- (instancetype)initWithFrame:(CGRect)frame config:(SDVideoConfig *)config;

- (void)showViewAction;

- (void)dismissViewAction;

@property(nonatomic,weak)id <SDVideoPreviewTextDelegate>delegate;

@end

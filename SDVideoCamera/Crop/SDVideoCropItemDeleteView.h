//
//  SDVideoCropItemDeleteView.h
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/27.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDVideoCropDataManager.h"

@protocol SDVideoCropItemDeleteViewDelegate <NSObject>

@optional

- (void)userDeletVideoAssetWithIndexRow:(NSInteger)indexRow;

@end


@interface SDVideoCropItemDeleteView : UIView

// SDVideoCropItemDeleteView 是删除单个资源的视图

- (instancetype)initWithFrame:(CGRect)frame dataManager:(SDVideoCropDataManager *)dataManager;

@property(nonatomic,strong)UIImage *selectImage;
@property(nonatomic,assign)NSInteger indexRow;
@property(nonatomic,weak)id <SDVideoCropItemDeleteViewDelegate>delegate;

@end


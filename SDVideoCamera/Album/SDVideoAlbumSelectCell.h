//
//  SDVideoAlbumSelectCell.h
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/19.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@protocol SDVideoAlbumSelectCellDelegate <NSObject>

@optional
- (void)userDeleteVideoWithDataIndex:(NSNumber *)dataIndex;

@end

@interface SDVideoAlbumSelectCell : UICollectionViewCell

// SDVideoAlbumSelectCell 是视频选择完成的Cell

@property(nonatomic,copy)NSNumber *dataIndex;
@property(nonatomic,strong)UIImage *bgImage;
@property(nonatomic,strong)PHAsset *asset;

@property(nonatomic,weak)id <SDVideoAlbumSelectCellDelegate>delegate;

@end

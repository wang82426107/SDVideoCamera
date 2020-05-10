//
//  SDVideoAlbumCell.h
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/19.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface SDVideoAlbumCell : UICollectionViewCell

// SDVideoAlbumCell是视频列表展示的Cell

@property(nonatomic,strong)UIImage *bgImage;
@property(nonatomic,strong)PHAsset *asset;
@property(nonatomic,assign)int selectNumber;

@end

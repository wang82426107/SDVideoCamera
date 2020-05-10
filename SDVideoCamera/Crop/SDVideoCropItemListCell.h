//
//  SDVideoCropItemListCell.h
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/27.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface SDVideoCropItemListCell : UICollectionViewCell

@property(nonatomic,strong)AVAsset *videoAsset;
@property(nonatomic,strong)UIImage *videoImage;

@end


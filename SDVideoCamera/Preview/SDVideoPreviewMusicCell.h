//
//  SDVideoPreviewMusicCell.h
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/30.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDVideoMusicModel.h"

@interface SDVideoPreviewMusicCell : UICollectionViewCell

// SDVideoPreviewMusicCell 是配乐的Cell

@property(nonatomic,strong)SDVideoMusicModel *dataModel;
@property(nonatomic,assign)BOOL isSelect;

@end

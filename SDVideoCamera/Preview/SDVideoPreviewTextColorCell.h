//
//  SDVideoPreviewTextColorCell.h
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/5/2.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDVideoPreviewTextColorCell : UICollectionViewCell

// SDVideoPreviewTextColorCell 是字体颜色的Cell

@property(nonatomic,copy)NSString *hexColorString;
@property(nonatomic,assign)BOOL isSelect;

@end


//
//  SDVideoPreviewMusicSlider.h
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/5/1.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDVideoPreviewMusicSlider : UISlider

@property(nonatomic,assign)BOOL isUserInterface;
@property(nonatomic,strong)UIColor *valueTextColor;
@property(nonatomic,strong)UIFont *valueFont;
@property(nonatomic,copy)NSString *valueText;

@end


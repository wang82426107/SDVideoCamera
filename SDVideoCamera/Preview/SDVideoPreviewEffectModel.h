//
//  SDVideoPreviewEffectModel.h
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/5/8.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    EffectDataTypeNone,
    EffectDataTypeText,
    EffectDataTypeImage,
} EffectDataType;

@interface SDVideoPreviewEffectModel : NSObject

// SDVideoPreviewEffectModel 是特效的Model,包括文字和图片

@property(nonatomic,assign)EffectDataType type;

@property(nonatomic,copy)NSString *text;

@property(nonatomic,strong)UIFont *textFont;

@property(nonatomic,assign)CGFloat textFontSize;

@property(nonatomic,strong)UIColor *textColor;

@property(nonatomic,strong)UIColor *backgroundColor;

@property(nonatomic,strong)UIImage *image;

@property(nonatomic,assign)CGSize contentSize;

@end


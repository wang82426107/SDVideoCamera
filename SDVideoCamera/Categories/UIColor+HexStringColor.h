//
//  UIColor+HexStringColor.h
// ChildMusicTeacher
//
//  Created by bnqc on 2018/12/7.
//  Copyright © 2018年 Dong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexStringColor)

// HexStringColor 是16进制颜色

+ (UIColor *)hexStringToColor:(NSString *)stringToConvert;

+ (UIColor *)hexStringToColor:(NSString *)stringToConvert alpha:(CGFloat)alpha;

@end

//
//  UIColor+HexStringColor.m
// ChildMusicTeacher
//
//  Created by bnqc on 2018/12/7.
//  Copyright © 2018年 Dong. All rights reserved.
//

#import "UIColor+HexStringColor.h"

@implementation UIColor (HexStringColor)

+ (UIColor *)hexAlphaStringToColor:(NSString *)stringToConvert alpha:(CGFloat)alpha {
    NSString *cString = [[stringToConvert
                          stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
        return [UIColor blackColor];
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor blackColor];
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f)
                           green:((float)g / 255.0f)
                            blue:((float)b / 255.0f)
                           alpha:alpha];
}

+ (UIColor *)hexStringToColor:(NSString *)stringToConvert {
    return [UIColor hexAlphaStringToColor:stringToConvert alpha:1.0f];
}

+ (UIColor *)hexStringToColor:(NSString *)stringToConvert alpha:(CGFloat)alpha {
    return [UIColor hexAlphaStringToColor:stringToConvert alpha:alpha];
}

@end

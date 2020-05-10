//
//  NSString+Size.m
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/30.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "NSString+Size.h"

@implementation NSString (Size)

- (CGFloat)heightWithTextFont:(UIFont *)textFont andWidth:(CGFloat)width {
    
    return [self textSizeWithTextFont:textFont width:width height:0].width;
}

- (CGFloat)widthWithTextFont:(UIFont *)textFont andHeight:(CGFloat)height {
    
    return [self textSizeWithTextFont:textFont width:0 height:height].height;
}

- (CGSize)textSizeWithTextFont:(UIFont *)textFont width:(float)width height:(float)height {
    
    int nowWidth = 0;
    int nowHeight = 0;
    if (width != 0) {
        nowWidth =width;
    }else{
        nowWidth =CGFLOAT_MAX;
    }
    if (height != 0) {
        nowHeight =height;
    }else{
        nowHeight =CGFLOAT_MAX;
    }
    if (textFont == nil) {
        textFont = [UIFont systemFontOfSize:14];
    }
    CGSize newSizeToFit = [self boundingRectWithSize:CGSizeMake(nowWidth,nowHeight) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : textFont} context:nil].size;
    return newSizeToFit;
}

@end

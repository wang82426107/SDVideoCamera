//
//  UIButton+imageTitleLayout.m
//  
//
//  Created by 韩保玉 on 15/6/28.
//  Copyright (c) 2015年 韩保玉. All rights reserved.
//

#import "UIButton+EdgeInsets.h"

@implementation UIButton (EdgeInsets)

- (void)layoutButtonWithEdgeInsetsStyle:(ButtonEdgeInsetsStyle)style imageTitlespace:(CGFloat)space {
    CGFloat imageViewWidth = CGRectGetWidth(self.imageView.frame);
    CGFloat labelWidth = CGRectGetWidth(self.titleLabel.frame);
    
    if (labelWidth == 0) {
        CGSize titleSize = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}];
        labelWidth  = titleSize.width;
    }
    
    CGFloat imageInsetsTop = 0.0f;
    CGFloat imageInsetsLeft = 0.0f;
    CGFloat imageInsetsBottom = 0.0f;
    CGFloat imageInsetsRight = 0.0f;
    
    CGFloat titleInsetsTop = 0.0f;
    CGFloat titleInsetsLeft = 0.0f;
    CGFloat titleInsetsBottom = 0.0f;
    CGFloat titleInsetsRight = 0.0f;
    
    switch (style) {
        case ButtonEdgeInsetsStyleImageRight:
        {
            space = space * 0.5;

            imageInsetsLeft = labelWidth + space;
            imageInsetsRight = -imageInsetsLeft;
            
            titleInsetsLeft = - (imageViewWidth + space);
            titleInsetsRight = -titleInsetsLeft;
        }
            break;
            
        case ButtonEdgeInsetsStyleImageLeft:
        {
            space = space * 0.5;

            imageInsetsLeft = -space;
            imageInsetsRight = -imageInsetsLeft;
            
            titleInsetsLeft = space;
            titleInsetsRight = -titleInsetsLeft;
        }
            break;
        case ButtonEdgeInsetsStyleImageBottom:
        {
            CGFloat imageHeight = CGRectGetHeight(self.imageView.frame);
            CGFloat labelHeight = CGRectGetHeight(self.titleLabel.frame);
            CGFloat buttonHeight = CGRectGetHeight(self.frame);
            CGFloat boundsCentery = (imageHeight + space + labelHeight) * 0.5;
            
            CGFloat centerX_button = CGRectGetMidX(self.bounds); // bounds
            CGFloat centerX_titleLabel = CGRectGetMidX(self.titleLabel.frame);
            CGFloat centerX_image = CGRectGetMidX(self.imageView.frame);
            
            CGFloat imageBottomY = CGRectGetMaxY(self.imageView.frame);
            CGFloat titleTopY = CGRectGetMinY(self.titleLabel.frame);
            
            imageInsetsTop = buttonHeight - (buttonHeight * 0.5 - boundsCentery) - imageBottomY;
            imageInsetsLeft = centerX_button - centerX_image;
            imageInsetsRight = - imageInsetsLeft;
            imageInsetsBottom = - imageInsetsTop;
            
            titleInsetsTop = (buttonHeight * 0.5 - boundsCentery) - titleTopY;
            titleInsetsLeft = -(centerX_titleLabel - centerX_button);
            titleInsetsRight = - titleInsetsLeft;
            titleInsetsBottom = - titleInsetsTop;
            
        }
            break;
            case ButtonEdgeInsetsStyleImageTop:
        {
            CGFloat imageHeight = CGRectGetHeight(self.imageView.frame);
            CGFloat labelHeight = CGRectGetHeight(self.titleLabel.frame);
            CGFloat buttonHeight = CGRectGetHeight(self.frame);
            CGFloat boundsCentery = (imageHeight + space + labelHeight) * 0.5;
            
            CGFloat centerX_button = CGRectGetMidX(self.bounds); // bounds
            CGFloat centerX_titleLabel = CGRectGetMidX(self.titleLabel.frame);
            CGFloat centerX_image = CGRectGetMidX(self.imageView.frame);
            
            CGFloat imageTopY = CGRectGetMinY(self.imageView.frame);
            CGFloat titleBottom = CGRectGetMaxY(self.titleLabel.frame);
            
            imageInsetsTop = (buttonHeight * 0.5 - boundsCentery) - imageTopY;
            imageInsetsLeft = centerX_button - centerX_image;
            imageInsetsRight = - imageInsetsLeft;
            imageInsetsBottom = - imageInsetsTop;
            
            titleInsetsTop = buttonHeight - (buttonHeight * 0.5 - boundsCentery) - titleBottom;
            titleInsetsLeft = -(centerX_titleLabel - centerX_button);
            titleInsetsRight = - titleInsetsLeft;
            titleInsetsBottom = - titleInsetsTop;
        }
            break;
            
        default:
            break;
    }
    self.imageEdgeInsets = UIEdgeInsetsMake(imageInsetsTop, imageInsetsLeft, imageInsetsBottom, imageInsetsRight);
    self.titleEdgeInsets = UIEdgeInsetsMake(titleInsetsTop, titleInsetsLeft, titleInsetsBottom, titleInsetsRight);
}

- (void)centerImageAndTitle:(CGFloat)space {
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    // get the height they will take up as a unit
//    NSLog(@"%lf-%lf",imageSize.width,imageSize.height);// 63 63
//    NSLog(@"%lf-%lf",titleSize.width,titleSize.height); // 14.5 17
//    NSLog(@"%lf-%lf",self.frame.size.width,self.frame.size.height); // 93.75 100
    CGFloat totalHeight = (imageSize.height + titleSize.height + space);
    // raise the image and push it right to center it
//    self.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), titleSize.width/2.0, 0.0, - titleSize.width);
    self.imageEdgeInsets = UIEdgeInsetsMake(-(totalHeight - imageSize.height), (self.frame.size.width - imageSize.width)/2.0, 0.0, 0);
    // lower the text and push it left to center it
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (totalHeight - titleSize.height),0.0);
}
@end

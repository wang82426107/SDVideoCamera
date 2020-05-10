//
//  NSString+Size.h
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/30.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Size)

- (CGFloat)heightWithTextFont:(UIFont *)textFont andWidth:(CGFloat)width;

- (CGFloat)widthWithTextFont:(UIFont *)textFont andHeight:(CGFloat)height;

@end

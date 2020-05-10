//
//  SDVideoCameraPlayButton.h
//  FamilyClassroom
//
//  Created by 王巍栋 on 2020/1/13.
//  Copyright © 2020 Dong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDVideoConfig.h"

typedef enum : NSUInteger {
    PlayButtonStateNomal,
    PlayButtonStateTouch,
    PlayButtonStateMove,
} PlayButtonState;

@interface SDVideoCameraPlayButton : UIView

- (instancetype)initWithFrame:(CGRect)frame config:(SDVideoConfig *)config;

@property(nonatomic,assign)PlayButtonState buttonState;

@end

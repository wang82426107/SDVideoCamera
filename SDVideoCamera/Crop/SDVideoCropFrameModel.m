//
//  SDVideoCropFrameModel.m
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/22.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDVideoCropFrameModel.h"

@implementation SDVideoCropFrameModel

- (void)setStartTime:(CMTime)startTime {
    
    _startTime = startTime;
    
    // 解决某些视频不是从kCMTimeZero开始有帧图像的情况
    if (CMTimeCompare(startTime, kCMTimeZero) == 0) {
        _startTime = CMTimeMakeWithSeconds(1, 50);
    }
}

@end

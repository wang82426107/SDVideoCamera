//
//  SDAudioPlayerManager.h
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/18.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDVideoConfig.h"

@interface SDAudioPlayerManager : NSObject

// SDAudioPlayerManager 是配音伴奏播放管理类

- (instancetype)initWithConfig:(SDVideoConfig *)config;

- (void)play;

- (void)pause;

- (void)seekToTime:(CMTime)time;

@end

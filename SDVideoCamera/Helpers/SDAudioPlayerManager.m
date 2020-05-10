//
//  SDAudioPlayerManager.m
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/18.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDAudioPlayerManager.h"
#import <AVFoundation/AVFoundation.h>

@interface SDAudioPlayerManager ()

@property(nonatomic,strong)SDVideoConfig *config;
@property(nonatomic,strong)AVPlayer *audioPlayer;

@end

@implementation SDAudioPlayerManager

- (instancetype)initWithConfig:(SDVideoConfig *)config {
    
    if (self = [super init]) {
        self.config = config;
        if (config.audioURL != nil) {
            if (@available(iOS 10.0, *)) {
                self.audioPlayer.automaticallyWaitsToMinimizeStalling = NO;
            }
            [self.audioPlayer seekToTime:CMTimeMake(1.0, 1.0) completionHandler:^(BOOL finished) {}];
        }
    }
    return self;
}

- (AVPlayer *)audioPlayer {
    
    if (_audioPlayer == nil) {
        NSURL *audioURL = self.config.audioURLType == AudioURLTypeWeb ? [NSURL URLWithString:self.config.audioURL] : [NSURL fileURLWithPath:self.config.audioURL];
        AVPlayerItem *audioItem = [[AVPlayerItem alloc] initWithURL:audioURL];
        _audioPlayer = [[AVPlayer alloc] initWithPlayerItem:audioItem];
    }
    return _audioPlayer;
}

- (void)play {
    
    [_audioPlayer play];
}

- (void)pause {
    
    [_audioPlayer pause];
}

- (void)seekToTime:(CMTime)time {
    
    [_audioPlayer seekToTime:time];
}


@end

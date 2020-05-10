//
//  SDVideoDataManager.m
//  FamilyClassroom
//
//  Created by 王巍栋 on 2020/1/13.
//  Copyright © 2020 Dong. All rights reserved.
//

#import "SDVideoDataManager.h"
#import <AVFoundation/AVFoundation.h>
#import "SDVideoUtils.h"

@interface SDVideoDataManager ()

@property (nonatomic, weak) NSTimer *videoTimer;

@end

@implementation SDVideoDataManager

static SDVideoDataManager *manager = nil;

+ (SDVideoDataManager *)defaultManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[SDVideoDataManager alloc] init];
        }
    });
    return manager;
}

- (NSTimer *)videoTimer {
    
    if (_videoTimer == nil) {
        _videoTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(videoStartTimerAction) userInfo:nil repeats:YES];
    }
    return _videoTimer;
}

- (void)videoStartTimerAction {
    
    self.totalVideoTime += 0.1;
    if (self.totalVideoTime > _videoSecondTime) {
        self.cameraState = VideoCameraStateStop;
        [_videoTimer invalidate];
        _videoTimer = nil;
    } else {
        self.progress = (float)self.totalVideoTime / (float)_videoSecondTime;
    }
}

- (void)setCameraState:(VideoCameraState)cameraState {
    
    _cameraState = cameraState;
    switch (cameraState) {
        case VideoCameraStateIdle:{
            self.progress = 0;
            self.totalVideoTime = 0;
            break;
        }
        case VideoCameraStateInProgress:{
            [self.videoTimer setFireDate:[NSDate distantPast]];
            break;
        }
        case VideoCameraStatePause:{
            [self.videoTimer setFireDate:[NSDate distantFuture]];
            break;
        }
        case VideoCameraStateStop: {
            self.progress = 1;
            break;
        }
    }
}

#pragma mark - 视频的相关操作

- (void)addVideoModel:(SDVideoDataModel *)videoModel {
    
    [_videoDataArray addObject:videoModel];
    self.videoNumber = self.videoDataArray.count;
}

- (void)deleteLastVideoModel {

    SDVideoDataModel *dataModel = _videoDataArray.lastObject;
    manager.totalVideoTime -= dataModel.duration;
    [dataModel deleteLocalVideoFileAction];
    [_videoDataArray removeLastObject];
    self.videoNumber = self.videoDataArray.count;
    
    if (self.videoNumber == 0) {
        self.cameraState = VideoCameraStateIdle;
    } else {
        self.cameraState = VideoCameraStatePause;
    }
}

- (void)deleteAllVideoModel {
    
    for (SDVideoDataModel *dataModel in _videoDataArray) {
        [dataModel deleteLocalVideoFileAction];
    }
    [_videoDataArray removeAllObjects];
    self.videoNumber = self.videoDataArray.count;
    self.cameraState = VideoCameraStateIdle;
}

#pragma mark - 设置方法

- (void)setConfig:(SDVideoConfig *)config {
    
    _config = config;
    self.totalVideoTime = 0;
    _videoDataArray = [NSMutableArray arrayWithCapacity:16];
    
    // 根据不同情况设置最大时长
    if (config.audioURL == nil) {
        // 当前没有配音伴奏URL
        _videoSecondTime = config.maxVideoDuration;
    } else {
        // 当前有配音伴奏
        if (config.durationType == MaxVideoDurationTypeAudio) {
            switch (config.audioURLType) {
                case AudioURLTypeNone:
                    _videoSecondTime = config.maxVideoDuration;
                    break;
                case AudioURLTypeLocal:
                    _videoSecondTime = [SDVideoDataManager getMediaSecondWithMediaURL:[NSURL fileURLWithPath:config.audioURL]];
                    break;
                case AudioURLTypeWeb:
                    _videoSecondTime = [SDVideoDataManager getMediaSecondWithMediaURL:[NSURL URLWithString:config.audioURL]];
                    break;
            }
        } else {
            _videoSecondTime = config.maxVideoDuration;
        }
    }
}

#pragma mark - 私有方法

// 获取媒体时长
+ (NSInteger)getMediaSecondWithMediaURL:(NSURL *)mediaURL {

    AVURLAsset *mediaAsset = [AVURLAsset assetWithURL:mediaURL];
    CMTime mediaTime = [mediaAsset duration];
    return ceil(mediaTime.value/mediaTime.timescale);
}

@end

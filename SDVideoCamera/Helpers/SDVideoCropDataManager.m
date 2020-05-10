//
//  SDVideoCropDataManager.m
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/24.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDVideoCropDataManager.h"

#import "SDVideoUtils.h"

@implementation SDVideoCropDataManager

- (instancetype)initWithCameraConfig:(SDVideoConfig *)config {
    
    if (self = [super init]) {
        _config = config;
        _minDuration = CMTimeMake(1.0, 1.0);
        _observerTimeSpace = CMTimeMake(1, 10);
        _videoArray = [NSMutableArray arrayWithCapacity:16];
    }
    return self;
}

#pragma mark - 接口方法

- (void)videoArrayAddVideoAsset:(AVAsset *)videoAsset {
    
    [[self mutableArrayValueForKey:@"videoArray"] addObject:videoAsset];
    [self reloadPlayItemAction];
    [[NSNotificationCenter defaultCenter] postNotificationName:VideoArrayItemAddNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:VideoPlayItemChangeNotificationName object:nil];
}

- (void)videoArrayAddVideoAssetArray:(NSArray <AVAsset *>*)videoAssetArray {
 
    [[self mutableArrayValueForKey:@"videoArray"] addObjectsFromArray:videoAssetArray];
    [self reloadPlayItemAction];
    [[NSNotificationCenter defaultCenter] postNotificationName:VideoArrayItemAddNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:VideoPlayItemChangeNotificationName object:nil];
}

- (void)videoArrayDeleteVideoWithDataIndex:(NSInteger)dataIndex {
    
    [[self mutableArrayValueForKey:@"videoArray"] removeObjectAtIndex:dataIndex];
    [self reloadPlayItemAction];
    [[NSNotificationCenter defaultCenter] postNotificationName:VideoArrayItemDeleteIndexNotificationName object:@[@(dataIndex)]];
    [[NSNotificationCenter defaultCenter] postNotificationName:VideoPlayItemChangeNotificationName object:nil];
}

- (void)videoArrayChangeIndexWithFirstIndex:(NSInteger)firstIndex secondIndex:(NSInteger)secondIndex {
    
    [[self mutableArrayValueForKey:@"videoArray"] exchangeObjectAtIndex:firstIndex withObjectAtIndex:secondIndex];
    [self reloadPlayItemAction];
    [[NSNotificationCenter defaultCenter] postNotificationName:VideoArrayItemExchangeIndexNotificationName object:@[@(firstIndex),@(secondIndex)]];
    [[NSNotificationCenter defaultCenter] postNotificationName:VideoPlayItemChangeNotificationName object:nil];
}

#pragma mark - 私有方法

// 重新生成媒体Item
- (void)reloadPlayItemAction {

    self.playItem = [SDVideoUtils mergeMediaPlayerItemActionWithAssetArray:_videoArray
                                                                 timeRange:kCMTimeRangeZero
                                                              bgAudioAsset:nil
                                                            originalVolume:1
                                                             bgAudioVolume:0];
}

- (void)setPlayItem:(AVPlayerItem *)playItem {
    
    _playItem = playItem;
    self.currentPlayTime = kCMTimeZero;
    self.playTimeRange = CMTimeRangeMake(kCMTimeZero, playItem.asset.duration);
    self.playTotalTimeRange = CMTimeRangeMake(kCMTimeZero, playItem.asset.duration);
    _playItem.forwardPlaybackEndTime = CMTimeAdd(kCMTimeZero, playItem.asset.duration);
}

- (void)setPlayTimeRange:(CMTimeRange)playTimeRange {
    
    if (CMTIME_COMPARE_INLINE(playTimeRange.start, <, kCMTimeZero)) {
        playTimeRange = CMTimeRangeMake(kCMTimeZero, playTimeRange.duration);
    }
    if (CMTIME_COMPARE_INLINE(playTimeRange.duration, >, self.playTotalTimeRange.duration)) {
        playTimeRange = CMTimeRangeMake(playTimeRange.start, self.playTotalTimeRange.duration);
    }
    _playTimeRange = playTimeRange;
}

@end

//
//  SDVideoCropDataManager.h
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/24.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SDVideoConfig.h"


// 用户添加视频媒体的通知
#define VideoArrayItemAddNotificationName @"VideoArrayItemAddNotificationName"

// 用户删除视频的下标位置的通知
#define VideoArrayItemDeleteIndexNotificationName @"VideoArrayItemDeleteIndexNotificationName"

// 用户交换视频的下标位置的通知
#define VideoArrayItemExchangeIndexNotificationName @"VideoArrayItemExchangeIndexNotificationName"

// 播放媒体改变的通知
#define VideoPlayItemChangeNotificationName @"VideoPlayItemChangeNotificationName"

@interface SDVideoCropDataManager : NSObject

// SDVideoCropDataManager 是视频截取模块数据管理的类
// 由于视频解决模块视图层级可能很多,所以在数据传递上有着一定的问题,或者传递混乱,这时候就需要这个数据管理类来共同管理公用数据
// 其他模块通过get方式或者KVO的形式来监听数据的变化

- (instancetype)initWithCameraConfig:(SDVideoConfig *)config;

/// 用户配置项
@property(nonatomic,strong)SDVideoConfig *config;

/// 所在控制器
@property(nonatomic,weak)UIViewController *superViewController;

/// 视频数组
@property(nonatomic,strong,readonly)NSMutableArray <AVAsset *>*videoArray;

/// 播放的媒体Item
@property(nonatomic,copy)AVPlayerItem *playItem;

/// 媒体的总播放区间
@property(nonatomic,assign)CMTimeRange playTotalTimeRange;

/// 播放的区间
@property(nonatomic,assign)CMTimeRange playTimeRange;

/// 最小的时长,默认为1s
@property(nonatomic,assign)CMTime minDuration;

/// 每过多少秒监听移除播放时间.默认为0.1s
@property(nonatomic,assign,readonly)CMTime observerTimeSpace;

/// 当前播放时间
@property(nonatomic,assign)CMTime currentPlayTime;

/// 添加视频资源
- (void)videoArrayAddVideoAsset:(AVAsset *)videoAsset;

/// 添加一组视频资源
- (void)videoArrayAddVideoAssetArray:(NSArray <AVAsset *>*)videoAssetArray;

/// 删除某个视频资源
- (void)videoArrayDeleteVideoWithDataIndex:(NSInteger)dataIndex;

/// 对某两个视频资源对换位置
- (void)videoArrayChangeIndexWithFirstIndex:(NSInteger)firstIndex secondIndex:(NSInteger)secondIndex;

@end


//
//  SDVideoUtils.h
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/14.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SDVideoCameraHeader.h"
#import "SDVideoDataModel.h"

// 视频尺寸
#define SDVideoSize (CGSizeMake(1080, 1920))

@interface SDVideoUtils : NSObject

// SDVideoUtils 是视频工具类


/// 合成录制视频,返回播放单体.(主要用于播放,合成时间短)
/// @param assetArray 媒体数组
/// @param timeRange 选择时间区间,如果想选择全部,请使用 kCMTimeRangeZero
/// @param bgAudioAsset 伴奏音乐
/// @param originalVolume 视频音量(0 ~ 1)
/// @param bgAudioVolume 背景音频音量(0 ~ 1)
+ (AVPlayerItem *)mergeMediaPlayerItemActionWithAssetArray:(NSArray <AVAsset *>*)assetArray
                                                 timeRange:(CMTimeRange)timeRange
                                              bgAudioAsset:(AVAsset *)bgAudioAsset
                                            originalVolume:(float)originalVolume
                                             bgAudioVolume:(float)bgAudioVolume;


/// 合成录制视频,返回合成路径
/// @param assetArray 合成资源数组
/// @param bgAudioAsset 背景音乐合成资源
/// @param timeRange 选择时间区间,如果想选择全部,请使用 kCMTimeRangeZero
/// @param originalVolume 视频音量(0 ~ 1)
/// @param bgAudioVolume 背景音频音量(0 ~ 1)
/// @param layerArray 贴纸图层数组
/// @param mergeFilePath 合成媒体文件路径,默认在NSCachesDirectory路径下
/// @param mergeFileName 合成媒体文件名称,默认为"SD_" + "时间戳_" + 0~999随机数 + ".mov"
+ (NSString *)mergeMediaActionWithAssetArray:(NSArray <AVAsset *>*)assetArray
                                bgAudioAsset:(AVAsset *)bgAudioAsset
                                   timeRange:(CMTimeRange)timeRange
                              originalVolume:(float)originalVolume
                               bgAudioVolume:(float)bgAudioVolume
                                  layerArray:(NSArray <CALayer *>*)layerArray
                               mergeFilePath:(NSString *)mergeFilePath
                               mergeFileName:(NSString *)mergeFileName;

/// 给视频添加贴图信息
/// @param composition 视频合成器
/// @param size 视频尺寸
/// @param layerArray 图层数组
+ (void)applyVideoEffectsWithComposition:(AVMutableVideoComposition *)composition
                                    size:(CGSize)size
                              layerArray:(NSArray <CALayer *>*)layerArray;

/// 根据类型快速获取沙盒路径
/// @param pathType 路径类型
+ (NSString *)getSandboxFilePathWithPathType:(VideoFilePathType)pathType;

@end


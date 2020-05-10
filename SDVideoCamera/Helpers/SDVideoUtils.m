//
//  SDVideoUtils.m
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/14.
//  Copyright © 2020 骚栋. All rights reserved.
//

typedef enum {
    LBVideoOrientationUp,               //Device starts recording in Portrait
    LBVideoOrientationDown,             //Device starts recording in Portrait upside down
    LBVideoOrientationLeft,             //Device Landscape Left  (home button on the left side)
    LBVideoOrientationRight,            //Device Landscape Right (home button on the Right side)
    LBVideoOrientationNotFound = 99     //An Error occurred or AVAsset doesn't contains video track
} LBVideoOrientation;

#import "SDVideoUtils.h"
#import <AVFoundation/AVFoundation.h>

@implementation SDVideoUtils

#pragma mark - 接口方法

+ (AVPlayerItem *)mergeMediaPlayerItemActionWithAssetArray:(NSArray <AVAsset *>*)assetArray
                                                 timeRange:(CMTimeRange)timeRange
                                              bgAudioAsset:(AVAsset *)bgAudioAsset
                                            originalVolume:(float)originalVolume
                                             bgAudioVolume:(float)bgAudioVolume {
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:composition];
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];

    [self loadMeidaCompostion:composition videoComposition:videoComposition audioMix:audioMix assetArray:assetArray selectTimeRange:timeRange bgAudioAsset:bgAudioAsset originalVolume:originalVolume bgAudioVolume:bgAudioVolume];
    
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:composition];
    playerItem.videoComposition = videoComposition;
    playerItem.audioMix = audioMix;
    return playerItem;
}

+ (NSString *)mergeMediaActionWithAssetArray:(NSArray <AVAsset *>*)assetArray
                                bgAudioAsset:(AVAsset *)bgAudioAsset
                                   timeRange:(CMTimeRange)timeRange
                              originalVolume:(float)originalVolume
                               bgAudioVolume:(float)bgAudioVolume
                                  layerArray:(NSArray <CALayer *>*)layerArray
                               mergeFilePath:(NSString *)mergeFilePath
                               mergeFileName:(NSString *)mergeFileName {
    
    NSString * mergePath = [SDVideoUtils mergeMediaPathWithMergeFilePath:mergeFilePath mergeFileName:mergeFileName];
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:composition];
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    
    [self loadMeidaCompostion:composition videoComposition:videoComposition audioMix:audioMix assetArray:assetArray selectTimeRange:kCMTimeRangeZero bgAudioAsset:bgAudioAsset originalVolume:originalVolume bgAudioVolume:bgAudioVolume];
    
    [self applyVideoEffectsWithComposition:videoComposition size:SDVideoSize layerArray:layerArray];
    
    AVAssetExportSession *exporterSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetMediumQuality];
    exporterSession.outputFileType = AVFileTypeMPEG4;
    exporterSession.outputURL = [NSURL fileURLWithPath:mergePath]; //如果文件已存在，将造成导出失败
    exporterSession.videoComposition = videoComposition;
    exporterSession.audioMix = audioMix;
    exporterSession.shouldOptimizeForNetworkUse = YES; //用于互联网传输
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [exporterSession exportAsynchronouslyWithCompletionHandler:^{
        switch (exporterSession.status) {
            case AVAssetExportSessionStatusUnknown:
                NSLog(@"exporter Unknow");
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"exporter Canceled");
                break;
            case AVAssetExportSessionStatusFailed:
                NSLog(@"exporter Failed");
                break;
            case AVAssetExportSessionStatusWaiting:
                NSLog(@"exporter Waiting");
                break;
            case AVAssetExportSessionStatusExporting:
                NSLog(@"exporter Exporting");
                break;
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"exporter Completed");
                break;
        }
        dispatch_semaphore_signal(sema);
    }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

    return mergePath;
}

+ (void)applyVideoEffectsWithComposition:(AVMutableVideoComposition *)composition
                                    size:(CGSize)size
                              layerArray:(NSArray <CALayer *>*)layerArray {
    
    
    if (layerArray.count == 0) {
        return;
    }
    
    CALayer *overlayLayer = [CALayer layer];
    overlayLayer.frame = CGRectMake(0, 0, size.width, size.height);
    overlayLayer.masksToBounds = YES;
    for (CALayer *subLayer in layerArray) {
        [overlayLayer addSublayer:subLayer];
    }
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];
    
    composition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}

+ (NSString *)getSandboxFilePathWithPathType:(VideoFilePathType)pathType {

    NSString *pathString = nil;
    switch (pathType) {
        case VideoFilePathTypeDocumentsPath:{
            pathString = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        }break;
        case VideoFilePathTypeTmpPath: {
            pathString = NSTemporaryDirectory();
            break;
        }
        case VideoFilePathTypeLibraryPath: {
            pathString = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
            break;
        }
        case VideoFilePathTypeCachesPath: {
            pathString = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            break;
        }
        case VideoFilePathTypePreferencesPath: {
            pathString = [NSSearchPathForDirectoriesInDomains(NSPreferencePanesDirectory, NSUserDomainMask, YES) lastObject];
            break;
        }
    }
    return pathString;
}

#pragma mark - 私有方法

// 合成输出路径
+ (NSString *)mergeMediaPathWithMergeFilePath:(NSString *)mergeFilePath mergeFileName:(NSString *)mergeFileName {
    
    NSString * mergePath = nil;
    
    if (mergeFilePath != nil) {
        mergePath = mergeFilePath;
    } else {
        mergePath = [SDVideoUtils getSandboxFilePathWithPathType:VideoFilePathTypeCachesPath];
    }
    
    if (mergeFileName != nil) {
        mergePath = [mergePath stringByAppendingFormat:@"%@",mergeFileName];
    } else {
        mergePath = [mergePath stringByAppendingFormat:@"SD_%f_%d.mov",[[NSDate new] timeIntervalSince1970],arc4random()%999];
    }
    
    return mergePath;
}

// 生成视频轨
+ (void)loadMeidaCompostion:(AVMutableComposition *)composition
           videoComposition:(AVMutableVideoComposition *)videoComposition
                   audioMix:(AVMutableAudioMix *)audioMix
                 assetArray:(NSArray <AVAsset *>*)assetArray
            selectTimeRange:(CMTimeRange)selectTimeRange
               bgAudioAsset:(AVAsset *)bgAudioAsset
             originalVolume:(float)originalVolume
              bgAudioVolume:(float)bgAudioVolume {
    
    
    // 初始化视频轨和音频轨,伴奏音频轨
    videoComposition.frameDuration = CMTimeMake(1, 30);
    videoComposition.renderSize = SDVideoSize;
    // 创建两条视频轨,处理不同尺寸视频合成问题
    AVMutableCompositionTrack *firstVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *secondVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    NSArray *videoTrackArray = @[firstVideoTrack,secondVideoTrack];

    AVMutableCompositionTrack *audioTrack = nil;
    if (originalVolume > 0) {
        audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    }
    AVMutableCompositionTrack *bgAudioTrack = nil;
    if (bgAudioVolume > 0) {
        bgAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    }
    
    CMTime startTime = kCMTimeZero;
    CMTimeRange passThroughTimeRanges[assetArray.count];
    
    // 确定开始与结束的下标以及开始与结束的时间点,用于截取时间
    CMTime firstAssetStartTime = kCMTimeZero;
    CMTime endAssetDuration = assetArray.lastObject.duration;
    NSInteger startIndex = 0;
    NSInteger endIndex = assetArray.count - 1;
    
    // 如果是没有设置时间区间,那么直接认定全部选中
    if (!CMTimeRangeEqual(selectTimeRange, kCMTimeRangeZero)) {
        startIndex = -1;
        endIndex = -1;
        CMTime assetTotalTime = kCMTimeZero;
        CMTime videoTotalTime = CMTimeAdd(selectTimeRange.start, selectTimeRange.duration);
        for (int i = 0; i < assetArray.count; i++) {
            AVAsset *asset = assetArray[i];
            assetTotalTime = CMTimeAdd(assetTotalTime, asset.duration);
            if (CMTIME_COMPARE_INLINE(CMTimeSubtract(assetTotalTime,selectTimeRange.start), >, selectTimeRange.start) && startIndex == -1) {
                startIndex = i;
                firstAssetStartTime = CMTimeSubtract(asset.duration, CMTimeSubtract(assetTotalTime,selectTimeRange.start));
            }
            if (CMTIME_COMPARE_INLINE(assetTotalTime, >=, videoTotalTime) && startIndex != -1 && endIndex == -1) {
                endIndex = i;
                endAssetDuration = CMTimeSubtract(asset.duration, CMTimeSubtract(assetTotalTime,videoTotalTime));
            }
        }
    }
    
    NSMutableArray *audioMixArray = [NSMutableArray arrayWithCapacity:16];
    for (NSInteger i = startIndex; i <= endIndex; i++) {
        AVAsset *asset = assetArray[i];
        AVMutableCompositionTrack *videoTrack = videoTrackArray[i % 2];
        AVAssetTrack *videoAssetTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        if (videoAssetTrack == nil) {
            continue;
        }
        CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
        
        if (i == startIndex) {
            timeRange = CMTimeRangeMake(firstAssetStartTime, CMTimeSubtract(asset.duration, firstAssetStartTime));
        }
        if (i == endIndex) {
            timeRange = CMTimeRangeMake(kCMTimeZero, endAssetDuration);
        }

        [videoTrack insertTimeRange:timeRange ofTrack:videoAssetTrack atTime:startTime error:nil];
        passThroughTimeRanges[i] = CMTimeRangeMake(startTime, timeRange.duration);
        
        if (originalVolume > 0) {
            [audioTrack insertTimeRange:timeRange ofTrack:[asset tracksWithMediaType:AVMediaTypeAudio][0] atTime:startTime error:nil];
            AVMutableAudioMixInputParameters *audioTrackParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
            [audioTrackParameters setVolume:originalVolume atTime:timeRange.duration];
            [audioMixArray addObject:audioTrackParameters];
        }
        startTime = CMTimeAdd(startTime,timeRange.duration);
    }
    
    NSMutableArray *instructions = [NSMutableArray arrayWithCapacity:16];
    
    for (NSInteger i = startIndex; i <= endIndex; i++) {
        
        AVMutableCompositionTrack *videoTrack = videoTrackArray[i % 2];
        AVMutableVideoCompositionInstruction * passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        passThroughInstruction.timeRange = passThroughTimeRanges[i];
        AVMutableVideoCompositionLayerInstruction * passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        [SDVideoUtils changeVideoSizeWithAsset:assetArray[i] passThroughLayer:passThroughLayer];
        passThroughInstruction.layerInstructions = @[passThroughLayer];
        [instructions addObject:passThroughInstruction];
    }
    videoComposition.instructions = instructions;
        
    // 插入伴奏
    if (bgAudioAsset != nil && bgAudioVolume > 0) {
        AVAssetTrack *assetAudioTrack = [[bgAudioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        [bgAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, startTime) ofTrack:assetAudioTrack atTime:kCMTimeZero error:nil];
        AVMutableAudioMixInputParameters *bgAudioTrackParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:bgAudioTrack];
        [bgAudioTrackParameters setVolume:bgAudioVolume atTime:startTime];
        [audioMixArray addObject:bgAudioTrackParameters];
    }
    audioMix.inputParameters = audioMixArray;
}

// 处理视频尺寸大小
+ (void)changeVideoSizeWithAsset:(AVAsset *)asset passThroughLayer:(AVMutableVideoCompositionLayerInstruction *)passThroughLayer {
    
    AVAssetTrack *videoAssetTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    if (videoAssetTrack == nil) {
        return;
    }
    CGSize naturalSize = videoAssetTrack.naturalSize;
    
    if ([SDVideoUtils videoDegressWithVideoAsset:asset] == 90) {
        naturalSize = CGSizeMake(naturalSize.height, naturalSize.width);
    }
    
    if ((int)naturalSize.width % 2 != 0) {
        naturalSize = CGSizeMake(naturalSize.width + 1.0, naturalSize.height);
    }
    
    CGSize videoSize = SDVideoSize;
    
    if ([SDVideoUtils videoDegressWithVideoAsset:asset] == 90) {
        CGFloat height = videoSize.width * naturalSize.height / naturalSize.width;
        CGAffineTransform translateToCenter = CGAffineTransformMakeTranslation(videoSize.width, videoSize.height/2.0 - height/2.0);
        CGAffineTransform scaleTransform = CGAffineTransformScale(translateToCenter, videoSize.width/naturalSize.width, height/naturalSize.height);
        CGAffineTransform mixedTransform = CGAffineTransformRotate(scaleTransform, M_PI_2);
        [passThroughLayer setTransform:mixedTransform atTime:kCMTimeZero];
    } else {
        CGFloat height = videoSize.width * naturalSize.height / naturalSize.width;
        CGAffineTransform translateToCenter = CGAffineTransformMakeTranslation(0, videoSize.height/2.0 - height/2.0);
        CGAffineTransform scaleTransform = CGAffineTransformScale(translateToCenter, videoSize.width/naturalSize.width, height/naturalSize.height);
        [passThroughLayer setTransform:scaleTransform atTime:kCMTimeZero];
    }
}

// 计算视频角度
+ (NSInteger)videoDegressWithVideoAsset:(AVAsset *)videoAsset {
    
    NSInteger videoDegress = 0;
    NSArray *assetVideoTracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
    if (assetVideoTracks.count > 0) {
        AVAssetTrack *videoTrack = assetVideoTracks.firstObject;
        CGAffineTransform affineTransform = videoTrack.preferredTransform;
        if(affineTransform.a == 0 && affineTransform.b == 1.0 && affineTransform.c == -1.0 && affineTransform.d == 0){
            videoDegress = 90;
        }else if(affineTransform.a == 0 && affineTransform.b == -1.0 && affineTransform.c == 1.0 && affineTransform.d == 0){
            videoDegress = 270;
        }else if(affineTransform.a == 1.0 && affineTransform.b == 0 && affineTransform.c == 0 && affineTransform.d == 1.0){
            videoDegress = 0;
        }else if(affineTransform.a == -1.0 && affineTransform.b == 0 && affineTransform.c == 0 && affineTransform.d == -1.0){
            videoDegress = 180;
        }
    }
    return videoDegress;
}

@end

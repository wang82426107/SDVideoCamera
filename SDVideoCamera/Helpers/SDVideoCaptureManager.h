//
//  SDVideoCaptureManager.h
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/15.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SDVideoConfig.h"

@interface SDVideoCaptureManager : NSObject

// SDVideoCaptureManager 是摄像头硬件管理类

- (instancetype)initWithVideoView:(UIView *)videoView config:(SDVideoConfig *)config;

/// 检测麦克风是否已经打开
+ (AVAuthorizationStatus)isOpenMicrophoneAuthStatus;

/// 检测摄像头是否已经打开
+ (AVAuthorizationStatus)isOpenCameraAuthStatus;

/// 开始录制视频
- (void)startVideoRecordingAction;

/// 暂停(或停止)录制视频
- (void)pauseOrStopVideoRecordingAction;

/// 翻转摄像头
- (void)exchangeCameraInputAction;

/// 打开闪光灯
- (void)openCameraFlashLight;

/// 设置相机焦距
- (void)setVideoZoomFactorWithScale:(CGFloat)scale orientation:(TouchMoveOrientation)orientation;

/// 重新设定相机的当前焦距边界值
- (void)reloadCurrentVideoZoomFactorAction;

@end


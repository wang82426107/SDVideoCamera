//
//  SDVideoCaptureManager.m
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/15.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDVideoCaptureManager.h"
#import <AVFoundation/AVFoundation.h>
#import "SDVideoDataManager.h"
#import "SDVideoUtils.h"

@interface SDVideoCaptureManager ()<AVCaptureFileOutputRecordingDelegate>

@property(nonatomic,weak)UIView *videoView;// 输出图像的视图
@property(nonatomic,strong)SDVideoConfig *config;// 用户配置项
@property(nonatomic,strong)AVCaptureSession * captureSession;//负责输入和输出设备之间的数据传输
@property(nonatomic,strong)AVCaptureDeviceInput * captureDeviceInput;//负责从AVCaptureDevice获得输入数据
@property(nonatomic,strong)AVCaptureDeviceInput * audioCaptureDeviceInput;//音频输入设备
@property(nonatomic,strong)AVCaptureStillImageOutput * captureStillImageOutput;//照片输出流
@property(nonatomic,strong)AVCaptureMovieFileOutput * captureMovieFileOutPut;//视频输出流
@property(nonatomic,assign)UIBackgroundTaskIdentifier backgroundTaskIdentifier;//后台任务标识
@property(nonatomic,strong)AVCaptureVideoPreviewLayer * captureVideoPreviewLayer;//相机拍摄预览图层

@property(nonatomic,copy)NSNumber * currentVideoZoomFactor;

@end

@implementation SDVideoCaptureManager

- (instancetype)initWithVideoView:(UIView *)videoView config:(SDVideoConfig *)config {
    
    if (self = [super init]) {
        self.config = config;
        self.videoView = videoView;
        self.currentVideoZoomFactor = @(1);
        [self.videoView.layer addSublayer:self.captureVideoPreviewLayer];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.captureSession startRunning];
        });
    }
    return self;
}

#pragma mark - 输入输出设备懒加载

//设备管理会话
- (AVCaptureSession *)captureSession {
    
    if (_captureSession == nil) {
        _captureSession = [[AVCaptureSession alloc] init];
        //设置分辨率
        if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
            _captureSession.sessionPreset=AVCaptureSessionPreset1280x720;
        }

        //将设备输入添加到会话中
        if ([_captureSession canAddInput:self.captureDeviceInput]) {
            [_captureSession addInput:self.captureDeviceInput];
            [_captureSession addInput:self.audioCaptureDeviceInput];
            AVCaptureConnection *captureConnection = [self.captureMovieFileOutPut connectionWithMediaType:AVMediaTypeVideo];
            ;
            if ([captureConnection isVideoStabilizationSupported]) {
                captureConnection.preferredVideoStabilizationMode= AVCaptureVideoStabilizationModeAuto;
            }
        }

        //将设备输出添加到会话中
        if ([_captureSession canAddOutput:self.captureStillImageOutput]) {
            [_captureSession addOutput:self.captureStillImageOutput];
        }
        if ([_captureSession canAddOutput:self.captureMovieFileOutPut]) {
            [_captureSession addOutput:self.captureMovieFileOutPut];
        }
    }
    return _captureSession;
}

//图像输入设备
- (AVCaptureDeviceInput *)captureDeviceInput {
    
    if (_captureDeviceInput == nil) {
        AVCaptureDevice *captureDevice = [self getCameraDeviceWithPosition:self.config.devicePosition];
        if (!captureDevice) {
            NSLog(@"取得摄像头时出现问题。");
        }
        NSError * error = nil;
        _captureDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:captureDevice error:&error];
        if (error) {
            NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        }
    }
    return _captureDeviceInput;
}

- (AVCaptureVideoPreviewLayer *)captureVideoPreviewLayer {
    
    if (_captureVideoPreviewLayer == nil) {
        _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
        _captureVideoPreviewLayer.frame = self.videoView.layer.bounds;
        _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _captureVideoPreviewLayer;
}

//音频输入设备
- (AVCaptureDeviceInput *)audioCaptureDeviceInput {
    
    if (_audioCaptureDeviceInput == nil) {
        NSError * error = nil;
        AVCaptureDevice * audioCaptureDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
        _audioCaptureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioCaptureDevice error:&error];
        if (error) {
            NSLog(@"获得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        }
    }
    return _audioCaptureDeviceInput;
}

//照片输出流
- (AVCaptureStillImageOutput *)captureStillImageOutput {
    
    if (_captureStillImageOutput == nil) {
        _captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary * outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};//输出设置
        [_captureStillImageOutput setOutputSettings:outputSettings];
    }
    return _captureStillImageOutput;
}

//视频输出流
- (AVCaptureMovieFileOutput *)captureMovieFileOutPut {
    
    if (_captureMovieFileOutPut == nil) {
        _captureMovieFileOutPut = [[AVCaptureMovieFileOutput alloc] init];
    }
    return _captureMovieFileOutPut;
}

#pragma mark - 接口方法

+ (AVAuthorizationStatus)isOpenMicrophoneAuthStatus {
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    return authStatus;
}

+ (AVAuthorizationStatus)isOpenCameraAuthStatus {
    
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return videoAuthStatus;
}

- (void)startVideoRecordingAction {

    //根据设备输出获得连接
    AVCaptureConnection *captureConnection = [self.captureMovieFileOutPut connectionWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice * currentDevice = [self.captureDeviceInput device];
    if (currentDevice.position==AVCaptureDevicePositionBack){
        captureConnection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        captureConnection.videoMirrored = NO;
    } else if (currentDevice.position == AVCaptureDevicePositionFront || currentDevice.position == AVCaptureDevicePositionUnspecified){
        // 关闭前置摄像头的镜像模式
        captureConnection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        captureConnection.videoMirrored = YES;
    }

    //根据连接取得设备输出的数据
    if (![self.captureMovieFileOutPut isRecording]) {
        //如果支持多任务则则开始多任务
        if ([[UIDevice currentDevice] isMultitaskingSupported]) {
            self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
        }
        //预览图层和视频方向保持一致
        captureConnection.videoOrientation=[self.captureVideoPreviewLayer connection].videoOrientation;
        NSString *outputFielPath=[[SDVideoUtils getSandboxFilePathWithPathType:self.config.videoFilePathType] stringByAppendingString:[NSString stringWithFormat:@"%@%d.mov",self.config.videoFileNamePrefix,(int)[SDVideoDataManager defaultManager].videoDataArray.count]];
        NSURL *fileUrl=[NSURL fileURLWithPath:outputFielPath];
        [self.captureMovieFileOutPut startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
    }
}

- (void)pauseOrStopVideoRecordingAction {
    
    [self.captureMovieFileOutPut stopRecording];//停止录制
}

- (void)exchangeCameraInputAction {
    
    AVCaptureDevice * currentDevice = [self.captureDeviceInput device];
    AVCaptureDevicePosition currentPosition = [currentDevice position];
    AVCaptureDevice * toChangeDevice;
    AVCaptureDevicePosition  toChangePosition = AVCaptureDevicePositionFront;
    if (currentPosition == AVCaptureDevicePositionUnspecified || currentPosition == AVCaptureDevicePositionFront) {
        toChangePosition = AVCaptureDevicePositionBack;
    }
    toChangeDevice = [self getCameraDeviceWithPosition:toChangePosition];
    AVCaptureDeviceInput * toChangeDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:toChangeDevice error:nil];
    [self.captureSession beginConfiguration];
    [self.captureSession removeInput:self.captureDeviceInput];
    if ([self.captureSession canAddInput:toChangeDeviceInput]) {
        [self.captureSession addInput:toChangeDeviceInput];
        self.captureDeviceInput=toChangeDeviceInput;
    }
    [self.captureSession commitConfiguration];
}

- (void)openCameraFlashLight {
    
    AVCaptureDevice *currentDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
    if (currentDevice.torchMode == AVCaptureTorchModeOff) {
        [self.captureSession beginConfiguration];
        [currentDevice lockForConfiguration:nil];
        [currentDevice setTorchMode:AVCaptureTorchModeOn];
        [currentDevice unlockForConfiguration];
        [self.captureSession commitConfiguration];
    } else {
        [self.captureSession beginConfiguration];
        [currentDevice lockForConfiguration:nil];
        [currentDevice setTorchMode:AVCaptureTorchModeOff];
        [currentDevice unlockForConfiguration];
        [self.captureSession commitConfiguration];
    }
}

#pragma mark - 设置缩放比例相关方法

- (void)setVideoZoomFactorWithScale:(CGFloat)scale orientation:(TouchMoveOrientation)orientation {
    
    CGFloat minZoomFactor = [self minZoomFactor];
    CGFloat maxZoomFactor = [self maxZoomFactor];
    AVCaptureDevice * currentDevice = [self.captureDeviceInput device];
    
    if (orientation == TouchMoveOrientationUp) {
        // 往上滑动
        CGFloat nextZoomFactor = [self.currentVideoZoomFactor floatValue] + (maxZoomFactor - [self.currentVideoZoomFactor floatValue]) * scale;
        NSError *error = nil;
        if ([currentDevice lockForConfiguration:&error] ) {
            currentDevice.videoZoomFactor = nextZoomFactor;
            [currentDevice unlockForConfiguration];
        }
    } else {
        NSError *error = nil;
        if (scale == 0 && [currentDevice lockForConfiguration:&error]) {
            currentDevice.videoZoomFactor = minZoomFactor;
            [currentDevice unlockForConfiguration];
        }
    }
}

- (void)reloadCurrentVideoZoomFactorAction {
    
    AVCaptureDevice * currentDevice = [self.captureDeviceInput device];
    self.currentVideoZoomFactor = @(currentDevice.videoZoomFactor);
}

- (CGFloat)minZoomFactor {
    
    CGFloat minZoomFactor = 1.0;
    if (@available(iOS 11.0, *)) {
        AVCaptureDevice * currentDevice = [self.captureDeviceInput device];
        minZoomFactor = currentDevice.minAvailableVideoZoomFactor;
    }
    return minZoomFactor;
}

- (CGFloat)maxZoomFactor {
    CGFloat maxZoomFactor = self.config.maxVideoZoomFactor;
    if (maxZoomFactor > 6.0) {
        maxZoomFactor = 6.0;
    }
    if (maxZoomFactor < 1.0) {
        maxZoomFactor = 1.0;
    }
    return maxZoomFactor;
}

#pragma mark - 视频输出代理

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
    
    // 开始录制
}

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    
    // 分段视频录制完成
    SDVideoDataModel *dataModel = [[SDVideoDataModel alloc] init];
    dataModel.pathURL = outputFileURL;
    if ([SDVideoDataManager defaultManager].videoNumber == 0) {
        dataModel.duration = [SDVideoDataManager defaultManager].totalVideoTime;
        dataModel.progress = [SDVideoDataManager defaultManager].progress;
        dataModel.durationWeight = [SDVideoDataManager defaultManager].progress;
    } else {
        SDVideoDataModel *lastDataModel = [SDVideoDataManager defaultManager].videoDataArray.lastObject;
        dataModel.duration = ([SDVideoDataManager defaultManager].progress - lastDataModel.progress) * [SDVideoDataManager defaultManager].videoSecondTime;
        dataModel.progress = [SDVideoDataManager defaultManager].progress;
        dataModel.durationWeight = dataModel.duration/[SDVideoDataManager defaultManager].videoSecondTime;
    }
    [[SDVideoDataManager defaultManager] addVideoModel:dataModel];
}

#pragma mark - 私有方法

//获取指定位置的摄像头
- (AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition)positon {
    
    NSArray * cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice * camera in cameras) {
        if ([camera position] == positon) {
            return camera;
        }
    }
    return nil;
}

// 根据不同摄像头设置拍摄方向
- (AVCaptureVideoOrientation)getCaptureVideoOrientation {
    
    AVCaptureVideoOrientation result;
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
            result = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            //如果这里设置成AVCaptureVideoOrientationPortraitUpsideDown，则视频方向和拍摄时的方向是相反的。
            result = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeLeft:
            result = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            result = AVCaptureVideoOrientationLandscapeLeft;
            break;
        default:
            result = AVCaptureVideoOrientationPortrait;
            break;
    }
    return result;
}

@end

//
//  SDVideoCameraController.m
//  FamilyClassroom
//
//  Created by 王巍栋 on 2020/1/13.
//  Copyright © 2020 Dong. All rights reserved.
//

#import "SDVideoCameraController.h"
#import "SDVideoPreviewViewController.h"
#import "SDVideoAlbumViewController.h"
#import "SDVideoCameraAuthoView.h"
#import "SDVideoCaptureManager.h"
#import "SDAudioPlayerManager.h"
#import "SDVideoLoadingView.h"
#import "SDVideoDataManager.h"
#import "SDVideoUtils.h"

@interface SDVideoCameraController ()<SDVideoCameraMenuDelegate>

@property(nonatomic,strong)SDVideoConfig *config;
@property(nonatomic,strong)UIView *videoView;
@property(nonatomic,strong)SDVideoCaptureManager *captureManager;
@property(nonatomic,strong)SDAudioPlayerManager *audioManager;

@end

@implementation SDVideoCameraController

- (instancetype)initWithCameraConfig:(SDVideoConfig *)config {
    
    if (self = [super init]) {
        self.config = config;
        [config configDataSelfCheckAction];
        [SDVideoDataManager defaultManager].config = config;
        [SDVideoDataManager defaultManager].cameraState = VideoCameraStateIdle;
        [[SDVideoDataManager defaultManager] addObserver:self forKeyPath:@"cameraState" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.videoView];
    [self.view addSubview:self.menuView];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    if ([self.menuView isOpenAllDeviceAuthoStateAction]) {
        [self captureManager];
    }
    [self setNeedsStatusBarAppearanceUpdate];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)closeButtonAction {
    
    if ([SDVideoDataManager defaultManager].videoNumber != 0) {
        UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *reloadAction = [UIAlertAction actionWithTitle:@"重新拍摄" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [[SDVideoDataManager defaultManager] deleteAllVideoModel];
        }];
        UIAlertAction *exitAction = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertViewController addAction:reloadAction];
        [alertViewController addAction:exitAction];
        [alertViewController addAction:cancelAction];
        [self presentViewController:alertViewController animated:YES completion:nil];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - 懒加载

- (UIView *)videoView {
    
    if (_videoView == nil) {
        _videoView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _videoView.backgroundColor = [UIColor blackColor];
        _videoView.layer.masksToBounds = YES;
    }
    return _videoView;
}

- (SDVideoCameraMenuView *)menuView {
    
    if (_menuView == nil) {
        _menuView = [[SDVideoCameraMenuView alloc] initWithFrame:[UIScreen mainScreen].bounds cameraConfig:self.config];
        _menuView.superViewController = self;
        _menuView.delegate = self;
        [_menuView.closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _menuView;
}

- (SDVideoCaptureManager *)captureManager {
    
    if (_captureManager == nil) {
        _captureManager = [[SDVideoCaptureManager alloc] initWithVideoView:self.videoView config:self.config];
    }
    return _captureManager;
}

- (SDAudioPlayerManager *)audioManager {
    
    if (_audioManager == nil) {
        _audioManager = [[SDAudioPlayerManager alloc] initWithConfig:self.config];
    }
    return _audioManager;
}

#pragma mark - 控制层回调方法

- (void)userFinishMergeVideoAction {
    
    [SDVideoLoadingView showLoadingAction];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *videoAssetArray = [NSMutableArray arrayWithCapacity:16];
        for (SDVideoDataModel *dataModel in [SDVideoDataManager defaultManager].videoDataArray) {
            AVAsset *asset = [AVAsset assetWithURL:dataModel.pathURL];
            [videoAssetArray addObject:asset];
        }

        AVPlayerItem *playItem = [SDVideoUtils mergeMediaPlayerItemActionWithAssetArray:videoAssetArray
                                                                              timeRange:kCMTimeRangeZero
                                                                           bgAudioAsset:nil
                                                                         originalVolume:1
                                                                          bgAudioVolume:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SDVideoLoadingView dismissLoadingAction];
            SDVideoPreviewViewController *previewViewController = [[SDVideoPreviewViewController alloc] initWithCameraConfig:self.config playItem:playItem videoAssetArray:videoAssetArray playTimeRange:kCMTimeRangeZero];
            [self.navigationController pushViewController:previewViewController animated:YES];
        });
        
    });
}

- (void)deleteLaseVideoDataAction {

    [self.audioManager seekToTime:CMTimeMake([SDVideoDataManager defaultManager].totalVideoTime, 1.0)];
}

- (void)userClickOutMenuButtonWithButtonType:(VideoMenuType)menuType {
    
    switch (menuType) {
        case VideoMenuTypesTurnOver:{
            [self.captureManager exchangeCameraInputAction];
            break;
        }
        case VideoMenuTypesFlashlight:{
            [self.captureManager openCameraFlashLight];
            break;
        }
        default:
            break;
    }
}

- (void)userChangeVideoZoomFactorWithScale:(CGFloat)scale orientation:(TouchMoveOrientation)orientation {

    [self.captureManager setVideoZoomFactorWithScale:scale orientation:orientation];
}

- (void)userEndChangeVideoZoomFactor {
    
    [self.captureManager reloadCurrentVideoZoomFactorAction];
}

- (void)userClickAlbumAction {
    
    SDVideoAlbumViewController *albumViewController = [[SDVideoAlbumViewController alloc] initWithCameraConfig:self.config];
    UINavigationController *albumNavigationController = [[UINavigationController alloc] initWithRootViewController:albumViewController];
    albumNavigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:albumNavigationController animated:YES completion:nil];
}

- (void)userOpenAllDerviceAuthoAction {
    
    [self captureManager];
}

#pragma mark - 监听方法

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {

    if ([keyPath isEqualToString:@"cameraState"]) {
        switch ([SDVideoDataManager defaultManager].cameraState) {
            case VideoCameraStateIdle:{
                break;
            }
            case VideoCameraStateInProgress:{
                [self.audioManager play];
                [self.captureManager startVideoRecordingAction];
                break;
            }
            case VideoCameraStatePause:{
                [self.audioManager pause];
                [self.captureManager pauseOrStopVideoRecordingAction];//停止录制
                break;
            }
            case VideoCameraStateStop: {
                [self.audioManager pause];
                [self.captureManager pauseOrStopVideoRecordingAction];//停止录制
                break;
            }
        }
    }
}

#pragma mark - 系统方法

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

- (void)dealloc {
    
    [[SDVideoDataManager defaultManager] removeObserver:self forKeyPath:@"cameraState"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end

//
//  SDVideoCropViewController.m
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/19.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDVideoCropViewController.h"
#import "SDVideoPreviewViewController.h"
#import "SDVideoCropDataManager.h"
#import "SDVideoCropBottomView.h"
#import "SDVideoLoadingView.h"
#import "UIView+Extension.h"
#import "SDVideoUtils.h"

@interface SDVideoCropViewController ()<SDVideoCropVideoDragDelegate>

@property(nonatomic,strong)UIButton *returnButton;
@property(nonatomic,strong)UIButton *nextButton;
@property(nonatomic,strong)UIImageView *mainVideoView;
@property(nonatomic,strong)SDVideoCropBottomView *bottomView;
@property(nonatomic,strong)AVPlayerLayer *videoLayer;
@property(nonatomic,strong)AVPlayer *player;

@property(nonatomic,strong)SDVideoCropDataManager *dataManager;
@property(nonatomic,assign)BOOL isReloadPlay;
@property(nonatomic,assign)BOOL isLeveViewController;

@end

@implementation SDVideoCropViewController

- (instancetype)initWithCameraConfig:(SDVideoConfig *)config videoAssetArray:(NSArray <AVAsset *>*)videoAssetArray {

    if (self = [super init]) {
        self.dataManager = [[SDVideoCropDataManager alloc] initWithCameraConfig:config];
        self.dataManager.superViewController = self;
        [self addDataObserverAction];
        [self.dataManager videoArrayAddVideoAssetArray:videoAssetArray];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadPlayerAction) name:VideoPlayItemChangeNotificationName object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor hexStringToColor:@"101118"];
    [self.view addSubview:self.returnButton];
    [self.view addSubview:self.nextButton];
    [self.view addSubview:self.mainVideoView];
    [self.view addSubview:self.bottomView];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.isLeveViewController = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self playVideoAction];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    self.isLeveViewController = YES;
}

#pragma mark - 懒加载

- (UIButton *)returnButton {
    
    if (_returnButton == nil) {
        _returnButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 20, 40, 40)];
        [_returnButton setImage:[UIImage imageNamed:@"sd_commom_return_icon"] forState:UIControlStateNormal];
        [_returnButton addTarget:self action:@selector(returnViewControllerAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _returnButton;
}

- (UIButton *)nextButton {
    
    if (_nextButton == nil) {
        _nextButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - 15 - 60, 0, 60, 30)];
        _nextButton.backgroundColor = [UIColor hexStringToColor:self.dataManager.config.tintColor];
        _nextButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _nextButton.centerY = self.returnButton.centerY;
        _nextButton.layer.cornerRadius = 5.0f;
        _nextButton.layer.masksToBounds = YES;
        [_nextButton setTitle:@"下一步" forState:UIControlStateNormal];
        [_nextButton addTarget:self action:@selector(nextButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}

- (UIImageView *)mainVideoView {
    
    if (_mainVideoView == nil) {
        _mainVideoView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.width/4.0, self.returnButton.bottom, self.view.width/2.0, self.view.width/2.0/1080.0 * 1920)];
        _mainVideoView.backgroundColor = [UIColor blackColor];
        [_mainVideoView.layer addSublayer:self.videoLayer];
    }
    return _mainVideoView;
}

- (SDVideoCropBottomView *)bottomView {
    
    if (_bottomView == nil) {
        _bottomView = [[SDVideoCropBottomView alloc] initWithFrame:CGRectMake(0, self.mainVideoView.bottom + 20.0f, self.view.width, self.view.height - (self.mainVideoView.bottom + 20.0f)) dataManager:self.dataManager];
        _bottomView.delegate = self;
    }
    return _bottomView;
}

- (AVPlayerLayer *)videoLayer {
    
    if (_videoLayer == nil) {
        _videoLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        _videoLayer.frame = self.mainVideoView.bounds;
    }
    return _videoLayer;
}

- (AVPlayer *)player {
    
    if (_player == nil) {
        _player = [[AVPlayer alloc] initWithPlayerItem:self.dataManager.playItem];
        __weak typeof(self) weakSelf = self;
        [_player addPeriodicTimeObserverForInterval:self.dataManager.observerTimeSpace queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            weakSelf.dataManager.currentPlayTime = weakSelf.player.currentTime;
        }];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoItemPlayFinishAction) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return _player;
}

#pragma mark - 点击事件

- (void)returnViewControllerAction {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextButtonAction {
    
    [self.player pause];
    [SDVideoLoadingView showLoadingAction];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        AVPlayerItem *playItem = [SDVideoUtils mergeMediaPlayerItemActionWithAssetArray:self.dataManager.videoArray
                                                                              timeRange:self.dataManager.playTimeRange
                                                                           bgAudioAsset:nil
                                                                         originalVolume:1
                                                                          bgAudioVolume:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SDVideoLoadingView dismissLoadingAction];
            SDVideoPreviewViewController *previewViewController = [[SDVideoPreviewViewController alloc] initWithCameraConfig:self.dataManager.config playItem:playItem videoAssetArray:self.dataManager.videoArray playTimeRange:self.dataManager.playTimeRange];
            [self.navigationController pushViewController:previewViewController animated:YES];
        });
    });
}

#pragma mark - 加载播放数据

- (void)reloadPlayerAction {

    _player = [[AVPlayer alloc] initWithPlayerItem:self.dataManager.playItem];
    _videoLayer.player = _player;
    __weak typeof(self) weakSelf = self;
    [_player addPeriodicTimeObserverForInterval:self.dataManager.observerTimeSpace queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        weakSelf.dataManager.currentPlayTime = weakSelf.player.currentTime;
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoItemPlayFinishAction) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [self playVideoAction];
}

- (void)playVideoAction {

    [self.player pause];
    [self.dataManager.playItem seekToTime:self.dataManager.playTimeRange.start toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self.player play];
}

#pragma mark - 通知回调事件

- (void)videoItemPlayFinishAction {
    
    // 因为没有队列 所以直接重新播放即可
    if (!self.isLeveViewController) {
        [self playVideoAction];
    }
}

#pragma mark - 拖拽代理方法

- (void)userStartChangeVideoTimeRangeAction {
    
    [self.player pause];
}

- (void)userChangeVideoTimeRangeAction {
    
    [self.player seekToTime:self.dataManager.currentPlayTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)userEndChangeVideoTimeRangeAction {
    
    [self.player play];
}

#pragma mark - 数据监听观察

- (void)addDataObserverAction {
    
    [self.dataManager addObserver:self forKeyPath:@"playTimeRange" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"playTimeRange"]) {
        self.player.currentItem.forwardPlaybackEndTime = CMTimeAdd(self.dataManager.playTimeRange.start, self.dataManager.playTimeRange.duration);
    }
}

#pragma mark - 系统方法

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.dataManager removeObserver:self forKeyPath:@"playTimeRange"];
}

@end

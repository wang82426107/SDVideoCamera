//
//  SDVideoPreviewViewController.m
//  FamilyClassroom
//
//  Created by 王巍栋 on 2020/1/15.
//  Copyright © 2020 Dong. All rights reserved.
//

#import "SDVideoPreviewViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SDVideoPreviewMusicView.h"
#import "SDVideoPreviewTagsView.h"
#import "SDVideoPreviewTextView.h"
#import "UIButton+EdgeInsets.h"
#import "SDVideoLoadingView.h"
#import "SDVideoController.h"
#import "UIView+Extension.h"
#import "SDVideoUtils.h"

@interface SDVideoPreviewViewController ()<SDVideoMusicDelegate,SDVideoPreviewTextDelegate,SDVideoPreviewTagsDelegate>

@property(nonatomic,strong)SDVideoConfig *config;
@property(nonatomic,strong)AVPlayerItem *playItem;
@property(nonatomic,strong)AVPlayerItem *audioPlayItem;
@property(nonatomic,copy)NSArray <AVAsset *>*videoAssetArray;
@property(nonatomic,assign)CMTimeRange playTimeRange;

@property(nonatomic,strong)UIImage *bgImage;
@property(nonatomic,strong)UIImageView *mainVideoView;
@property(nonatomic,strong)UIButton *returnButton;
@property(nonatomic,strong)UIButton *nextButton;
@property(nonatomic,strong)UIButton *musicButton;
@property(nonatomic,strong)UIButton *textButton;
@property(nonatomic,strong)UIButton *iconButton;
@property(nonatomic,strong)UIImageView *deleteTextImageView;

@property(nonatomic,strong)CALayer *verticalLineLayer;
@property(nonatomic,strong)CALayer *horizontalLineLayer;

@property(nonatomic,strong)SDVideoPreviewMusicView *musicView;
@property(nonatomic,strong)SDVideoPreviewTextView *textView;
@property(nonatomic,strong)SDVideoPreviewTagsView *tagsView;


@property(nonatomic,strong)AVPlayerLayer *videoLayer;
@property(nonatomic,strong)AVPlayer *audioPlayer;
@property(nonatomic,strong)AVPlayer *player;

@property(nonatomic,strong)NSMutableArray <NSDictionary *>*effectViewArray;

@end

@implementation SDVideoPreviewViewController

- (instancetype)initWithCameraConfig:(SDVideoConfig *)config
                            playItem:(AVPlayerItem *)playItem
                     videoAssetArray:(NSArray <AVAsset *>*)videoAssetArray
                       playTimeRange:(CMTimeRange)playTimeRange {
    
    if (self = [super init]) {
        self.config = config;
        self.playItem = playItem;
        self.playTimeRange = playTimeRange;
        self.videoAssetArray = videoAssetArray;
        self.effectViewArray = [NSMutableArray arrayWithCapacity:16];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.view addSubview:self.mainVideoView];
    [self.view addSubview:self.returnButton];
    [self.view addSubview:self.nextButton];
    [self.view addSubview:self.musicButton];
    [self.view addSubview:self.textButton];
    [self.view addSubview:self.iconButton];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoItemPlayFinishAction:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [self.player play];
}

- (void)popViewControllerAction {
    
    AVAsset *bgAudioAsset = nil;
    CGFloat bgAudioVolume = 0;
    if (_audioPlayItem != nil) {
        bgAudioAsset = _audioPlayItem.asset;
        bgAudioVolume = _audioPlayer.volume;
    }
    
    NSMutableArray *layerArray = [NSMutableArray arrayWithCapacity:16];
    
    [SDVideoLoadingView showLoadingAction];
    // 缩放倍数
    CGFloat widthScale = SDVideoSize.width/self.view.width;
    CGFloat heightScale = SDVideoSize.height/self.view.height;

    // 根据视频尺寸需要进行对应的缩放.以宽度为基准.
    for (NSDictionary *dictionary in self.effectViewArray) {
        UIView *effectView = dictionary[@"view"];
        NSData *viewData = [NSKeyedArchiver archivedDataWithRootObject:effectView];
        UIView *effectCopyView = [NSKeyedUnarchiver unarchiveObjectWithData:viewData];        
        effectCopyView.layer.affineTransform = CGAffineTransformMakeScale(widthScale, widthScale);
        effectCopyView.layer.position = CGPointMake(effectCopyView.centerX * widthScale, effectCopyView.centerY *heightScale);
        [layerArray addObject:effectCopyView.layer];
    }
    
    NSString *mergeVideoPathString = [SDVideoUtils mergeMediaActionWithAssetArray:self.videoAssetArray
                                                                    bgAudioAsset:bgAudioAsset
                                                                       timeRange:self.playTimeRange
                                                                  originalVolume:self.player.volume
                                                                   bgAudioVolume:bgAudioVolume
                                                                      layerArray:layerArray
                                                                    mergeFilePath:[SDVideoUtils getSandboxFilePathWithPathType:self.config.mergeFilePathType] mergeFileName:self.config.mergeFileName];

    [SDVideoLoadingView dismissLoadingAction];
    if (self.config.returnBlock != nil) {
        self.config.returnBlock(mergeVideoPathString);
    }

    UIViewController *viewController = self.navigationController.presentingViewController;

    while (![viewController isKindOfClass:[self.config.returnViewController class]]) {
          viewController = viewController.presentingViewController;
    }
    [viewController dismissViewControllerAnimated:YES completion:nil];
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
        _nextButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - 15 - 60, self.view.height - 15 - 30, 60, 30)];
        _nextButton.backgroundColor = [UIColor hexStringToColor:self.config.tintColor];
        _nextButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _nextButton.layer.cornerRadius = 5.0f;
        _nextButton.layer.masksToBounds = YES;
        [_nextButton setTitle:@"下一步" forState:UIControlStateNormal];
        [_nextButton addTarget:self action:@selector(popViewControllerAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}

- (UIImageView *)mainVideoView {
    
    if (_mainVideoView == nil) {
        _mainVideoView = [[UIImageView alloc] initWithImage:self.bgImage];
        _mainVideoView.userInteractionEnabled = YES;
        _mainVideoView.frame = self.view.bounds;
        [_mainVideoView.layer addSublayer:self.videoLayer];
        [_mainVideoView.layer addSublayer:self.verticalLineLayer];
        [_mainVideoView.layer addSublayer:self.horizontalLineLayer];
        self.verticalLineLayer.hidden = YES;
        self.horizontalLineLayer.hidden = YES;
    }
    return _mainVideoView;
}

- (UIImageView *)deleteTextImageView {
    
    if (_deleteTextImageView == nil) {
        _deleteTextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.mainVideoView.width/2.0 - 30, StatusHeight, 60, 60)];
        _deleteTextImageView.image = [UIImage imageNamed:@"sd_preview_text_delete_icon"];
        _deleteTextImageView.contentMode = UIViewContentModeCenter;
        _deleteTextImageView.layer.cornerRadius = 30.0f;
        _deleteTextImageView.layer.masksToBounds = YES;
    }
    return _deleteTextImageView;
}

- (CALayer *)verticalLineLayer {
    
    if (_verticalLineLayer == nil) {
        _verticalLineLayer = [[CALayer alloc] init];
        _verticalLineLayer.frame = CGRectMake(self.mainVideoView.width/2.0, 0, 1.0, self.mainVideoView.height);
        _verticalLineLayer.backgroundColor = [UIColor hexStringToColor:@"00f5ff"].CGColor;
    }
    return _verticalLineLayer;
}

- (CALayer *)horizontalLineLayer {
    
    if (_horizontalLineLayer == nil) {
        _horizontalLineLayer = [[CALayer alloc] init];
        _horizontalLineLayer.frame = CGRectMake(0, self.mainVideoView.height/2.0, self.mainVideoView.width, 1.0);
        _horizontalLineLayer.backgroundColor = [UIColor hexStringToColor:@"00f5ff"].CGColor;
    }
    return _horizontalLineLayer;
}

- (UIButton *)musicButton {
    
    if (_musicButton == nil) {
        _musicButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 0, 60, 60)];
        _musicButton.centerY = self.nextButton.centerY;
        _musicButton.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
        _musicButton.adjustsImageWhenHighlighted = NO;
        [_musicButton setTitle:@"配乐" forState:UIControlStateNormal];
        [_musicButton setTitleColor:[UIColor hexStringToColor:@"ffffff"] forState:UIControlStateNormal];
        [_musicButton setImage:[UIImage imageNamed:@"sd_preview_music_normal_icon"] forState:UIControlStateNormal];
        [_musicButton setImage:[UIImage imageNamed:@"sd_preview_music_finish_icon"] forState:UIControlStateSelected];
        [_musicButton addTarget:self action:@selector(showMusicViewAction) forControlEvents:UIControlEventTouchUpInside];
        [_musicButton layoutButtonWithEdgeInsetsStyle:ButtonEdgeInsetsStyleImageTop imageTitlespace:5];
    }
    return _musicButton;
}

- (UIButton *)textButton {
    
    if (_textButton == nil) {
        _textButton = [[UIButton alloc] initWithFrame:CGRectMake(self.musicButton.right, 0, 60, 60)];
        _textButton.centerY = self.nextButton.centerY;
        _textButton.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
        _textButton.adjustsImageWhenHighlighted = NO;
        [_textButton setTitle:@"文字" forState:UIControlStateNormal];
        [_textButton setTitleColor:[UIColor hexStringToColor:@"ffffff"] forState:UIControlStateNormal];
        [_textButton setImage:[UIImage imageNamed:@"sd_preview_text_icon"] forState:UIControlStateNormal];
        [_textButton addTarget:self action:@selector(showTextViewAction) forControlEvents:UIControlEventTouchUpInside];
        [_textButton layoutButtonWithEdgeInsetsStyle:ButtonEdgeInsetsStyleImageTop imageTitlespace:5];
    }
    return _textButton;
}

- (UIButton *)iconButton {
    
    if (_iconButton == nil) {
        _iconButton = [[UIButton alloc] initWithFrame:CGRectMake(self.textButton.right, 0, 60, 60)];
        _iconButton.centerY = self.nextButton.centerY;
        _iconButton.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
        _iconButton.adjustsImageWhenHighlighted = NO;
        [_iconButton setTitle:@"贴纸" forState:UIControlStateNormal];
        [_iconButton setTitleColor:[UIColor hexStringToColor:@"ffffff"] forState:UIControlStateNormal];
        [_iconButton setImage:[UIImage imageNamed:@"sd_preview_image_icon"] forState:UIControlStateNormal];
        [_iconButton addTarget:self action:@selector(showTagsViewAction) forControlEvents:UIControlEventTouchUpInside];
        [_iconButton layoutButtonWithEdgeInsetsStyle:ButtonEdgeInsetsStyleImageTop imageTitlespace:5];
    }
    return _iconButton;
}

- (SDVideoPreviewMusicView *)musicView {
    
    if (_musicView == nil) {
        _musicView = [[SDVideoPreviewMusicView alloc] initWithFrame:[UIScreen mainScreen].bounds config:self.config superViewController:self];
        _musicView.delegate = self;
    }
    return _musicView;
}

- (SDVideoPreviewTextView *)textView {
    
    if (_textView == nil) {
        _textView = [[SDVideoPreviewTextView alloc] initWithFrame:[UIScreen mainScreen].bounds config:self.config];
        _textView.delegate = self;
    }
    return _textView;
}

- (SDVideoPreviewTagsView *)tagsView {
    
    if (_tagsView == nil) {
        _tagsView = [[SDVideoPreviewTagsView alloc] initWithFrame:[UIScreen mainScreen].bounds config:self.config];
        _tagsView.delegate = self;
    }
    return _tagsView;
}

- (AVPlayerLayer *)videoLayer {
    
    if (_videoLayer == nil) {
        _videoLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        _videoLayer.frame = self.view.bounds;
    }
    return _videoLayer;
}

- (AVPlayer *)player {
    
    if (_player == nil) {
        _player = [AVPlayer playerWithPlayerItem:self.playItem];
        _player.currentItem.forwardPlaybackEndTime = self.player.currentItem.duration;
    }
    return _player;
}

#pragma mark - 相关事件

- (void)returnViewControllerAction {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showMusicViewAction {
    
    [self.view addSubview:self.musicView];
    [self.musicView showViewAction];
}

- (void)showTextViewAction {
    
    [self.view addSubview:self.textView];
    [self.textView showViewAction];
}

- (void)showTagsViewAction {
    
    [self.view addSubview:self.tagsView];
    [self.tagsView showViewAction];
}

#pragma mark - 回调事件

- (void)userSelectbackgroundMusicWithDataModel:(SDVideoMusicModel *)dataModel musicVolume:(CGFloat)musicVolume {
    
    if (dataModel == nil) {
        [_audioPlayer pause];
        _audioPlayItem = nil;
    } else {
        self.audioPlayItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:dataModel.musicPathURL]];
        _audioPlayer = [[AVPlayer alloc] initWithPlayerItem:self.audioPlayItem];
        [_audioPlayer setVolume:musicVolume/100.0];
        [self reloadPlayVideoItemAction];
    }
}

- (void)userChangeOriginalVolume:(CGFloat)originalVolume musicVolume:(CGFloat)musicVolume {
    
    [self.player setVolume:originalVolume/100.0];
    [self.audioPlayer setVolume:musicVolume/100.0];
}

- (void)userFinishInputTextWithDataModel:(SDVideoPreviewEffectModel *)dataModel {
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    textLabel.backgroundColor = dataModel.backgroundColor;
    textLabel.textColor = dataModel.textColor;
    textLabel.userInteractionEnabled = YES;
    textLabel.font = dataModel.textFont;
    textLabel.layer.cornerRadius = 3.0f;
    textLabel.layer.masksToBounds = YES;
    textLabel.text = dataModel.text;
    textLabel.numberOfLines = 0;
    CGSize textSize = [textLabel sizeThatFits:CGSizeMake(self.view.width - 10 * 2 - 3 * 2, 0)];
    textSize = CGSizeMake(textSize.width + 3 * 2, textSize.height  + 3 * 2);
    if (textSize.height > self.view.height - 10 * 2 - 3 * 2) {
        textSize = CGSizeMake(textSize.width, self.view.height - 10 * 2);
    }
    textLabel.size = textSize;
    textLabel.center = CGPointMake(self.view.width/2.0, self.view.height/2.0);
    [textLabel addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(effectViewMoveAction:)]];
    [self.mainVideoView addSubview:textLabel];
    [self.effectViewArray addObject:@{@"data":dataModel,@"view":textLabel}];
}

- (void)userFinishSelectTagWithDataModel:(SDVideoPreviewEffectModel *)dataModel {
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:dataModel.image];
    imageView.size = dataModel.contentSize;
    imageView.center = CGPointMake(self.view.width/2.0, self.view.height/2.0);
    imageView.userInteractionEnabled = YES;
    [imageView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(effectViewMoveAction:)]];
    [self.mainVideoView addSubview:imageView];
    [self.effectViewArray addObject:@{@"data":dataModel,@"view":imageView}];
}

- (void)effectViewMoveAction:(UIPanGestureRecognizer *)panGestureRecognizer {
    
    CGPoint panPoint = [panGestureRecognizer locationInView:self.mainVideoView];

    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            self.deleteTextImageView.backgroundColor = [UIColor clearColor];
            [self.mainVideoView addSubview:self.deleteTextImageView];
            [UIView animateWithDuration:0.1 animations:^{
                panGestureRecognizer.view.center = [self loadTextButtonCenterWithDragPoint:panPoint];
            }];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            panGestureRecognizer.view.center = [self loadTextButtonCenterWithDragPoint:panPoint];
            break;
        }
        case UIGestureRecognizerStateEnded:{
            if (CGRectContainsPoint(_deleteTextImageView.frame,panGestureRecognizer.view.center)) {
                [panGestureRecognizer.view removeFromSuperview];
                for (NSDictionary *effectDictionary in self.effectViewArray) {
                    if ([effectDictionary[@"view"] isEqual:panGestureRecognizer.view]) {
                        [self.effectViewArray removeObject:effectDictionary];
                        break;
                    }
                }
            }
            [_deleteTextImageView removeFromSuperview];
            self.verticalLineLayer.hidden = YES;
            self.horizontalLineLayer.hidden = YES;
            break;
        }
        default:
            break;
    }
}

- (CGPoint)loadTextButtonCenterWithDragPoint:(CGPoint)dragPoint {
    
    CGPoint returnPoint = dragPoint;
    if (returnPoint.x >= self.mainVideoView.width/2.0 - 10.0 &&
        returnPoint.x <= self.mainVideoView.width/2.0 + 10.0) {
        returnPoint = CGPointMake(self.mainVideoView.width/2.0, returnPoint.y);
        [self loadLineLayer:self.verticalLineLayer hidden:NO];
    } else {
        [self loadLineLayer:self.verticalLineLayer hidden:YES];
    }
    if (returnPoint.y >= self.mainVideoView.height/2.0 - 10.0 &&
        returnPoint.y <= self.mainVideoView.height/2.0 + 10.0) {
        returnPoint = CGPointMake(returnPoint.x, self.mainVideoView.height/2.0);
        [self loadLineLayer:self.horizontalLineLayer hidden:NO];
    } else {
        [self loadLineLayer:self.horizontalLineLayer hidden:YES];
    }
    
    if (CGRectContainsPoint(_deleteTextImageView.frame,returnPoint)) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        _deleteTextImageView.backgroundColor = [UIColor hexStringToColor:self.config.tintColor alpha:0.8];
    } else {
        _deleteTextImageView.backgroundColor = [UIColor clearColor];
    }
    
    return returnPoint;
}

- (void)loadLineLayer:(CALayer *)lineLayer hidden:(BOOL)hidden {
    
    if (hidden == NO && lineLayer.hidden == YES) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    lineLayer.hidden = hidden;
}

#pragma mark - 视频播放完成通知

- (void)videoItemPlayFinishAction:(NSNotification *)notification {
    
    // 把当前播放完成的视频重新添加到队列中.
    AVPlayerItem *playItem = notification.object;
    if ([playItem isEqual:self.playItem]) {
        [self reloadPlayVideoItemAction];
    }
}

- (void)reloadPlayVideoItemAction {
    
    [self.player pause];
    self.player.currentItem.forwardPlaybackEndTime = self.player.currentItem.duration;
    [self.player.currentItem seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    if (self.audioPlayItem != nil) {
        [self.audioPlayer pause];
        [self.audioPlayer.currentItem seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        [self.audioPlayer play];
    }
    [self.player play];
}

#pragma mark - 系统方法

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


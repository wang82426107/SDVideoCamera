//
//  SDVideoCameraMenuView.m
//  FamilyClassroom
//
//  Created by 王巍栋 on 2020/1/13.
//  Copyright © 2020 Dong. All rights reserved.
//

#import "SDVideoCameraMenuView.h"
#import "SDVideoCameraPlayButton.h"
#import "SDVideoCameraAuthoView.h"
#import "SDVideoCaptureManager.h"
#import "UIButton+EdgeInsets.h"
#import "SDVideoDataManager.h"
#import <Photos/Photos.h>

@interface SDVideoCameraMenuView()<CAAnimationDelegate,SDVideoCameraAuthoDelegate>

@property(nonatomic,strong)SDVideoConfig *config;
@property(nonatomic,strong)UIView *progressView;
@property(nonatomic,strong)UIView *progressCurrentView;
@property(nonatomic,strong)SDVideoCameraPlayButton *playButton;
@property(nonatomic,strong)UIButton *deleteVideoButton;
@property(nonatomic,strong)UIButton *finishButton;
@property(nonatomic,strong)UIButton *albumButton;
@property(nonatomic,strong)NSMutableArray <CALayer *>*endLineArray;
@property(nonatomic,strong)NSMutableArray <UIButton *>*menuButtonArray;

@property(nonatomic,strong)UILabel *countDownLabel;

@property(nonatomic,strong)SDVideoCameraAuthoView *authoView;

@property(nonatomic,assign)BOOL isEndVideoWithEndTouch;
@property(nonatomic,assign)CGPoint playButtonCenter;
@property(nonatomic,copy)NSDate *startTime;
@property(nonatomic,assign)BOOL isTouch;

@end

@implementation SDVideoCameraMenuView

- (instancetype)initWithFrame:(CGRect)frame cameraConfig:(SDVideoConfig *)config {
    
    if (self = [super initWithFrame:frame]) {
        self.endLineArray = [NSMutableArray arrayWithCapacity:16];
        self.config = config;
        [self addSubview:self.closeButton];
        [self addSubview:self.progressView];
        [self addSubview:self.playButton];
        [self addSubview:self.albumButton];
        [self loadMenuButtonsAction];
        [self loadVideoDataObserverAction];
    }
    return self;
}

#pragma mark - 懒加载

- (void)loadVideoDataObserverAction {
    
    // 添加监听
    [[SDVideoDataManager defaultManager] addObserver:self forKeyPath:@"cameraState" options:NSKeyValueObservingOptionNew context:nil];
    [[SDVideoDataManager defaultManager] addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
    [[SDVideoDataManager defaultManager] addObserver:self forKeyPath:@"videoNumber" options:NSKeyValueObservingOptionNew context:nil];
}

- (SDVideoCameraAuthoView *)authoView {
    
    if (_authoView == nil) {
        _authoView = [[SDVideoCameraAuthoView alloc] initWithFrame:self.bounds];
        _authoView.delegate = self;
        [_authoView testAuthoStateAction];
    }
    return _authoView;
}

- (UIView *)progressView {
    
    if (_progressView == nil) {
        _progressView = [[UIView alloc] initWithFrame:CGRectMake(MenuProgressLeftDistance, MenuProgressTopDistance, self.width - MenuProgressLeftDistance * 2, 6)];
        _progressView.backgroundColor = [UIColor hexStringToColor:@"#000000" alpha:0.3];
        _progressView.layer.cornerRadius = 3.0f;
        _progressView.layer.masksToBounds = YES;
        [_progressView addSubview:self.progressCurrentView];
    }
    return _progressView;
}

- (UIView *)progressCurrentView {
    
    if (_progressCurrentView == nil) {
        _progressCurrentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.progressView.height)];
        _progressCurrentView.backgroundColor = [UIColor hexStringToColor:self.config.progressColor];
    }
    return _progressCurrentView;
}

- (UIButton *)closeButton {
    
    if (_closeButton == nil) {
        _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(MenuProgressLeftDistance * 2, self.progressView.bottom + MenuViewVerticalDistance, 30, 30)];
        [_closeButton setImage:[UIImage imageNamed:@"sd_commom_exit_icon"] forState:UIControlStateNormal];
    }
    return _closeButton;
}

- (UIButton *)albumButton {
    
    if (_albumButton == nil) {
        _albumButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _albumButton.center = CGPointMake(self.width/4.0 * 3, self.playButton.centerY);
        _albumButton.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
        _albumButton.adjustsImageWhenHighlighted = NO;
        _albumButton.imageView.layer.cornerRadius = 4.0f;
        _albumButton.imageView.layer.masksToBounds = YES;
        _albumButton.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        _albumButton.imageView.layer.borderWidth = 2.0f;
        [_albumButton setTitle:@"上传" forState:UIControlStateNormal];
        [_albumButton setTitleColor:[UIColor hexStringToColor:@"ffffff"] forState:UIControlStateNormal];
        [_albumButton setImage:[UIImage imageNamed:@"sd_camera_upload"] forState:UIControlStateNormal];
        [_albumButton addTarget:self action:@selector(showAlbumAction) forControlEvents:UIControlEventTouchUpInside];
        [_albumButton layoutButtonWithEdgeInsetsStyle:ButtonEdgeInsetsStyleImageTop imageTitlespace:5];
    }
    return _albumButton;
}

- (SDVideoCameraPlayButton *)playButton {
    
    if (_playButton == nil) {
        _playButton = [[SDVideoCameraPlayButton alloc] initWithFrame:CGRectMake(self.width/2.0 - 40, self.height - 40 - 80, 80, 80) config:self.config];
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressClick:)];
        longPressGesture.minimumPressDuration = 0.3;
        [_playButton addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playButtonTapAction)]];
        [_playButton addGestureRecognizer: longPressGesture];
    }
    return _playButton;
}

- (UIButton *)deleteVideoButton {
    
    if (_deleteVideoButton == nil) {
        _deleteVideoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 20)];
        [_deleteVideoButton setImage:[UIImage imageNamed:@"sd_camera_menu_delete_icon"] forState:UIControlStateNormal];
        CGFloat distance = (self.width - _playButton.right)/3.0;
        _deleteVideoButton.centerY = self.playButton.centerY;
        _deleteVideoButton.centerX = distance + self.playButton.right;
        [_deleteVideoButton addTarget:self action:@selector(deleteLastVideoAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteVideoButton;
}

- (UIButton *)finishButton {
    
    if (_finishButton == nil) {
        _finishButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [_finishButton setImage:[[UIImage imageNamed:@"sd_camera_menu_finish_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        CGFloat distance = (self.width - _playButton.right)/3.0;
        _finishButton.tintColor = [UIColor hexStringToColor:self.config.tintColor];
        _finishButton.centerY = self.playButton.centerY;
        _finishButton.centerX = distance * 2 + self.playButton.right;
        [_finishButton addTarget:self action:@selector(finishVideoAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishButton;
}

- (UILabel *)countDownLabel {
    
    if (_countDownLabel == nil) {
        _countDownLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _countDownLabel.font = [UIFont systemFontOfSize:150 weight:UIFontWeightBold];
        _countDownLabel.textAlignment = NSTextAlignmentCenter;
        _countDownLabel.textColor = [UIColor hexStringToColor:@"ffffff"];
        _countDownLabel.text = @"3";
    }
    return _countDownLabel;
}

#pragma mark - 加载侧边按钮

- (void)loadMenuButtonsAction {
    
    self.menuButtonArray = [NSMutableArray arrayWithCapacity:4];
    CGFloat startY = self.progressView.bottom;
    CGFloat buttonWidth = 80;
    CGFloat buttonHeight = 80;
    for (SDVideoMenuDataModel *menuDataModel in self.config.menuDataArray) {
        UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        menuButton.tag = 1000000 + menuDataModel.menuType;
        menuButton.frame = CGRectMake(self.width - buttonWidth, startY, buttonWidth, buttonHeight);
        menuButton.adjustsImageWhenHighlighted = NO;
        menuButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [menuButton setImage:[UIImage imageNamed:menuDataModel.normalImageName] forState:UIControlStateNormal];
        [menuButton setImage:[UIImage imageNamed:menuDataModel.selectImageName] forState:UIControlStateSelected];
        [menuButton setTitle:menuDataModel.normalTitle forState:UIControlStateNormal];
        [menuButton setTitle:menuDataModel.selectTitle forState:UIControlStateSelected];
        [menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [menuButton layoutButtonWithEdgeInsetsStyle:ButtonEdgeInsetsStyleImageTop imageTitlespace:5];
        [menuButton addTarget:self action:@selector(userClickOutButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:menuButton];
        [self.menuButtonArray addObject:menuButton];
        startY += buttonHeight;
        if (menuDataModel.menuType == VideoMenuTypesFlashlight) {
            menuButton.selected = !self.config.isOpenFlashlight;
            [self  userClickOutButton:menuButton];
        }
    }
}

#pragma mark - 按钮事件处理

- (void)playButtonTapAction {
    
    switch (_playButton.buttonState) {
        case PlayButtonStateNomal:{
            [SDVideoDataManager defaultManager].cameraState = VideoCameraStateInProgress;
            self.playButton.buttonState = PlayButtonStateTouch;
            break;
        }
        case PlayButtonStateTouch:{
            [SDVideoDataManager defaultManager].cameraState = VideoCameraStatePause;
            self.playButton.buttonState = PlayButtonStateNomal;
            break;
        }
        default:
            break;
    }
}

-(void)longPressClick:(UILongPressGestureRecognizer *)press {
    
    if(press.state == UIGestureRecognizerStateBegan){
        [SDVideoDataManager defaultManager].cameraState = VideoCameraStateInProgress;
        self.playButton.buttonState = PlayButtonStateMove;
        _playButtonCenter = self.playButton.center;
    } else if (press.state == UIGestureRecognizerStateEnded){
        [SDVideoDataManager defaultManager].cameraState = VideoCameraStatePause;
        [UIView animateWithDuration:0.2 animations:^{
            self.playButton.frame = CGRectMake(self.width/2.0 - 40, self.height - 40 - 80, 80, 80);
        } completion:^(BOOL finished) {
            self.playButton.buttonState = PlayButtonStateNomal;
        }];
    } else {
        CGPoint point = [press locationInView:self];
        _playButton.center = point;
        self.playButtonCenter = point;
    }
}

- (void)setPlayButtonCenter:(CGPoint)playButtonCenter {
    
    if (sqrt(pow((_playButtonCenter.x - playButtonCenter.x), 2) + pow((_playButtonCenter.y - playButtonCenter.y), 2)) < 20) {
        return;
    }
    
    int orientation = _playButtonCenter.y - playButtonCenter.y > 0 ? TouchMoveOrientationUp : TouchMoveOrientationDown;
    _playButtonCenter = playButtonCenter;
    
    CGFloat maxY = self.height - 40 - 80/2.0;
    CGFloat minY = self.progressView.bottom + 80.0/2.0;
     
    float scale = 0;
    if (_playButtonCenter.y >= maxY) {
        scale = 0;
    } else if (_playButtonCenter.y <= minY) {
        scale = 1;
    } else {
        scale = (maxY - _playButtonCenter.y)/(maxY - minY);
    }
    if (_delegate != nil && [_delegate respondsToSelector:@selector(userChangeVideoZoomFactorWithScale:orientation:)]) {
        [_delegate userChangeVideoZoomFactorWithScale:scale orientation:orientation];
    }
}

- (void)userClickOutButton:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(userClickOutMenuButtonWithButtonType:)]) {
        [self.delegate userClickOutMenuButtonWithButtonType:sender.tag - 1000000];
    }
    if (sender.tag - 1000000 == VideoMenuTypesCountDown) {
        [self startCountDownAnimationAction];
    }
}

- (void)showAlbumAction {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    switch (status) {
        case PHAuthorizationStatusNotDetermined:{
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(userClickAlbumAction)]) {
                            [self.delegate userClickAlbumAction];
                        }
                    });
                } else {
                    [self showSettingAlertControllerAction];
                }
            }];
            break;
        }
        case PHAuthorizationStatusRestricted: {
            UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:@"访问受限" message:@"手机相册访问受限" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alertViewController addAction:cancelAction];
            [self.superViewController presentViewController:alertViewController animated:YES completion:nil];
            break;
        }
        case PHAuthorizationStatusDenied: {
            [self showSettingAlertControllerAction];
            break;
        }
        case PHAuthorizationStatusAuthorized: {
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(userClickAlbumAction)]) {
                [self.delegate userClickAlbumAction];
            }
            break;
        }
    }
}

- (void)showSettingAlertControllerAction {
    
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:@"提示" message:@"相机权限被禁用,请到设置中授予该应用允许访问相册权限" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertViewController addAction:cancelAction];
    [alertViewController addAction:okAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.superViewController presentViewController:alertViewController animated:YES completion:nil];
    });
}

- (void)startCountDownAnimationAction {
    
    [self addSubview:self.countDownLabel];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.delegate = self;
    animation.duration = 1.0;
    animation.fromValue = @(1.0);
    animation.toValue = @(1.5);
    animation.repeatCount = 1;
    [self.countDownLabel.layer addAnimation:animation forKey:@"scaleAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    int showNumber = [self.countDownLabel.text intValue] - 1;
    [self.countDownLabel.layer removeAnimationForKey:@"scaleAnimation"];
    if (showNumber > 0) {
        self.countDownLabel.text = [NSString stringWithFormat:@"%d",showNumber];
        [self startCountDownAnimationAction];
    } else {
        [self.countDownLabel removeFromSuperview];
        self.countDownLabel.text = @"3";
        [self playButtonTapAction];
    }
}

#pragma mark - 监听操作

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    // 相机状态发生改变
    if ([keyPath isEqualToString:@"cameraState"]) {
        [_albumButton removeFromSuperview];
        switch ([SDVideoDataManager defaultManager].cameraState) {
            case VideoCameraStateIdle:{
                [self addSubview:self.albumButton];
                break;
            }
            case VideoCameraStateInProgress:{
                [self removeSubViewViewAction];
                break;
            }
            case VideoCameraStatePause:{
                self.playButton.frame = CGRectMake(self.width/2.0 - 40, self.height - 40 - 80, 80, 80);
                self.playButton.buttonState = PlayButtonStateNomal;
                [self addSubViewViewAction];
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(userEndChangeVideoZoomFactor)]) {
                    [self.delegate userEndChangeVideoZoomFactor];
                }
                break;
            }
            case VideoCameraStateStop: {
                self.playButton.frame = CGRectMake(self.width/2.0 - 40, self.height - 40 - 80, 80, 80);
                self.playButton.buttonState = PlayButtonStateNomal;
                [self addSubViewViewAction];
                break;
            }
        }
    }
    if ([keyPath isEqualToString:@"progress"]) {
        self.progressCurrentView.width = self.progressView.width * [SDVideoDataManager defaultManager].progress;
    }
    if ([keyPath isEqualToString:@"videoNumber"]) {
        [self drawProgressEndLineAction];
        if ([SDVideoDataManager defaultManager].videoNumber != 0) {
            [self addSubview:self.deleteVideoButton];
            [self addSubview:self.finishButton];
        } else {
            [self.deleteVideoButton removeFromSuperview];
            [self.finishButton removeFromSuperview];
        }
    }
}

// 录制的时候需要移除的按钮
- (void)removeSubViewViewAction {
    
    [self.deleteVideoButton removeFromSuperview];
    [self.finishButton removeFromSuperview];
    [self.closeButton removeFromSuperview];
    [self.menuButtonArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

// 录制完成需要添加的按钮
- (void)addSubViewViewAction {
    
    [self addSubview:self.deleteVideoButton];
    [self addSubview:self.finishButton];
    [self addSubview:self.closeButton];
    for (UIButton *menuButton in self.menuButtonArray) {
        [self addSubview:menuButton];
    }
}

// 删除上一个视频
- (void)deleteLastVideoAction {
    
    [[SDVideoDataManager defaultManager] deleteLastVideoModel];
    
    SDVideoDataModel *dataModel = [SDVideoDataManager defaultManager].videoDataArray.lastObject;
    CGFloat currentWidth = dataModel.progress * self.progressView.width;

    [UIView animateWithDuration:0.3 animations:^{
        self.progressCurrentView.width = currentWidth;
    } completion:^(BOOL finished) {
        [SDVideoDataManager defaultManager].progress = dataModel.progress;
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(deleteLaseVideoDataAction)]) {
            [self.delegate deleteLaseVideoDataAction];
        }
    }];
}

// 完成录制
- (void)finishVideoAction {
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(userFinishMergeVideoAction)]) {
        [_delegate userFinishMergeVideoAction];
    }
}

// 绘制分段视频的结束线
- (void)drawProgressEndLineAction {
    
    [self.endLineArray makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.endLineArray removeAllObjects];
    
    for (SDVideoDataModel *dataModel in [SDVideoDataManager defaultManager].videoDataArray) {
        CALayer *endLineLayer = [[CALayer alloc] init];
        endLineLayer.backgroundColor = [UIColor whiteColor].CGColor;
        endLineLayer.frame = CGRectMake(dataModel.progress * self.progressView.width, 0, 1.5, self.progressView.height);
        [self.progressView.layer addSublayer:endLineLayer];
        [self.endLineArray addObject:endLineLayer];
    }
}

// 检测设备状态
- (BOOL)isOpenAllDeviceAuthoStateAction {
    
    if ([SDVideoCaptureManager isOpenCameraAuthStatus] == AVAuthorizationStatusAuthorized &&
        [SDVideoCaptureManager isOpenMicrophoneAuthStatus] == AVAuthorizationStatusAuthorized) {
        return YES;
    } else {
        self.authoView.top = self.height;
        [self addSubview:self.authoView];
        [self addSubview:self.closeButton];
        [UIView animateWithDuration:0.3 animations:^{
            self.authoView.top = 0;
        }];
        return NO;
    }
}

- (void)userOpenAllDerviceAuthoAction {
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(userOpenAllDerviceAuthoAction)]) {
        [_delegate userOpenAllDerviceAuthoAction];
    }
}

- (void)dealloc {
    
    [[SDVideoDataManager defaultManager] removeObserver:self forKeyPath:@"videoNumber"];
    [[SDVideoDataManager defaultManager] removeObserver:self forKeyPath:@"cameraState"];
    [[SDVideoDataManager defaultManager] removeObserver:self forKeyPath:@"progress"];
}


@end

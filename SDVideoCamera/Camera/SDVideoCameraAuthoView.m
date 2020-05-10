//
//  SDVideoCameraAuthoView.m
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/29.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDVideoCameraAuthoView.h"
#import "UIColor+HexStringColor.h"
#import "SDVideoCaptureManager.h"
#import "UIView+Extension.h"

@interface SDVideoCameraAuthoView ()

@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *subTitleLabel;
@property(nonatomic,strong)UIButton *cameraAuthoButton;
@property(nonatomic,strong)UIButton *microAuthoButton;

@end

@implementation SDVideoCameraAuthoView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor hexStringToColor:@"000000" alpha:0.8];
        self.userInteractionEnabled = YES;
        [self addSubview:self.titleLabel];
        [self addSubview:self.subTitleLabel];
        [self addSubview:self.cameraAuthoButton];
        [self addSubview:self.microAuthoButton];
        [self testAuthoStateAction];
    }
    return self;
}

- (UILabel *)titleLabel {
    
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.subTitleLabel.top - 30 - 10, self.width, 30)];
        _titleLabel.textColor = [UIColor hexStringToColor:@"ffffff"];
        _titleLabel.font = [UIFont boldSystemFontOfSize:30];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"拍摄音乐短视频";
    }
    return _titleLabel;;
}

- (UILabel *)subTitleLabel {
    
    if (_subTitleLabel == nil) {
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.height/2.0 - 20 - 30, self.width, 30)];
        _subTitleLabel.textColor = [UIColor hexStringToColor:@"787878"];
        _subTitleLabel.font = [UIFont systemFontOfSize:16];
        _subTitleLabel.textAlignment = NSTextAlignmentCenter;
        _subTitleLabel.text = @"允许访问即可进入拍摄";
    }
    return _subTitleLabel;;
}

- (UIButton *)cameraAuthoButton {
    
    if (_cameraAuthoButton == nil) {
        _cameraAuthoButton = [[UIButton alloc] initWithFrame:CGRectMake(10, self.height/2.0 + 20, self.width - 10 * 2, 30)];
        _cameraAuthoButton.tintColor = [UIColor hexStringToColor:@"737373"];
        [_cameraAuthoButton setTitle:@"启用相机访问权限" forState:UIControlStateNormal];
        [_cameraAuthoButton setTitle:@" 启用相机访问权限" forState:UIControlStateSelected];
        [_cameraAuthoButton setTitle:@"相机不可用" forState:UIControlStateDisabled];
        [_cameraAuthoButton setTitleColor:[UIColor hexStringToColor:@"4cb0c1"] forState:UIControlStateNormal];
        [_cameraAuthoButton setTitleColor:[UIColor hexStringToColor:@"737373"] forState:UIControlStateSelected];
        [_cameraAuthoButton setTitleColor:[UIColor hexStringToColor:@"737373"] forState:UIControlStateDisabled];
        [_cameraAuthoButton setImage:[[UIImage imageNamed:@"sd_camera_autho_open_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
        [_cameraAuthoButton addTarget:self action:@selector(cameraAuthoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraAuthoButton;
}

- (UIButton *)microAuthoButton {
    
    if (_microAuthoButton == nil) {
        _microAuthoButton = [[UIButton alloc] initWithFrame:CGRectMake(10, self.cameraAuthoButton.bottom + 20, self.width - 10 * 2, 30)];
        _microAuthoButton.tintColor = [UIColor hexStringToColor:@"737373"];
        [_microAuthoButton setTitle:@"启用麦克风访问权限" forState:UIControlStateNormal];
        [_microAuthoButton setTitle:@" 启用麦克风访问权限" forState:UIControlStateSelected];
        [_microAuthoButton setTitle:@"麦克风不可用" forState:UIControlStateDisabled];
        [_microAuthoButton setTitleColor:[UIColor hexStringToColor:@"4cb0c1"] forState:UIControlStateNormal];
        [_microAuthoButton setTitleColor:[UIColor hexStringToColor:@"737373"] forState:UIControlStateSelected];
        [_microAuthoButton setTitleColor:[UIColor hexStringToColor:@"737373"] forState:UIControlStateDisabled];
        [_microAuthoButton setImage:[[UIImage imageNamed:@"sd_camera_autho_open_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
        [_microAuthoButton addTarget:self action:@selector(microAuthoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _microAuthoButton;
}

#pragma mark - 点击事件

- (void)testAuthoStateAction {
    
    self.cameraAuthoButton.enabled = YES;
    self.cameraAuthoButton.selected = NO;
    switch ([SDVideoCaptureManager isOpenCameraAuthStatus]) {
        case AVAuthorizationStatusNotDetermined:case AVAuthorizationStatusDenied:
            self.cameraAuthoButton.selected = NO;
            break;
        case AVAuthorizationStatusRestricted:
            self.cameraAuthoButton.enabled = NO;
            self.cameraAuthoButton.selected = YES;
            break;
        case AVAuthorizationStatusAuthorized:
            self.cameraAuthoButton.selected = YES;
            break;
    }
    
    self.microAuthoButton.enabled = YES;
    self.microAuthoButton.selected = NO;
    switch ([SDVideoCaptureManager isOpenMicrophoneAuthStatus]) {
        case AVAuthorizationStatusNotDetermined:case AVAuthorizationStatusDenied:
            self.microAuthoButton.selected = NO;
            break;
        case AVAuthorizationStatusRestricted:
            self.microAuthoButton.enabled = NO;
            self.microAuthoButton.selected = YES;
            break;
        case AVAuthorizationStatusAuthorized:
            self.microAuthoButton.selected = YES;
            break;
    }
    
    if ([SDVideoCaptureManager isOpenCameraAuthStatus] == AVAuthorizationStatusAuthorized &&
        [SDVideoCaptureManager isOpenMicrophoneAuthStatus] == AVAuthorizationStatusAuthorized) {
        [UIView animateWithDuration:0.2 animations:^{
            self.top = self.height;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
        if (_delegate != nil && [_delegate respondsToSelector:@selector(userOpenAllDerviceAuthoAction)]) {
            [_delegate userOpenAllDerviceAuthoAction];
        }
    }
}

- (void)cameraAuthoButtonAction {
    
    if (self.cameraAuthoButton.selected) {
        return;
    }
    
    switch ([SDVideoCaptureManager isOpenCameraAuthStatus]) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self testAuthoStateAction];
                });
            }];
            break;
        }
        case AVAuthorizationStatusRestricted: {
            self.cameraAuthoButton.enabled = NO;
            self.cameraAuthoButton.selected = YES;
            break;
        }
        case AVAuthorizationStatusDenied: {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            self.cameraAuthoButton.selected = YES;
            break;
        }
    }
}

- (void)microAuthoButtonAction {
    
    if (self.microAuthoButton.selected) {
        return;
    }
    
    switch ([SDVideoCaptureManager isOpenMicrophoneAuthStatus]) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self testAuthoStateAction];
                });
            }];
            break;
        }
        case AVAuthorizationStatusRestricted: {
            self.microAuthoButton.enabled = NO;
            self.microAuthoButton.selected = YES;
            break;
        }
        case AVAuthorizationStatusDenied: {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            self.microAuthoButton.selected = YES;
            break;
        }
    }
    
}

@end

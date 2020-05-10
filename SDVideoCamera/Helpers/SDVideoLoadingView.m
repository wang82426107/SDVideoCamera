//
//  SDVideoLoadingView.m
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/28.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDVideoLoadingView.h"
#import "UIColor+HexStringColor.h"
#import "UIView+Extension.h"

@interface SDVideoLoadingView ()

@property(nonatomic,strong)UIView *mainView;
@property(nonatomic,strong)UIImageView *loadingImageView;
@property(nonatomic,strong)UILabel *loadingLabel;

@end

@implementation SDVideoLoadingView

static SDVideoLoadingView *loadingView;

+ (SDVideoLoadingView *)defaultManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (loadingView == nil) {
            loadingView = [[SDVideoLoadingView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            loadingView.userInteractionEnabled = YES;
            [loadingView addSubview:loadingView.mainView];
        }
    });
    return loadingView;
}

- (UIView *)mainView {
    
    if (_mainView == nil) {
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _mainView.backgroundColor = [UIColor hexStringToColor:@"000000" alpha:0.2];
        _mainView.layer.cornerRadius = 3.0f;
        _mainView.layer.masksToBounds = YES;
        _mainView.center = self.center;
        [_mainView addSubview:self.loadingImageView];
        [_mainView addSubview:self.loadingLabel];
    }
    return _mainView;
}

- (UIImageView *)loadingImageView {
    
    if (_loadingImageView == nil) {
        NSMutableArray *framesArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < 60; i++) {
            UIImage *imageName = [UIImage imageNamed:[NSString stringWithFormat:@"sd_video_loading%d@2x",i]];
            [framesArray addObject:imageName];
        }
        _loadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, self.mainView.width, 32)];
        _loadingImageView.contentMode = UIViewContentModeScaleAspectFit;
        _loadingImageView.animationImages = framesArray;
        _loadingImageView.animationDuration = 1.0;
        [_loadingImageView startAnimating];
    }
    return _loadingImageView;
}

- (UILabel *)loadingLabel {
    
    if (_loadingLabel == nil) {
        _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.loadingImageView.bottom , self.mainView.width, 40)];
        _loadingLabel.textAlignment = NSTextAlignmentCenter;
        _loadingLabel.font = [UIFont systemFontOfSize:12];
        _loadingLabel.textColor = [UIColor whiteColor];
        _loadingLabel.text = @"奋力加载中...";
    }
    return _loadingLabel;
}

+ (void)showLoadingAction {
    
    [[UIApplication sharedApplication].delegate.window addSubview:[SDVideoLoadingView defaultManager]];
}

+ (void)dismissLoadingAction {
    
    [[SDVideoLoadingView defaultManager] removeFromSuperview];
}

@end

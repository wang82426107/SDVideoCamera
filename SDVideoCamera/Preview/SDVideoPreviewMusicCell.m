//
//  SDVideoPreviewMusicCell.m
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/30.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDVideoPreviewMusicCell.h"
#import "UIColor+HexStringColor.h"
#import "UIView+Extension.h"

@interface SDVideoPreviewMusicCell ()

@property(nonatomic,strong)UIImageView *musicImageView;
@property(nonatomic,strong)UILabel *musicNameLabel;
@property(nonatomic,strong)UIActivityIndicatorView *indicatorView; // 系统自带加载

@end

@implementation SDVideoPreviewMusicCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.musicImageView];
        [self addSubview:self.musicNameLabel];
    }
    return self;
}

#pragma mark - 懒加载

- (UIImageView *)musicImageView {
    
    if (_musicImageView == nil) {
        _musicImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, self.width, self.width)];
        self.musicImageView.layer.borderColor = [UIColor hexStringToColor:@"fbc835"].CGColor;
        _musicImageView.contentMode = UIViewContentModeScaleAspectFill;
        _musicImageView.clipsToBounds = YES;
    }
    return _musicImageView;
}

- (UILabel *)musicNameLabel {
    
    if (_musicNameLabel == nil) {
        _musicNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.musicImageView.bottom, self.width, self.height - self.musicImageView.bottom)];
        _musicNameLabel.textColor = [UIColor hexStringToColor:@"ffffff"];
        _musicNameLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _musicNameLabel.textAlignment = NSTextAlignmentCenter;
        _musicNameLabel.font = [UIFont systemFontOfSize:12];
    }
    return _musicNameLabel;
}

- (UIActivityIndicatorView *)indicatorView {
    if (_indicatorView == nil) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
        _indicatorView.frame= self.musicImageView.bounds;
        _indicatorView.color = [UIColor lightGrayColor];
        _indicatorView.center = self.center;
        _indicatorView.backgroundColor = [UIColor clearColor];
    }
    return _indicatorView;
}

- (void)setDataModel:(SDVideoMusicModel *)dataModel {
    
    _dataModel = dataModel;
    self.musicNameLabel.text = dataModel.musicTitle;
    if (dataModel.musicImageName != nil) {
        self.musicImageView.image = [UIImage imageNamed:dataModel.musicImageName];
    }
    if (dataModel.musicImageURL != nil) {
        if (dataModel.musicImageData != nil) {
            self.musicImageView.image = [UIImage imageWithData:dataModel.musicImageData];
        } else {
            self.musicImageView.image = [UIImage imageNamed:@"sd_preview_music_default_image"];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData* imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dataModel.musicImageURL]];
                self.dataModel.musicImageData = imageData;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.musicImageView.image = [UIImage imageWithData:imageData];
                });
            });
        }
    }
    if (self.dataModel.state == SDVideoMusicStateDownLoad) {
        [self.musicImageView addSubview:self.indicatorView];
        [self.indicatorView startAnimating];
    } else {
        [_indicatorView stopAnimating];
        [_indicatorView removeFromSuperview];
    }
}

- (void)setIsSelect:(BOOL)isSelect {
    
    _isSelect = isSelect;
    
    if (isSelect) {
        self.musicImageView.layer.borderWidth = 2.0;
    } else {
        self.musicImageView.layer.borderWidth = 0;
    }
}

@end

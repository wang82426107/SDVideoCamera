//
//  SDVideoAlbumSelectCell.m
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/19.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDVideoAlbumSelectCell.h"
#import "UIColor+HexStringColor.h"
#import "UIView+Extension.h"

@interface SDVideoAlbumSelectCell ()

@property(nonatomic,strong)UIImageView *bgImageView;
@property(nonatomic,strong)UIButton *deleteButton;
@property(nonatomic,strong)UILabel *timeLabel;

@end

@implementation SDVideoAlbumSelectCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.bgImageView];
        [self addSubview:self.deleteButton];
        [self addSubview:self.timeLabel];
    }
    return self;
}

- (UIImageView *)bgImageView {
    
    if (_bgImageView == nil) {
        _bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageView.clipsToBounds = YES;
    }
    return _bgImageView;
}

- (UIButton *)deleteButton {
    
    if (_deleteButton == nil) {
        _deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 20, 0, 20, 20)];
        _deleteButton.backgroundColor = [UIColor hexStringToColor:@"000000" alpha:0.3];
        _deleteButton.adjustsImageWhenHighlighted = NO;
        [_deleteButton setImage:[UIImage imageNamed:@"sd_album_delete_icon"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

- (UILabel *)timeLabel {
    
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.height - 20, self.width, 20)];
        _timeLabel.textColor = [UIColor hexStringToColor:@"ffffff"];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont systemFontOfSize:12];
    }
    return _timeLabel;
}

- (void)setBgImage:(UIImage *)bgImage {
    
    _bgImage = bgImage;
    self.bgImageView.image = bgImage;
}

- (void)setAsset:(PHAsset *)asset {
    
    _asset = asset;
    _timeLabel.text = [NSString stringWithFormat:@"%02d:%02d",((int)asset.duration)/60,((int)asset.duration)%60];
}

- (void)deleteButtonAction {
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(userDeleteVideoWithDataIndex:)]) {
        [self.delegate userDeleteVideoWithDataIndex:self.dataIndex];
    }
}

@end

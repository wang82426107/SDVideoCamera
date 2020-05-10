//
//  SDVideoAlbumCell.m
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/19.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDVideoAlbumCell.h"
#import "UIColor+HexStringColor.h"
#import "UIView+Extension.h"

@interface SDVideoAlbumCell ()

@property(nonatomic,strong)UIImageView *bgImageView;
@property(nonatomic,strong)UILabel *numberLabel;
@property(nonatomic,strong)UILabel *timeLabel;

@end

@implementation SDVideoAlbumCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.bgImageView];
        [self addSubview:self.numberLabel];
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

- (UILabel *)timeLabel {
    
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, self.height - 20, self.width - 5 * 2, 20)];
        _timeLabel.textColor = [UIColor hexStringToColor:@"ffffff"];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.font = [UIFont systemFontOfSize:12];
    }
    return _timeLabel;
}

- (UILabel *)numberLabel {
    
    if (_numberLabel == nil) {
        _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.width - 10 - 20, 10, 20, 20)];
        _numberLabel.textColor = [UIColor hexStringToColor:@"000000"];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.font = [UIFont systemFontOfSize:12];
        _numberLabel.layer.cornerRadius = 10.0;
        _numberLabel.layer.masksToBounds = YES;
        _numberLabel.layer.borderColor = [UIColor hexStringToColor:@"f5f5f5"].CGColor;
    }
    return _numberLabel;
}

- (void)setBgImage:(UIImage *)bgImage {
    
    _bgImage = bgImage;
    self.bgImageView.image = bgImage;
}

- (void)setAsset:(PHAsset *)asset {
    
    _asset = asset;
    _timeLabel.text = [NSString stringWithFormat:@"%02d:%02d",((int)asset.duration)/60,((int)asset.duration)%60];
}

- (void)setSelectNumber:(int)selectNumber {
    
    _selectNumber = selectNumber;
    
    if (selectNumber == - 1) {
        self.numberLabel.text = nil;
        self.numberLabel.backgroundColor = [UIColor hexStringToColor:@"ffffff" alpha:0];
        self.numberLabel.layer.borderWidth = 1.0f;
    } else {
        self.numberLabel.text = [NSString stringWithFormat:@"%d",selectNumber];
        self.numberLabel.backgroundColor = [UIColor hexStringToColor:@"ffffff"];
        self.numberLabel.layer.borderWidth = 0.0f;
    }
}

@end

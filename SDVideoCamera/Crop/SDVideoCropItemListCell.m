//
//  SDVideoCropItemListCell.m
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/27.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDVideoCropItemListCell.h"
#import "UIView+Extension.h"

@interface SDVideoCropItemListCell ()

@property(nonatomic,strong)UIImageView *frameImageView;
@property(nonatomic,strong)UILabel *timeLabel;

@end

@implementation SDVideoCropItemListCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.frameImageView];
    }
    return self;
}

-(UIImageView *)frameImageView {
    
    if (_frameImageView == nil) {
        CGFloat frameImageHeight = self.height > 60 ? 60.0f : self.height * 0.8;
        _frameImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frameImageHeight, frameImageHeight)];
        _frameImageView.center = CGPointMake(self.width/2.0, self.height/2.0);
        _frameImageView.contentMode = UIViewContentModeScaleAspectFill;
        _frameImageView.layer.cornerRadius = 3.0f;
        _frameImageView.layer.masksToBounds = YES;
        _frameImageView.clipsToBounds = YES;
        [_frameImageView addSubview:self.timeLabel];
    }
    return _frameImageView;
}

- (UILabel *)timeLabel {
    
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] initWithFrame:self.frameImageView.bounds];
        _timeLabel.font = [UIFont boldSystemFontOfSize:12];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [UIColor whiteColor];
    }
    return _timeLabel;
}

- (void)setVideoAsset:(AVAsset *)videoAsset {
    
    _videoAsset = videoAsset;
    self.timeLabel.text = [NSString stringWithFormat:@"%.1fs",CMTimeGetSeconds(videoAsset.duration)];
}

- (void)setVideoImage:(UIImage *)videoImage {
    
    _videoImage = videoImage;
    self.frameImageView.image = videoImage;
}

@end

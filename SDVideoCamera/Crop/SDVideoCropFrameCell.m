//
//  SDVideoCropFrameCell.m
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/21.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDVideoCropFrameCell.h"

@interface SDVideoCropFrameCell ()

@property(nonatomic,strong)UIImageView *bgImageView;

@end

@implementation SDVideoCropFrameCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.bgImageView];
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

- (void)setFrameModel:(SDVideoCropFrameModel *)frameModel {
    
    _frameModel = frameModel;
    _bgImageView.frame = self.bounds;
    self.bgImageView.image = frameModel.frameImage;
}

@end

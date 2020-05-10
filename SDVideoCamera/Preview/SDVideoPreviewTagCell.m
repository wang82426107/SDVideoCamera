//
//  SDVideoPreviewTagCell.m
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/5/5.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDVideoPreviewTagCell.h"
#import "UIView+Extension.h"

@interface SDVideoPreviewTagCell ()

@property(nonatomic,strong)UIImageView *imageView;

@end

@implementation SDVideoPreviewTagCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.imageView];
    }
    return self;
}

- (UIImageView *)imageView {
    
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width * 0.8, self.height * 0.8)];
        _imageView.center = CGPointMake(self.width/2.0, self.height/2.0);
        _imageView.contentMode = UIViewContentModeCenter;
    }
    return _imageView;
}

- (void)setImageName:(NSString *)imageName {
    
    _imageName = imageName;
    self.imageView.image = [UIImage imageNamed:imageName];
}

@end

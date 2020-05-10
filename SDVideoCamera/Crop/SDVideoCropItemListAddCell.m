//
//  SDVideoCropItemListAddCell.m
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/27.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDVideoCropItemListAddCell.h"
#import "UIView+Extension.h"

@interface SDVideoCropItemListAddCell ()

@property(nonatomic,strong)UIImageView *frameImageView;

@end

@implementation SDVideoCropItemListAddCell

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
        _frameImageView.image = [UIImage imageNamed:@"sd_corp_add_icon"];
        _frameImageView.center = CGPointMake(self.width/2.0, self.height/2.0);
        _frameImageView.contentMode = UIViewContentModeScaleAspectFill;
        _frameImageView.layer.cornerRadius = 3.0f;
        _frameImageView.layer.masksToBounds = YES;
        _frameImageView.clipsToBounds = YES;
    }
    return _frameImageView;
}




@end

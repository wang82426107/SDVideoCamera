//
//  SDVideoPreviewTextColorCell.m
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/5/2.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDVideoPreviewTextColorCell.h"
#import "UIColor+HexStringColor.h"
#import "UIView+Extension.h"

@interface SDVideoPreviewTextColorCell ()

@property(nonatomic,strong)UIView *colorView;

@end

@implementation SDVideoPreviewTextColorCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.colorView];
    }
    return self;
}

- (UIView *)colorView {
    
    if (_colorView == nil) {
        _colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width/2.0, self.width/2.0)];
        _colorView.center = CGPointMake(self.width/2.0, self.width/2.0);
        _colorView.layer.borderColor = [UIColor whiteColor].CGColor;
        _colorView.layer.cornerRadius = _colorView.width/2.0;
        _colorView.layer.masksToBounds = YES;
        _colorView.layer.borderWidth = 2.0f;
    }
    return _colorView;
}

- (void)setHexColorString:(NSString *)hexColorString {
    
    _hexColorString = hexColorString;
    _colorView.backgroundColor = [UIColor hexStringToColor:hexColorString];
}

- (void)setIsSelect:(BOOL)isSelect {
    
    _isSelect = isSelect;
    if (isSelect) {
        _colorView.size = CGSizeMake(self.width * 0.6, self.width * 0.6);
        _colorView.layer.cornerRadius = _colorView.width/2.0;
    } else {
        _colorView.size = CGSizeMake(self.width/2.0, self.width/2.0);
        _colorView.layer.cornerRadius = _colorView.width/2.0;
    }
    _colorView.center = CGPointMake(self.width/2.0, self.width/2.0);
}

@end


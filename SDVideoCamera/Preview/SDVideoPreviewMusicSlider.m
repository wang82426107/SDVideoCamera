//
//  SDVideoPreviewMusicSlider.m
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/5/1.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDVideoPreviewMusicSlider.h"
#import "UIColor+HexStringColor.h"

@interface SDVideoPreviewMusicSlider ()

@property(nonatomic,assign)CGRect thumbRect;
@property(nonatomic,strong)UILabel *valueLabel;

@end

@implementation SDVideoPreviewMusicSlider

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.isUserInterface = YES;
    }
    return self;
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    
    CGRect thumbRect = [super thumbRectForBounds:bounds trackRect:rect value:value];
    self.thumbRect = thumbRect;
    self.valueText = [NSString stringWithFormat:@"%.0f", self.value];
    return thumbRect;
}

#pragma mark - Setter functions

- (void)setValueText:(NSString *)valueText {
    
    _valueText = valueText;
    self.valueLabel.text = valueText;
    [self.valueLabel sizeToFit];
    self.valueLabel.center = CGPointMake(self.thumbRect.origin.x + self.thumbRect.size.width/2.0, self.thumbRect.origin.y - self.valueLabel.bounds.size.height/2.0);
    
    if (!self.valueLabel.superview) {
        [self addSubview:self.valueLabel];
    }
}

#pragma mark - Getter functions

- (UILabel *)valueLabel {
    
    if (_valueLabel == nil) {
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _valueLabel.textColor = _valueTextColor ?: [UIColor whiteColor];
        _valueLabel.font = _valueFont ?: [UIFont systemFontOfSize:14.0];
        _valueLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _valueLabel;
}

- (void)setIsUserInterface:(BOOL)isUserInterface {
    
    _isUserInterface = isUserInterface;
    self.userInteractionEnabled = isUserInterface;
    if (isUserInterface) {
        self.minimumTrackTintColor = [UIColor hexStringToColor:@"fbc835"];
        self.maximumTrackTintColor = [UIColor hexStringToColor:@"ffffff"];
        self.thumbTintColor = [UIColor hexStringToColor:@"ffffff"];
        [self setThumbImage:[UIImage imageNamed:@"sd_preview_music_volume_icon"] forState:UIControlStateNormal];
    } else {
        self.minimumTrackTintColor = [UIColor hexStringToColor:@"7a6c1e"];
        self.maximumTrackTintColor = [UIColor hexStringToColor:@"7b7b7b"];
        self.thumbTintColor = [UIColor hexStringToColor:@"808080"];
        [self setThumbImage:[UIImage imageNamed:@"sd_preview_music_volume_icon"] forState:UIControlStateNormal];
    }
}

- (void)setValueFont:(UIFont *)valueFont {
    
    _valueFont = valueFont;
    self.valueLabel.font = valueFont;
}

- (void)setValueTextColor:(UIColor *)valueTextColor {
    
    _valueTextColor = valueTextColor;
    self.valueLabel.textColor = valueTextColor;
}

@end

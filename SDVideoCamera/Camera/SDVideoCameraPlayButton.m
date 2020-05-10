//
//  SDVideoCameraPlayButton.m
//  FamilyClassroom
//
//  Created by 王巍栋 on 2020/1/13.
//  Copyright © 2020 Dong. All rights reserved.
//

#import "SDVideoCameraPlayButton.h"
#import "SDVideoCameraHeader.h"

@interface SDVideoCameraPlayButton ()

@property(nonatomic,strong)SDVideoConfig *config;
@property(nonatomic,strong)CAShapeLayer *ringShapeLayer;
@property(nonatomic,strong)CALayer *mainLayer;
@property(nonatomic,strong)UIBezierPath *normalPath;
@property(nonatomic,strong)UIBezierPath *selectMinPath;
@property(nonatomic,strong)UIBezierPath *selectMaxPath;
@property(nonatomic,assign)CGFloat mainLayerScale;

@end

@implementation SDVideoCameraPlayButton

- (instancetype)initWithFrame:(CGRect)frame config:(SDVideoConfig *)config {
    
    if (self = [super initWithFrame:frame]) {
        self.layer.masksToBounds = NO;
        self.mainLayerScale = 1;
        self.config = config;
        [self.layer addSublayer:self.ringShapeLayer];
        [self.layer addSublayer:self.mainLayer];
    }
    return self;
}

#pragma mark - 懒加载

- (CAShapeLayer *)ringShapeLayer {
    
    if (_ringShapeLayer == nil) {
        _ringShapeLayer = [[CAShapeLayer alloc] init];
        _ringShapeLayer.strokeColor = [UIColor hexStringToColor:self.config.tintColor alpha:0.5].CGColor;
        _ringShapeLayer.fillColor = [UIColor clearColor].CGColor;
        _ringShapeLayer.path = self.normalPath.CGPath;
        _ringShapeLayer.lineWidth = 8;
    }
    return _ringShapeLayer;
}

- (CALayer *)mainLayer {

    if (_mainLayer == nil) {
        _mainLayer = [[CALayer alloc] init];
        _mainLayer.backgroundColor = [UIColor hexStringToColor:self.config.tintColor].CGColor;
        _mainLayer.frame = CGRectMake(6, 6, self.frame.size.width - 12, self.frame.size.height - 12);
        _mainLayer.cornerRadius = _mainLayer.frame.size.height/2.0;
        _mainLayer.masksToBounds = YES;
    }
    return _mainLayer;
}

- (UIBezierPath *)normalPath {
    
    if (_normalPath == nil) {
        CGFloat radius = self.frame.size.width/2.0;
        _normalPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0) radius:radius startAngle:0 endAngle:2 * M_PI clockwise:false];
    }
    return _normalPath;
}

- (UIBezierPath *)selectMinPath {
    
    if (_selectMinPath == nil) {
        CGFloat radius = self.frame.size.width/2.0 + 10;
        _selectMinPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0) radius:radius startAngle:0 endAngle:2 * M_PI clockwise:false];
    }
    return _selectMinPath;
}

- (UIBezierPath *)selectMaxPath {
    
    if (_selectMaxPath == nil) {
        CGFloat radius = self.frame.size.width/2.0 + 8;
        _selectMaxPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0) radius:radius startAngle:0 endAngle:2 * M_PI clockwise:false];
    }
    return _selectMaxPath;
}

- (void)setButtonState:(PlayButtonState)buttonState {
    
    // 状态是否已经发生了改变
    BOOL stateIsChange = buttonState == _buttonState ? NO : YES;
    _buttonState = buttonState;
    if (!stateIsChange) {
        return;
    }
    [self.mainLayer removeAllAnimations];
    [self.ringShapeLayer removeAllAnimations];
    switch (buttonState) {
        case PlayButtonStateNomal:{
            _ringShapeLayer.lineWidth = 8;
            _ringShapeLayer.path = self.normalPath.CGPath;
            _mainLayer.frame = CGRectMake(6, 6, self.frame.size.width - 12, self.frame.size.height - 12);
            _mainLayer.cornerRadius = _mainLayer.frame.size.height/2.0;
            _mainLayer.masksToBounds = YES;
            _mainLayerScale = 1;
            break;
        }
        case PlayButtonStateTouch:{
            self.mainLayer.cornerRadius = 15.0f;
            CABasicAnimation *sizeAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            sizeAnimation.fromValue = @(_mainLayerScale);
            sizeAnimation.toValue = @(0.6f);
            sizeAnimation.fillMode = kCAFillModeForwards;
            sizeAnimation.repeatCount = 1;
            sizeAnimation.duration = 0.3f;
            sizeAnimation.removedOnCompletion = NO;
            [self.mainLayer addAnimation:sizeAnimation forKey:@"sizeAnimation"];
            [self addRingShapeLayerAnimationAction];
            _mainLayerScale = 0.5;
            break;
        }
        case PlayButtonStateMove:{
            CABasicAnimation *sizeAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            sizeAnimation.fromValue = @(_mainLayerScale);
            sizeAnimation.toValue = @(0);
            sizeAnimation.fillMode = kCAFillModeForwards;
            sizeAnimation.repeatCount = 1;
            sizeAnimation.duration = 0.3f;
            sizeAnimation.removedOnCompletion = NO;
            [self.mainLayer addAnimation:sizeAnimation forKey:@"sizeAnimation"];
            [self addRingShapeLayerAnimationAction];
            _mainLayerScale = 0;
            break;
        }
    }
}

- (void)addRingShapeLayerAnimationAction {
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.fromValue = (id)self.selectMinPath.CGPath;
    pathAnimation.toValue = (id)self.selectMaxPath.CGPath;
    pathAnimation.duration = 0.5f;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.autoreverses = YES;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.repeatCount = MAXFLOAT;
    CABasicAnimation *lineWidthAnimation = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
    lineWidthAnimation.fromValue = @(8);
    lineWidthAnimation.toValue = @(12);
    lineWidthAnimation.duration = 0.5f;
    lineWidthAnimation.fillMode = kCAFillModeForwards;
    lineWidthAnimation.autoreverses = YES;
    lineWidthAnimation.removedOnCompletion = NO;
    lineWidthAnimation.repeatCount = MAXFLOAT;
    [self.ringShapeLayer addAnimation:pathAnimation forKey:@"pathAnimation"];
    [self.ringShapeLayer addAnimation:lineWidthAnimation forKey:@"lineWidthAnimation"];
}



@end

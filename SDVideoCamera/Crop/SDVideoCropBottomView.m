//
//  SDVideoCropBottomView.m
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/20.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDVideoCropBottomView.h"
#import "SDVideoCropItemListView.h"
#import "UIColor+HexStringColor.h"
#import "SDVideoCropFrameView.h"
#import "UIView+Extension.h"
#import "SDVideoUtils.h"

@interface SDVideoCropBottomView ()<SDVideoCropVideoDragDelegate>

@property(nonatomic,strong)UILabel *selectTimeLabel;
@property(nonatomic,strong)UIButton *reloadSelectButton;
@property(nonatomic,strong)SDVideoCropFrameView *cropFrameView;
@property(nonatomic,strong)SDVideoCropItemListView *itemListView;
@property(nonatomic,strong)UICollectionView *videoCollectionView;

@property(nonatomic,strong)SDVideoCropDataManager *dataManager;

@end

@implementation SDVideoCropBottomView

- (instancetype)initWithFrame:(CGRect)frame dataManager:(SDVideoCropDataManager *)dataManager {

    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor hexStringToColor:@"15181f"];
        self.dataManager = dataManager;
        [self addDataObserverAction];
        [self addSubview:self.selectTimeLabel];
        [self addSubview:self.cropFrameView];
        [self addSubview:self.itemListView];
    }
    return self;
}

#pragma mark - 懒加载

- (UILabel *)selectTimeLabel {
    
    if (_selectTimeLabel == nil) {
        _selectTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.width - 10 * 2, 30)];
        _selectTimeLabel.text = [NSString stringWithFormat:@"已选取 %.1fs",CMTimeGetSeconds(self.dataManager.playTimeRange.duration)];
        _selectTimeLabel.textColor = [UIColor hexStringToColor:@"ffffff"];
        _selectTimeLabel.font = [UIFont boldSystemFontOfSize:12];
        _selectTimeLabel.userInteractionEnabled = YES;
    }
    return _selectTimeLabel;
}

- (UIButton *)reloadSelectButton {
    
    if (_reloadSelectButton == nil) {
        _reloadSelectButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 26)];
        _reloadSelectButton.backgroundColor = [UIColor hexStringToColor:self.dataManager.config.tintColor];
        _reloadSelectButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        _reloadSelectButton.centerY = self.selectTimeLabel.height/2.0;
        _reloadSelectButton.right = self.selectTimeLabel.width;
        _reloadSelectButton.layer.cornerRadius = 13.0f;
        _reloadSelectButton.layer.masksToBounds = YES;
        [_reloadSelectButton setTitle:@"重置" forState:UIControlStateNormal];
        [_reloadSelectButton addTarget:self action:@selector(reloadSelectButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reloadSelectButton;
}

- (SDVideoCropFrameView *)cropFrameView {
    
    if (_cropFrameView == nil) {
        _cropFrameView = [[SDVideoCropFrameView alloc] initWithFrame:CGRectMake(0, _selectTimeLabel.bottom, self.width, 100) dataManager:self.dataManager];
        _cropFrameView.delegate = self;
    }
    return _cropFrameView;
}

- (SDVideoCropItemListView *)itemListView {
    
    if (_itemListView == nil) {
        _itemListView = [[SDVideoCropItemListView alloc] initWithFrame:CGRectMake(0, self.cropFrameView.bottom, self.width, self.height - self.cropFrameView.bottom) dataManager:self.dataManager];
    }
    return _itemListView;
}

#pragma mark - 点击方法

- (void)reloadSelectButtonAction {
     
    self.dataManager.playTimeRange = self.dataManager.playTotalTimeRange;
    self.dataManager.currentPlayTime = kCMTimeZero;
    [self.cropFrameView reloadPlayTimeRangeAction];
}

#pragma mark - 拖拽代理方法

- (void)userStartChangeVideoTimeRangeAction {
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(userStartChangeVideoTimeRangeAction)]) {
        [_delegate userStartChangeVideoTimeRangeAction];
    }
}

- (void)userChangeVideoTimeRangeAction {
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(userChangeVideoTimeRangeAction)]) {
        [_delegate userChangeVideoTimeRangeAction];
    }
}

- (void)userEndChangeVideoTimeRangeAction {
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(userEndChangeVideoTimeRangeAction)]) {
        [_delegate userEndChangeVideoTimeRangeAction];
    }
}

#pragma mark - 数据监听观察

- (void)addDataObserverAction {
    
    [self.dataManager addObserver:self forKeyPath:@"playTimeRange" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"playTimeRange"]) {
        self.selectTimeLabel.text = [NSString stringWithFormat:@"已选取 %.1fs",CMTimeGetSeconds(self.dataManager.playTimeRange.duration)];
        if (CMTimeCompare(self.dataManager.playTimeRange.duration,self.dataManager.playTotalTimeRange.duration) == 0) {
            [_reloadSelectButton removeFromSuperview];
        } else {
            [self.selectTimeLabel addSubview:self.reloadSelectButton];
        }
    }
}

#pragma mark - 系统方法

- (void)dealloc {

    [self.dataManager removeObserver:self forKeyPath:@"playTimeRange"];
}

@end

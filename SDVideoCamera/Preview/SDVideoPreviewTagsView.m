//
//  SDVideoPreviewTagsView.m
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/5/5.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDVideoPreviewTagsView.h"
#import "UIColor+HexStringColor.h"
#import "SDVideoPreviewTagCell.h"
#import "UIView+Extension.h"

@interface SDVideoPreviewTagsView ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

@property(nonatomic,strong)SDVideoConfig *config;
@property(nonatomic,strong)UIView *mainView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UICollectionView *colletionView;

@end

@implementation SDVideoPreviewTagsView

- (instancetype)initWithFrame:(CGRect)frame config:(SDVideoConfig *)config {
    
    if (self = [super initWithFrame:frame]) {
        self.config = config;
        [self addSubview:self.mainView];
    }
    return self;
}

#pragma mark - 懒加载

- (UIView *)mainView {
    
    if (_mainView == nil) {
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, StatusHeight + NavigationBarHeight, self.width, self.height - (StatusHeight + NavigationBarHeight))];
        _mainView.backgroundColor = [UIColor hexStringToColor:@"000000" alpha:0.8];
        [_mainView addSubview:self.titleLabel];
        [_mainView addSubview:self.colletionView];
    }
    return _mainView;
}

- (UILabel *)titleLabel {
    
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.mainView.width, 60)];
        _titleLabel.textColor = [UIColor hexStringToColor:@"ffffff"];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.text = @"贴纸";
        CALayer *lineLayer = [[CALayer alloc] init];
        lineLayer.frame = CGRectMake(0, _titleLabel.height - 1, _titleLabel.width, 0.5);
        lineLayer.backgroundColor = [UIColor hexStringToColor:@"333333"].CGColor;
        [_titleLabel.layer addSublayer:lineLayer];
    }
    return _titleLabel;
}

- (UICollectionView *)colletionView {
    
    if (_colletionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(self.mainView.width/4.0, self.mainView.width/4.0);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        _colletionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.titleLabel.bottom, self.mainView.width, self.mainView.height - self.titleLabel.bottom) collectionViewLayout:layout];
        _colletionView.backgroundColor = [UIColor clearColor];
        _colletionView.showsVerticalScrollIndicator = NO;
        _colletionView.dataSource = self;
        _colletionView.delegate = self;
        [_colletionView registerClass:[SDVideoPreviewTagCell class] forCellWithReuseIdentifier:@"SDVideoPreviewTagCell"];
    }
    return _colletionView;
}

#pragma mark - UICollectionViewDelegateFlowLayout,UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.config.previewTagImageNameArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SDVideoPreviewTagCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SDVideoPreviewTagCell" forIndexPath:indexPath];
    cell.imageName = self.config.previewTagImageNameArray[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UIImage *contentImage = [UIImage imageNamed:self.config.previewTagImageNameArray[indexPath.row]];
    SDVideoPreviewEffectModel *dataModel = [[SDVideoPreviewEffectModel alloc] init];
    dataModel.contentSize = contentImage.size;
    dataModel.type = EffectDataTypeImage;
    dataModel.image = contentImage;
    if (_delegate != nil && [_delegate respondsToSelector:@selector(userFinishSelectTagWithDataModel:)]) {
        [_delegate userFinishSelectTagWithDataModel:dataModel];
    }
    [self removeFromSuperview];
}

#pragma mark - 显示与隐藏

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    
    if (!CGRectContainsPoint(self.mainView.frame, touchPoint)) {
        [self dismissViewAction];
    }
}

- (void)showViewAction {
    
    self.mainView.top = self.height;
    [UIView animateWithDuration:0.3 animations:^{
        self.mainView.bottom = self.height;
    }];
}

- (void)dismissViewAction {
    
    [UIView animateWithDuration:0.2 animations:^{
        self.mainView.top = self.height;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


@end


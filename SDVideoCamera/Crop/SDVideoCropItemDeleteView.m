//
//  SDVideoCropItemDeleteView.m
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/27.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDVideoCropItemDeleteView.h"
#import "UIColor+HexStringColor.h"
#import "UIView+Extension.h"

@interface SDVideoCropItemDeleteView ()

@property(nonatomic,strong)UIView *lineView;
@property(nonatomic,strong)UIButton *deleteButton;
@property(nonatomic,strong)UIButton *cancleButton;
@property(nonatomic,strong)UIImageView *imageView;

@property(nonatomic,strong)SDVideoCropDataManager *dataManager;

@end

@implementation SDVideoCropItemDeleteView

- (instancetype)initWithFrame:(CGRect)frame dataManager:(SDVideoCropDataManager *)dataManager {

    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor hexStringToColor:@"15181f"];
        self.dataManager = dataManager;
        [self addSubview:self.deleteButton];
        [self addSubview:self.imageView];
        [self addSubview:self.cancleButton];
        [self addSubview:self.lineView];
    }
    return self;
}

- (UIView *)lineView {
    
    if (_lineView == nil) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0.5f)];
        _lineView.backgroundColor = [UIColor hexStringToColor:@"666666"];
    }
    return _lineView;;
}

- (UIButton *)deleteButton {
    
    if (_deleteButton == nil) {
        _deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, 60, self.height)];
        _deleteButton.adjustsImageWhenHighlighted = NO;
        [_deleteButton setImage:[UIImage imageNamed:@"sd_corp_delete_icon"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

- (UIImageView *)imageView {
    
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.height/2.0, self.height/2.0)];
        _imageView.layer.borderColor = [UIColor hexStringToColor:@"fbc835"].CGColor;
        _imageView.center = CGPointMake(self.width/2.0, self.height/2.0);
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.cornerRadius = 2.0f;
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.borderWidth = 1.0f;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UIButton *)cancleButton {
    
    if (_cancleButton == nil) {
        _cancleButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 20 - 60, 0, 60, self.height)];
        _cancleButton.adjustsImageWhenHighlighted = NO;
        [_cancleButton setImage:[UIImage imageNamed:@"sd_corp_cancle_icon"] forState:UIControlStateNormal];
        [_cancleButton addTarget:self action:@selector(cancleButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancleButton;
}

- (void)setIndexRow:(NSInteger)indexRow {
    
    _indexRow = indexRow;
}

- (void)setSelectImage:(UIImage *)selectImage {
    
    _selectImage = selectImage;
    _imageView.image = selectImage;
}

- (void)cancleButtonAction {
    
    [UIView animateWithDuration:0.2 animations:^{
        self.top = self.height;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)deleteButtonAction {
    
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:@"是否删除此片段?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self cancleButtonAction];
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(userDeletVideoAssetWithIndexRow:)]) {
            [self.delegate userDeletVideoAssetWithIndexRow:self.indexRow];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertViewController addAction:deleteAction];
    [alertViewController addAction:cancelAction];
    [self.dataManager.superViewController presentViewController:alertViewController animated:YES completion:nil];
}

@end

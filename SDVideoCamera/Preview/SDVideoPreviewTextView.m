//
//  SDVideoPreviewTextView.m
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/5/1.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDVideoPreviewTextView.h"
#import "SDVideoPreviewTextColorCell.h"
#import "UIColor+HexStringColor.h"
#import "UIView+Extension.h"

typedef enum : NSUInteger {
    TextAlignmentStyleLeft,
    TextAlignmentStyleCenter,
    TextAlignmentStyleRight,
} TextAlignmentStyle;

typedef enum : NSUInteger {
    TextColorStyleText,
    TextColorStyleBackground,
    TextColorStyleAlpha,
} TextColorStyle;

@interface SDVideoPreviewTextView ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

@property(nonatomic,assign)TextAlignmentStyle alignmentStyle;
@property(nonatomic,assign)TextColorStyle colorStyle;
@property(nonatomic,assign)NSTextAlignment textAlignment;

@property(nonatomic,strong)NSString *selectFontName;
@property(nonatomic,strong)NSString *selectColor;

@property(nonatomic,strong)SDVideoConfig *config;

@property(nonatomic,strong)UIButton *finishButton;
@property(nonatomic,strong)UITextField *inputTextView;

@property(nonatomic,strong)UIView *bottomView;

@property(nonatomic,strong)UIButton *colorButton;
@property(nonatomic,strong)UIButton *alignmentButton;
@property(nonatomic,strong)UICollectionView *fontCollectionView;
@property(nonatomic,strong)UICollectionView *colorCollectionView;

@end

@implementation SDVideoPreviewTextView

- (instancetype)initWithFrame:(CGRect)frame config:(SDVideoConfig *)config {
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor hexStringToColor:@"000000" alpha:0.8];
        self.config = config;
        self.selectColor = self.config.previewColorArray.firstObject;
        [self addSubview:self.finishButton];
        [self addSubview:self.inputTextView];
        [self addSubview:self.bottomView];
        self.alignmentStyle = TextAlignmentStyleCenter;
        self.colorStyle = TextColorStyleText;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (UIButton *)finishButton {
    
    if (_finishButton == nil) {
        _finishButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 15 - 60, 15, 60, 36)];
        _finishButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_finishButton setTitle:@"完成" forState:UIControlStateNormal];
        [_finishButton setTitleColor:[UIColor hexStringToColor:@"ffffff"] forState:UIControlStateNormal];
        [_finishButton addTarget:self action:@selector(finishAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishButton;
}

- (UITextField *)inputTextView {
    
    if (_inputTextView == nil) {
        _inputTextView = [[UITextField alloc] initWithFrame:CGRectMake(20, self.finishButton.bottom + 20, self.width - 40, 60)];
        _inputTextView.centerY = (self.bottomView.top - 20 - (self.finishButton.bottom + 20))/2.0 + self.finishButton.bottom + 20;
        _inputTextView.tintColor = [UIColor hexStringToColor:@"fbc835"];
        _inputTextView.font = [UIFont boldSystemFontOfSize:30];
        _inputTextView.backgroundColor = [UIColor clearColor];
        _inputTextView.textAlignment = NSTextAlignmentCenter;
        _inputTextView.layer.cornerRadius = 4.0f;
        _inputTextView.layer.masksToBounds = YES;
    }
    return _inputTextView;
}

- (UIView *)bottomView {
    
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 100, self.width, 100)];
        [_bottomView addSubview:self.colorButton];
        [_bottomView addSubview:self.alignmentButton];
        [_bottomView addSubview:self.fontCollectionView];
        [_bottomView addSubview:self.colorCollectionView];
    }
    return _bottomView;
}

- (UIButton *)colorButton {
    
    if (_colorButton == nil) {
        _colorButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 0, 40, self.bottomView.height/2.0)];
        [_colorButton addTarget:self action:@selector(changeTextColorStyleAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _colorButton;
}

- (UIButton *)alignmentButton {
    
    if (_alignmentButton == nil) {
        _alignmentButton = [[UIButton alloc] initWithFrame:CGRectMake(15 + self.colorButton.right, 0, 40, self.bottomView.height/2.0)];
        [_alignmentButton addTarget:self action:@selector(changeTextAlignmentStyleAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _alignmentButton;
}

- (UICollectionView *)colorCollectionView {
    
    if (_colorCollectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(self.bottomView.height/2.0, self.bottomView.height/2.0);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        _colorCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.bottomView.height/2.0, self.bottomView.width, self.bottomView.height/2.0) collectionViewLayout:layout];
        _colorCollectionView.backgroundColor = [UIColor clearColor];
        _colorCollectionView.showsHorizontalScrollIndicator = NO;
        _colorCollectionView.dataSource = self;
        _colorCollectionView.delegate = self;
        [_colorCollectionView registerClass:[SDVideoPreviewTextColorCell class] forCellWithReuseIdentifier:@"SDVideoPreviewTextColorCell"];
    }
    return _colorCollectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.config.previewColorArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SDVideoPreviewTextColorCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SDVideoPreviewTextColorCell" forIndexPath:indexPath];
    cell.hexColorString = self.config.previewColorArray[indexPath.row];
    cell.isSelect = [self.config.previewColorArray[indexPath.row] isEqualToString:self.selectColor];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectColor = self.config.previewColorArray[indexPath.row];
    [self reloadColorSettingAction];
    [collectionView reloadData];
}

#pragma mark - 事件响应

- (void)showViewAction {
    
    [self.inputTextView becomeFirstResponder];
}

- (void)dismissViewAction {
    
    if (self.inputTextView.text.length != 0) {
        
        SDVideoPreviewEffectModel *effectModel = [[SDVideoPreviewEffectModel alloc] init];
        effectModel.contentSize = [_inputTextView sizeThatFits:CGSizeZero];
        effectModel.backgroundColor = _inputTextView.backgroundColor;
        effectModel.textColor = _inputTextView.textColor;
        effectModel.textFont = _inputTextView.font;
        effectModel.text = _inputTextView.text;
        effectModel.textFontSize = 30;
        if (_delegate != nil && [_delegate respondsToSelector:@selector(userFinishInputTextWithDataModel:)]) {
            [_delegate userFinishInputTextWithDataModel:effectModel];
        }
    }
    self.inputTextView.text = nil;
}

- (void)finishAction {
    
    [self removeFromSuperview];
}

- (void)changeTextColorStyleAction {
    
    if (self.colorStyle == 2) {
        self.colorStyle = 0;
    } else {
        self.colorStyle ++;
    }
}

- (void)changeTextAlignmentStyleAction {
    
    if (self.alignmentStyle == 2) {
        self.alignmentStyle = 0;
    } else {
        self.alignmentStyle ++;
    }
}

- (void)setAlignmentStyle:(TextAlignmentStyle)alignmentStyle {
    
    _alignmentStyle = alignmentStyle;
    switch (alignmentStyle) {
        case TextAlignmentStyleLeft:{
            self.textAlignment = NSTextAlignmentLeft;
            [self.alignmentButton setImage:[UIImage imageNamed:@"sd_preview_alignment_left"] forState:UIControlStateNormal];
            break;
        }
        case TextAlignmentStyleCenter:{
            self.textAlignment = NSTextAlignmentCenter;
            [self.alignmentButton setImage:[UIImage imageNamed:@"sd_preview_alignment_center"] forState:UIControlStateNormal];
            break;
        }
        case TextAlignmentStyleRight:{
            self.textAlignment = NSTextAlignmentRight;
            [self.alignmentButton setImage:[UIImage imageNamed:@"sd_preview_alignment_right"] forState:UIControlStateNormal];
            break;
        }
    }
}

- (void)setColorStyle:(TextColorStyle)colorStyle {
    
    _colorStyle = colorStyle;
    [self reloadColorSettingAction];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    
    _textAlignment = textAlignment;
    self.inputTextView.textAlignment = textAlignment;
}

- (void)reloadColorSettingAction {
    
    UIColor *textColor = [UIColor whiteColor];
    if ([self.selectColor isEqualToString:@"ffffff"] ||
        [self.selectColor isEqualToString:@"FFFFFF"] ||
        [self.selectColor isEqualToString:@"#ffffff"] ||
        [self.selectColor isEqualToString:@"#FFFFFF"]) {
        textColor = [UIColor hexStringToColor:@"c0c0c0"];
    }
    switch (self.colorStyle) {
        case TextColorStyleText:
            self.inputTextView.backgroundColor = [UIColor clearColor];
            self.inputTextView.textColor = [UIColor hexStringToColor:self.selectColor];
            [self.colorButton setImage:[UIImage imageNamed:@"sd_preview_color_text"] forState:UIControlStateNormal];
            break;
        case TextColorStyleBackground:
            self.inputTextView.backgroundColor = [UIColor hexStringToColor:self.selectColor];
            self.inputTextView.textColor = textColor;
            [self.colorButton setImage:[UIImage imageNamed:@"sd_preview_color_bg"] forState:UIControlStateNormal];
            break;
        case TextColorStyleAlpha:
            self.inputTextView.backgroundColor = [UIColor hexStringToColor:self.selectColor alpha:0.5];
            self.inputTextView.textColor = textColor;
            [self.colorButton setImage:[UIImage imageNamed:@"sd_preview_color_alpha"] forState:UIControlStateNormal];
            break;
    }
}

#pragma mark - 系统相关

- (void)keyBoardWillShow:(NSNotification *)notification {

    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    float height = keyboardRect.size.height;
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [UIView animateWithDuration:animationDuration animations:^{
        self.bottomView.bottom = KNoSafeHeight - height;
        self.inputTextView.centerY = (self.bottomView.top - 20 - (self.finishButton.bottom + 20))/2.0 + self.finishButton.bottom + 20;
    }];
}

- (void)keyBoardWillHide:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [UIView animateWithDuration:animationDuration animations:^{
        self.bottomView.bottom = KNoSafeHeight;
        self.inputTextView.centerY = (self.bottomView.top - 20 - (self.finishButton.bottom + 20))/2.0 + self.finishButton.bottom + 20;
    } completion:^(BOOL finished) {
        [self dismissViewAction];
        [self removeFromSuperview];
    }];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

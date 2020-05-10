//
//  SDVideoPreviewMusicView.m
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/30.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDVideoPreviewMusicView.h"
#import "SDVideoPreviewMusicSlider.h"
#import "SDVideoPreviewMusicCell.h"
#import "UIColor+HexStringColor.h"
#import "UIView+Extension.h"
#import "UIImage+Color.h"
#import "UIView+Toast.h"
#import "SDVideoUtils.h"

typedef enum : NSUInteger {
    TabbarSelectTypeUnkonw,
    TabbarSelectTypeMusic,
    TabbarSelectTypeVolume,
} TabbarSelectType;

@interface SDVideoPreviewMusicView ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property(nonatomic,weak)SDVideoConfig *config;
@property(nonatomic,assign)TabbarSelectType selectType;

@property(nonatomic,weak)UIViewController *superViewController;

@property(nonatomic,strong)NSMutableArray <SDVideoMusicModel *>*musicDataArray;

@property(nonatomic,strong)UIView *mainView;
@property(nonatomic,strong)UIButton *musicButton;
@property(nonatomic,strong)UIButton *volumeButton;
@property(nonatomic,strong)UIView *topLineView;
@property(nonatomic,strong)UIView *centerLineView;

@property(nonatomic,strong)UIView *musicView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UICollectionView *collectionView;

@property(nonatomic,strong)UIView *volumeView;
@property(nonatomic,strong)UILabel *originalLabel;
@property(nonatomic,strong)SDVideoPreviewMusicSlider *originalVolumeView;
@property(nonatomic,strong)UILabel *musicLabel;
@property(nonatomic,strong)SDVideoPreviewMusicSlider *musicVolumeView;

@property(nonatomic,strong)SDVideoMusicModel *selectModel;

@end

@implementation SDVideoPreviewMusicView

- (instancetype)initWithFrame:(CGRect)frame config:(SDVideoConfig *)config superViewController:(UIViewController *)superViewController {
    
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.config = config;
        self.superViewController = superViewController;
        [self addSubview:self.mainView];
        [self loadRecommendListDataArrayAction];
        __weak typeof(self) weakSelf = self;
        self.config.finishBlock = ^(SDVideoMusicModel *selectModel) {
            weakSelf.selectModel = selectModel;
            [weakSelf.musicDataArray insertObject:selectModel atIndex:1];
            [weakSelf.collectionView reloadData];
        };
    }
    return self;
}

- (void)loadRecommendListDataArrayAction {
    
    self.musicDataArray = [NSMutableArray arrayWithCapacity:16];
    SDVideoMusicModel *moreMusicModel = [[SDVideoMusicModel alloc] init];
    moreMusicModel.musicTitle = @"更多";
    moreMusicModel.musicImageName = @"sd_preview_music_more_icon";
    [self.musicDataArray addObject:moreMusicModel];
    [self.musicDataArray addObjectsFromArray:self.config.recommendMusicList];
    [self.collectionView reloadData];
}

#pragma mark - 懒加载

- (UIView *)mainView {
    
    if (_mainView == nil) {
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height, self.width, 200)];
        _mainView.backgroundColor = [UIColor hexStringToColor:@"000000" alpha:0.9];
        [_mainView addSubview:self.musicButton];
        [_mainView addSubview:self.volumeButton];
        [_mainView addSubview:self.topLineView];
        [_mainView addSubview:self.centerLineView];
        [_mainView addSubview:self.musicView];
        [_mainView addSubview:self.volumeView];
    }
    return _mainView;
}

- (UIButton *)musicButton {
    
    if (_musicButton == nil) {
        _musicButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.mainView.height - 50, self.mainView.width/2.0, 50)];
        _musicButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _musicButton.selected = YES;
        [_musicButton setTitle:@"配乐" forState:UIControlStateNormal];
        [_musicButton setTitleColor:[UIColor hexStringToColor:@"666666"] forState:UIControlStateNormal];
        [_musicButton setTitleColor:[UIColor hexStringToColor:@"ffffff"] forState:UIControlStateSelected];
        [_musicButton addTarget:self action:@selector(userSelectMusicTabbarAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _musicButton;
}

- (UIButton *)volumeButton {
    
    if (_volumeButton == nil) {
        _volumeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.mainView.width/2.0, self.mainView.height - 50, self.mainView.width/2.0, 50)];
        _volumeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_volumeButton setTitle:@"音量" forState:UIControlStateNormal];
        [_volumeButton setTitleColor:[UIColor hexStringToColor:@"666666"] forState:UIControlStateNormal];
        [_volumeButton setTitleColor:[UIColor hexStringToColor:@"ffffff"] forState:UIControlStateSelected];
        [_volumeButton addTarget:self action:@selector(userSelectVolumeTabbarAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _volumeButton;
}

- (UIView *)topLineView {
    
    if (_topLineView == nil) {
        _topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.volumeButton.top, self.mainView.width, 0.5f)];
        _topLineView.backgroundColor = [UIColor hexStringToColor:@"333333"];
    }
    return _topLineView;
}

- (UIView *)centerLineView {
    
    if (_centerLineView == nil) {
        _centerLineView = [[UIView alloc] initWithFrame:CGRectMake(self.volumeButton.left, self.volumeButton.top + self.volumeButton.height/4.0, 0.5f, self.volumeButton.height/2.0)];
        _centerLineView.backgroundColor = [UIColor hexStringToColor:@"333333"];
    }
    return _centerLineView;
}

- (UIView *)musicView {
    
    if (_musicView == nil) {
        _musicView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mainView.width, self.mainView.height - self.musicButton.height)];
        [_musicView addSubview:self.titleLabel];
        [_musicView addSubview:self.collectionView];
    }
    return _musicView;
}

- (UILabel *)titleLabel {
    
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.musicView.width - 20, 30)];
        _titleLabel.textColor = [UIColor hexStringToColor:@"ffffff"];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.text = @"推荐";
    }
    return _titleLabel;
}

- (UICollectionView *)collectionView {
    
    if (_collectionView == nil) {
        
        CGFloat itemHeight = self.musicButton.top - self.titleLabel.bottom;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(60, itemHeight);
        layout.minimumInteritemSpacing = 10;
        layout.minimumLineSpacing = 20;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.titleLabel.bottom, self.width, itemHeight) collectionViewLayout:layout];
        _collectionView.contentInset = UIEdgeInsetsMake(0, 20, 0, 20);
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[SDVideoPreviewMusicCell class] forCellWithReuseIdentifier:@"SDVideoPreviewMusicCell"];
    }
    return _collectionView;
}

- (UIView *)volumeView {
    
    if (_volumeView == nil) {
        _volumeView = [[UIView alloc] initWithFrame:CGRectMake(self.mainView.width, 0, self.mainView.width, self.mainView.height - self.musicButton.height)];
        [_volumeView addSubview:self.originalLabel];
        [_volumeView addSubview:self.originalVolumeView];
        [_volumeView addSubview:self.musicLabel];
        [_volumeView addSubview:self.musicVolumeView];
    }
    return _volumeView;
}

- (UILabel *)originalLabel {
    
    if (_originalLabel == nil) {
        _originalLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 20, 40, 60)];
        _originalLabel.textColor = [UIColor hexStringToColor:@"ffffff"];
        _originalLabel.font = [UIFont systemFontOfSize:12];
        _originalLabel.text = @"音量";
    }
    return _originalLabel;
}

- (SDVideoPreviewMusicSlider *)originalVolumeView {
    
    if (_originalVolumeView == nil) {
        CGFloat x = self.originalLabel.right + 30;
        _originalVolumeView = [[SDVideoPreviewMusicSlider alloc] initWithFrame:CGRectMake(x, self.originalLabel.top, self.width - 30 - x, self.originalLabel.height)];
        _originalVolumeView.valueTextColor = [UIColor hexStringToColor:@"707070"];
        _originalVolumeView.valueFont = [UIFont systemFontOfSize:12];
        _originalVolumeView.minimumValue = 0;
        _originalVolumeView.maximumValue = 100;
        _originalVolumeView.value = 50;
        [_originalVolumeView addTarget:self action:@selector(originalVolumeChangeAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _originalVolumeView;
}

- (UILabel *)musicLabel {
    
    if (_musicLabel == nil) {
        _musicLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, self.originalLabel.bottom, 40, 60)];
        _musicLabel.textColor = [UIColor hexStringToColor:@"ffffff"];
        _musicLabel.font = [UIFont systemFontOfSize:12];
        _musicLabel.text = @"配乐";
    }
    return _musicLabel;
}

- (SDVideoPreviewMusicSlider *)musicVolumeView {
    
    if (_musicVolumeView == nil) {
        CGFloat x = self.musicLabel.right + 30;
        _musicVolumeView = [[SDVideoPreviewMusicSlider alloc] initWithFrame:CGRectMake(x, self.musicLabel.top, self.width - 30 - x, self.musicLabel.height)];
        _musicVolumeView.valueTextColor = [UIColor hexStringToColor:@"707070"];
        _musicVolumeView.valueFont = [UIFont systemFontOfSize:12];
        _musicVolumeView.minimumValue = 0;
        _musicVolumeView.maximumValue = 100;
        _musicVolumeView.value = 50;
        _musicVolumeView.isUserInterface = NO;
        [_musicVolumeView addTarget:self action:@selector(musicVolumeChangeAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _musicVolumeView;
}

#pragma mark - UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.musicDataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    SDVideoPreviewMusicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SDVideoPreviewMusicCell" forIndexPath:indexPath];
    cell.dataModel = self.musicDataArray[indexPath.row];
    cell.isSelect = [cell.dataModel isEqual:self.selectModel];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        // 展示更多配乐界面
        if (self.config.moreMusicViewController != nil) {
            [self.superViewController presentViewController:self.config.moreMusicViewController animated:YES completion:nil];
        } else {
            [self makeToast:@"还未定义更多配乐界面" duration:0.8 position:CSToastPositionCenter];
        }
    } else {
        SDVideoMusicModel *selectModel = self.musicDataArray[indexPath.row];
        if ([selectModel isEqual:self.selectModel]) {
            self.selectModel = nil;
        } else {
            self.selectModel = selectModel;
        }
    }
}

- (void)setSelectModel:(SDVideoMusicModel *)selectModel {
    
    _selectModel = selectModel;
    self.musicVolumeView.value = 50;
    if (_selectModel == nil) {
        self.musicVolumeView.isUserInterface = NO;
        if (_delegate != nil && [_delegate respondsToSelector:@selector(userSelectbackgroundMusicWithDataModel:musicVolume:)]) {
            [_delegate userSelectbackgroundMusicWithDataModel:selectModel musicVolume:self.musicVolumeView.value];
        }
        [self.collectionView reloadData];
        
    } else {
        self.musicVolumeView.isUserInterface = YES;
        if (_selectModel.state == SDVideoMusicStateLocal) {
            if (_delegate != nil && [_delegate respondsToSelector:@selector(userSelectbackgroundMusicWithDataModel:musicVolume:)]) {
                [_delegate userSelectbackgroundMusicWithDataModel:selectModel musicVolume:self.musicVolumeView.value];
            }
            [self.collectionView reloadData];
        } else {
            _selectModel.state = SDVideoMusicStateDownLoad;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSError *error = nil;
                NSData *musicData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.selectModel.musicWebURL] options:NSDataReadingMappedIfSafe|NSDataReadingMappedAlways error:&error];
                if (error == nil) {
                    NSString *tmpPath = [SDVideoUtils getSandboxFilePathWithPathType:VideoFilePathTypeTmpPath];
                    NSString *musicDataPath = [tmpPath stringByAppendingFormat:@"SD_music_%f_%d.mp3",[[NSDate new] timeIntervalSince1970],arc4random()%999];
                    BOOL success = [musicData writeToFile:musicDataPath atomically:YES];
                    if (success) {
                        self.selectModel.musicPathURL = musicDataPath;
                    } else {
                        self.selectModel.state = SDVideoMusicStateWeb;
                    }
                } else {
                    self.selectModel.state = SDVideoMusicStateWeb;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                    if (self.selectModel.state == SDVideoMusicStateLocal) {
                        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(userSelectbackgroundMusicWithDataModel:musicVolume:)]) {
                            [self.delegate userSelectbackgroundMusicWithDataModel:selectModel musicVolume:self.musicVolumeView.value];
                        }
                    }
                });
            });
            [self.collectionView reloadData];
        }
    }
}

#pragma mark - 设置显示

- (void)setSelectType:(TabbarSelectType)selectType {
    
    if (_selectType == selectType) {
        return;
    }
    _selectType = selectType;
    switch (selectType) {
        case TabbarSelectTypeMusic:{
            self.musicButton.selected = YES;
            self.volumeButton.selected = NO;
            [UIView animateWithDuration:0.3 animations:^{
                self.musicView.left = 0;
                self.volumeView.left = self.mainView.width;
            }];
            break;
        }
        case TabbarSelectTypeVolume:{
            self.musicButton.selected = NO;
            self.volumeButton.selected = YES;
            [UIView animateWithDuration:0.3 animations:^{
                self.musicView.left = -self.mainView.width;
                self.volumeView.left = 0;
            }];
            break;
        }
        default:
            break;
    }
}

#pragma mark - 响应事件

- (void)userSelectMusicTabbarAction:(UIButton *)sender {
    
    self.selectType = TabbarSelectTypeMusic;;
}

- (void)userSelectVolumeTabbarAction:(UIButton *)sender {
    
    self.selectType = TabbarSelectTypeVolume;
}

- (void)originalVolumeChangeAction:(UISlider *)sender {
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(userChangeOriginalVolume:musicVolume:)]) {
        [_delegate userChangeOriginalVolume:self.originalVolumeView.value musicVolume:self.musicVolumeView.value];
    }
}

- (void)musicVolumeChangeAction:(UISlider *)sender {
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(userChangeOriginalVolume:musicVolume:)]) {
        [_delegate userChangeOriginalVolume:self.originalVolumeView.value musicVolume:self.musicVolumeView.value];
    }
}

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

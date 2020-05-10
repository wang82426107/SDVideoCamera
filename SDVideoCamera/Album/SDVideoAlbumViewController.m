//
//  SDVideoAlbumViewController.m
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/19.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDVideoAlbumViewController.h"
#import "SDVideoCropViewController.h"
#import "SDVideoAlbumSelectCell.h"
#import "SDVideoLoadingView.h"
#import "SDVideoAlbumCell.h"
#import "UIView+Extension.h"
#import <Photos/Photos.h>
#import "SDVideoUtils.h"

@interface SDVideoAlbumViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,SDVideoAlbumSelectCellDelegate>

@property(nonatomic,strong)SDVideoConfig *config;

@property(nonatomic,strong)UIView *mainView;
@property(nonatomic,strong)UIButton *exitButton;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)UIView *bottomView;
@property(nonatomic,strong)UICollectionView *selectCollectionView;
@property(nonatomic,strong)UILabel *alertLabel;
@property(nonatomic,strong)UIButton *nextButton;

@property(nonatomic,strong)NSMutableArray *videoArray;
@property(nonatomic,strong)NSMutableArray *videoImageArray;
@property(nonatomic,strong)NSMutableArray *selectVideoArray;

@end

@implementation SDVideoAlbumViewController

- (instancetype)initWithCameraConfig:(SDVideoConfig *)config {

    if (self = [super init]) {
        self.config = config;
        self.videoArray = [NSMutableArray arrayWithCapacity:16];
        self.videoImageArray = [NSMutableArray arrayWithCapacity:16];
        self.selectVideoArray = [NSMutableArray arrayWithCapacity:16];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    [self.view addSubview:self.mainView];
    [self loadAllVideoDataAction];
    self.view.backgroundColor = [UIColor blackColor];
}

#pragma mark - 懒加载

- (UIView *)mainView {
    
    if (_mainView == nil) {
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, StatusHeight, KmainWidth, KNoSafeHeight - StatusHeight)];
        _mainView.backgroundColor = [UIColor hexStringToColor:@"ffffff"];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_mainView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = _mainView.bounds;
        maskLayer.path = maskPath.CGPath;
        _mainView.layer.mask = maskLayer;
        [_mainView addSubview:self.exitButton];
        [_mainView addSubview:self.titleLabel];
        [_mainView addSubview:self.collectionView];
        [_mainView addSubview:self.bottomView];
    }
    return _mainView;
}

- (UIButton *)exitButton {
    
    if (_exitButton == nil) {
        _exitButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, NavigationBarHeight, NavigationBarHeight)];
        _exitButton.tintColor = [UIColor hexStringToColor:@"000000"];
        [_exitButton setImage:[[UIImage imageNamed:@"sd_commom_exit_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_exitButton addTarget:self action:@selector(exitAlbumViewControllerAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _exitButton;
}

- (UILabel *)titleLabel {
    
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(NavigationBarHeight, 0, KmainWidth - NavigationBarHeight * 2, NavigationBarHeight)];
        _titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
        _titleLabel.textColor = [UIColor hexStringToColor:@"000000"];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"选择视频";
    }
    return _titleLabel;
}

- (UIView *)bottomView {
    
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.mainView.height - 50, KmainWidth, 50)];
        _bottomView.backgroundColor = [UIColor hexStringToColor:@"ffffff"];
        [_bottomView addSubview:self.alertLabel];
        [_bottomView addSubview:self.nextButton];
    }
    return _bottomView;
}

- (UILabel *)alertLabel {
    
    if (_alertLabel == nil) {
        _alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, _bottomView.height)];
        _alertLabel.textColor = [UIColor hexStringToColor:@"696969"];
        _alertLabel.font = [UIFont systemFontOfSize:12];
        _alertLabel.text = @"当前暂只支持选择视频";
    }
    return _alertLabel;
}

- (UIButton *)nextButton {
    
    if (_nextButton == nil) {
        _nextButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bottomView.width - 10 - 80, (_bottomView.height - 36)/2.0, 80, 36)];
        _nextButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
        _nextButton.backgroundColor = [UIColor hexStringToColor:@"f5f5f5"];
        _nextButton.layer.cornerRadius = 4.0f;
        _nextButton.layer.masksToBounds = YES;
        [_nextButton setTitle:@"下一步" forState:UIControlStateNormal];
        [_nextButton setTitleColor:[UIColor hexStringToColor:@"696969"] forState:UIControlStateNormal];
        [_nextButton addTarget:self action:@selector(nextButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}

- (UICollectionView *)collectionView {
    
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(KmainWidth/4.0, KmainWidth/4.0);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.titleLabel.bottom, KmainWidth, self.bottomView.top - self.titleLabel.bottom) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor hexStringToColor:@"ffffff"];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[SDVideoAlbumCell class] forCellWithReuseIdentifier:@"SDVideoAlbumCell"];
    }
    return _collectionView;
}

- (UICollectionView *)selectCollectionView {
    
    if (_selectCollectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(50, 50);
        layout.minimumInteritemSpacing = 5;
        layout.minimumLineSpacing = 5;
        _selectCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 0, KmainWidth - 20, 60) collectionViewLayout:layout];
        _selectCollectionView.backgroundColor = [UIColor hexStringToColor:@"ffffff"];
        _selectCollectionView.showsHorizontalScrollIndicator = NO;
        _selectCollectionView.dataSource = self;
        _selectCollectionView.delegate = self;
        [_selectCollectionView registerClass:[SDVideoAlbumSelectCell class] forCellWithReuseIdentifier:@"SDVideoAlbumSelectCell"];
    }
    return _selectCollectionView;
}

#pragma mark - UICollectionViewDataSource,UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if ([collectionView isEqual:self.collectionView]) {
        return self.videoArray.count;
    } else {
        return self.selectVideoArray.count;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([collectionView isEqual:self.collectionView]) {
        SDVideoAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SDVideoAlbumCell" forIndexPath:indexPath];
        cell.asset = self.videoArray[indexPath.row];
        cell.bgImage = self.videoImageArray[indexPath.row];
        cell.selectNumber = [self loadSelectNumberWithIndexRow:indexPath.row];
        return cell;
    } else {
        NSInteger index = [self.selectVideoArray[indexPath.row] integerValue];
        SDVideoAlbumSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SDVideoAlbumSelectCell" forIndexPath:indexPath];
        cell.bgImage = self.videoImageArray[index];
        cell.asset = self.videoArray[index];
        cell.dataIndex = @(index);
        cell.delegate = self;
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![collectionView isEqual:self.collectionView]) {
        return;
    }
    
    if ([self.selectVideoArray containsObject:@(indexPath.row)]) {
        [self.selectVideoArray removeObject:@(indexPath.row)];
        [self.collectionView reloadData];
    } else {
        [self.selectVideoArray addObject:@(indexPath.row)];
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
    [self reloadBottomViewStateAction];
}

- (int)loadSelectNumberWithIndexRow:(NSInteger)indexRow {
    
    if (![self.selectVideoArray containsObject:@(indexRow)]) {
        return -1;
    } else {
        for (int i = 0; i < self.selectVideoArray.count; i++) {
            NSNumber *selectIndex = self.selectVideoArray[i];
            if ([selectIndex intValue] == indexRow) {
                return i + 1;
            }
        }
        return -1;
    }
}

- (void)reloadBottomViewStateAction {
    
    [self.selectCollectionView reloadData];

    if (self.selectVideoArray.count == 0) {
        [_selectCollectionView removeFromSuperview];
        self.bottomView.frame = CGRectMake(0, self.mainView.height - 50, KmainWidth, 50);
        self.collectionView.frame = CGRectMake(0, self.titleLabel.bottom, KmainWidth, self.bottomView.top - self.titleLabel.bottom);
        self.alertLabel.frame = CGRectMake(10, 0, 200, _bottomView.height);
        self.nextButton.frame = CGRectMake(self.bottomView.width - 10 - 80, (_bottomView.height - 36)/2.0, 80, 36);
        self.nextButton.backgroundColor = [UIColor hexStringToColor:@"f5f5f5"];
        [self.nextButton setTitle:@"下一步" forState:UIControlStateNormal];
        [self.nextButton setTitleColor:[UIColor hexStringToColor:@"696969"] forState:UIControlStateNormal];
    } else {
        self.bottomView.frame = CGRectMake(0, self.mainView.height - 50 - 60, KmainWidth, 50 + 60);
        self.collectionView.frame = CGRectMake(0, self.titleLabel.bottom, KmainWidth, self.bottomView.top - self.titleLabel.bottom);
        self.alertLabel.frame = CGRectMake(10, self.bottomView.height - 50, 200, 50);
        self.nextButton.frame = CGRectMake(self.bottomView.width - 10 - 80, self.bottomView.height - 36 - (50 - 36)/2.0, 80, 36);
        [self.bottomView addSubview:self.selectCollectionView];
        self.nextButton.backgroundColor = [UIColor hexStringToColor:self.config.tintColor];
        [self.nextButton setTitle:[NSString stringWithFormat:@"下一步(%d)",(int)self.selectVideoArray.count] forState:UIControlStateNormal];
        [self.nextButton setTitleColor:[UIColor hexStringToColor:@"ffffff"] forState:UIControlStateNormal];
    }
}

#pragma mark - 获取相册数据

- (void)loadAllVideoDataAction {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        for (PHAssetCollection *assetCollection in assetCollections) {
            [self enumerateAssetsInAssetCollection:assetCollection original:NO];
        }
        PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
        [self enumerateAssetsInAssetCollection:cameraRoll original:NO];
    });
}

- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection original:(BOOL)original {

    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.synchronous = YES;
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    for (PHAsset *asset in assets) {
        CGSize size = original ? CGSizeMake(asset.pixelWidth, asset.pixelHeight) : CGSizeZero;
        if (asset.mediaType == PHAssetMediaTypeVideo) {
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                [self.videoArray addObject:asset];
                [self.videoImageArray addObject:result];
            }];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

#pragma mark - 响应事件

- (void)exitAlbumViewControllerAction {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDeleteVideoWithDataIndex:(NSNumber *)dataIndex {
    
    [self.selectVideoArray removeObject:dataIndex];
    [self.collectionView reloadData];
    [self reloadBottomViewStateAction];
}

- (void)nextButtonAction {
    
    if (self.selectVideoArray.count == 0) {
        return;
    }
    
    NSMutableArray *selectAssetArray = [NSMutableArray arrayWithCapacity:16];
    
    for (NSNumber *index in self.selectVideoArray) {
        PHAsset *asset = self.videoArray[[index intValue]];
        [selectAssetArray addObject:asset];
    }
    
    if (!self.isFinishReturn) {
        [SDVideoLoadingView showLoadingAction];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSMutableArray *videoAssetArray = [NSMutableArray arrayWithCapacity:selectAssetArray.count];
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        for (PHAsset *asset in selectAssetArray) {
            if (asset.mediaType == PHAssetMediaTypeVideo) {
                [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    [videoAssetArray addObject:asset];
                    if (videoAssetArray.count == selectAssetArray.count) {
                        dispatch_semaphore_signal(sema);
                    }
                }];
            }
        }
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (self.isFinishReturn) {
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(userFinishSelectWithVideoAssetArray:)]) {
                    [self.delegate userFinishSelectWithVideoAssetArray:videoAssetArray];
                }
                [self exitAlbumViewControllerAction];
            } else {
                [SDVideoLoadingView dismissLoadingAction];
                SDVideoCropViewController *cropViewController = [[SDVideoCropViewController alloc] initWithCameraConfig:self.config videoAssetArray:videoAssetArray];
                [self.navigationController pushViewController:cropViewController animated:YES];
            }
        });
    });
}

#pragma mark - 系统方法

// 设置状态栏的颜色
- (UIStatusBarStyle)preferredStatusBarStyle {

    return UIStatusBarStyleLightContent;
}

@end

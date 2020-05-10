//
//  SDVideoCropItemListView.m
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/27.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDVideoCropItemListView.h"
#import "SDVideoAlbumViewController.h"
#import "SDVideoCropItemListAddCell.h"
#import "SDVideoCropItemDeleteView.h"
#import "SDVideoCropItemListCell.h"
#import "UIView+Extension.h"

@interface SDVideoCropItemListView ()
<
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
SDVideoCropItemDeleteViewDelegate,
SDVideoAlbumViewControllerDelegate
>

@property(nonatomic,strong)UILabel *alertLabel;
@property(nonatomic,strong)UICollectionView *itemCollectionView;
@property(nonatomic,strong)SDVideoCropItemDeleteView *deleteView;
@property(nonatomic,strong)AVAssetImageGenerator *imageGenerator;
@property(nonatomic,strong)NSMutableArray <UIImage *>*frameImageArray;

@property(nonatomic,strong)SDVideoCropDataManager *dataManager;

@end

@implementation SDVideoCropItemListView

- (instancetype)initWithFrame:(CGRect)frame dataManager:(SDVideoCropDataManager *)dataManager {
    
    if (self = [super initWithFrame:frame]) {
        self.dataManager = dataManager;
        [self addSubview:self.alertLabel];
        [self addSubview:self.itemCollectionView];
        [self loadVideoFirstFrameImageAction];
    }
    return self;
}

- (void)loadVideoFirstFrameImageAction {
    
    self.frameImageArray = [NSMutableArray arrayWithCapacity:16];
    for (AVAsset *videoAsset in self.dataManager.videoArray) {
        _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:videoAsset];
        _imageGenerator.appliesPreferredTrackTransform = YES;
        _imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
        _imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        _imageGenerator.maximumSize = CGSizeMake(180, 180);
        CGImageRef cgImage = [_imageGenerator copyCGImageAtTime:CMTimeMake(1, 10) actualTime:NULL error:nil];
        [self.frameImageArray addObject:[UIImage imageWithCGImage:cgImage]];
        CGImageRelease(cgImage);
    }
    [self.itemCollectionView reloadData];
}

#pragma mark - 懒加载

- (UILabel *)alertLabel {
    
    if (_alertLabel == nil) {
        _alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.width - 10 *2, 20)];
        _alertLabel.textColor = [UIColor hexStringToColor:@"999999"];
        _alertLabel.font = [UIFont systemFontOfSize:10];
        _alertLabel.text = @"点击片段编辑单段,长按调整顺序";
    }
    return _alertLabel;
}

- (SDVideoCropItemDeleteView *)deleteView {
    
    if (_deleteView == nil) {
        _deleteView = [[SDVideoCropItemDeleteView alloc] initWithFrame:CGRectMake(0, self.height, self.width, self.height) dataManager:self.dataManager];
        _deleteView.delegate = self;
    }
    return _deleteView;
}

- (UICollectionView *)itemCollectionView {
    
    if (_itemCollectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(60 + 10 *2, self.height - 20);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        _itemCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.alertLabel.bottom, self.width, self.height - self.alertLabel.bottom) collectionViewLayout:layout];
        _itemCollectionView.contentInset = UIEdgeInsetsMake(0, 20, 0, 20);
        _itemCollectionView.backgroundColor = self.backgroundColor;
        _itemCollectionView.showsHorizontalScrollIndicator = NO;
        _itemCollectionView.dataSource = self;
        _itemCollectionView.delegate = self;
        _itemCollectionView.bounces = NO;
        [_itemCollectionView registerClass:[SDVideoCropItemListCell class] forCellWithReuseIdentifier:@"SDVideoCropItemListCell"];
        [_itemCollectionView registerClass:[SDVideoCropItemListAddCell class] forCellWithReuseIdentifier:@"SDVideoCropItemListAddCell"];
        [_itemCollectionView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(exchangVideoItemAction:)]];
    }
    return _itemCollectionView;
}

#pragma mark - UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.dataManager.videoArray.count + 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < self.dataManager.videoArray.count) {
        SDVideoCropItemListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SDVideoCropItemListCell" forIndexPath:indexPath];
        cell.videoAsset = self.dataManager.videoArray[indexPath.row];
        cell.videoImage = self.frameImageArray[indexPath.row];
        return cell;
    } else {
        SDVideoCropItemListAddCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SDVideoCropItemListAddCell" forIndexPath:indexPath];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataManager.videoArray.count <= 1) {
        return;
    }
    
    if (indexPath.row < self.dataManager.videoArray.count) {
        self.deleteView.selectImage = self.frameImageArray[indexPath.row];
        self.deleteView.indexRow = indexPath.row;
        [self addSubview:self.deleteView];
        [UIView animateWithDuration:0.3 animations:^{
            self.deleteView.top = 0;
        }];
    } else {
        SDVideoAlbumViewController *albumViewController = [[SDVideoAlbumViewController alloc] initWithCameraConfig:self.dataManager.config];
        albumViewController.delegate = self;
        albumViewController.isFinishReturn = YES;
        UINavigationController *albumNavigationController = [[UINavigationController alloc] initWithRootViewController:albumViewController];
        albumNavigationController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.dataManager.superViewController presentViewController:albumNavigationController animated:YES completion:nil];
    }
}

- (void)userDeletVideoAssetWithIndexRow:(NSInteger)indexRow {
    
    [self.itemCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexRow inSection:0]]];
    [self.frameImageArray removeObjectAtIndex:indexRow];
    [self.dataManager videoArrayDeleteVideoWithDataIndex:indexRow];
}

- (void)userFinishSelectWithVideoAssetArray:(NSArray <AVAsset *>*)videoAssetArray {
    
    [self.dataManager videoArrayAddVideoAssetArray:videoAssetArray];
    [self loadVideoFirstFrameImageAction];
}

#pragma mark - 拖拽移动相关

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < self.dataManager.videoArray.count) {
        return YES;
    } else {
        return NO;
    }
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath {

    if (sourceIndexPath.row == self.dataManager.videoArray.count ||
        destinationIndexPath.row == self.dataManager.videoArray.count) {
        [self.itemCollectionView cancelInteractiveMovement];
        return;
    }
    
    [self.dataManager videoArrayChangeIndexWithFirstIndex:sourceIndexPath.row secondIndex:destinationIndexPath.row];
    [self loadVideoFirstFrameImageAction];
}

#pragma mark - 长按改变顺序

- (void)exchangVideoItemAction:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    
    switch (longPressGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            NSIndexPath *indexPath = [self.itemCollectionView indexPathForItemAtPoint:[longPressGestureRecognizer locationInView:self.itemCollectionView]];
            if (indexPath == nil) {
                break;
            }
            SDVideoCropItemListCell *cell = (SDVideoCropItemListCell *)[self.itemCollectionView cellForItemAtIndexPath:indexPath];
            [self bringSubviewToFront:cell];
            [self.itemCollectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            
            NSIndexPath *indexPath = [self.itemCollectionView indexPathForItemAtPoint:[longPressGestureRecognizer locationInView:self.itemCollectionView]];
            if (indexPath.row != self.dataManager.videoArray.count) {
                [self.itemCollectionView updateInteractiveMovementTargetPosition:[longPressGestureRecognizer locationInView:self.itemCollectionView]];
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self.itemCollectionView endInteractiveMovement];
            break;
        }
        default:
            [self.itemCollectionView cancelInteractiveMovement];
            break;
    }
}

@end

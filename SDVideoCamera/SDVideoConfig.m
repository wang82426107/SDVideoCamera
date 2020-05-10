//
//  SDVideoConfig.m
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/14.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDVideoConfig.h"
#import <UIKit/UIKit.h>

@implementation SDVideoConfig

- (instancetype)init {
    
    if (self = [super init]) {
        self.durationType = MaxVideoDurationTypeDuration;
        self.maxVideoDuration = 15;
        self.audioURLType = AudioURLTypeNone;
        self.videoFilePathType = VideoFilePathTypeTmpPath;
        self.videoFileNamePrefix = @"SD_Record_Video";
        self.mergeFilePathType = VideoFilePathTypeCachesPath;
        self.mergeFileName = nil;
        self.tintColor = @"fb1e4d";
        self.progressColor = @"fbc835";
        self.isOpenFlashlight = NO;
        self.devicePosition = AVCaptureDevicePositionBack;
        self.maxVideoZoomFactor = 6;
        [self loadMenuButtonDataAction];
        [self loadPreviewTextColorArray];
    }
    return self;
}

- (void)loadMenuButtonDataAction {

    NSMutableArray *menuButtonArray = [NSMutableArray arrayWithCapacity:4];
    
    SDVideoMenuDataModel *turnOverDataModel = [[SDVideoMenuDataModel alloc] init];
    turnOverDataModel.menuType = VideoMenuTypesTurnOver;
    [menuButtonArray addObject:turnOverDataModel];
    
    SDVideoMenuDataModel *flashlightDataModel = [[SDVideoMenuDataModel alloc] init];
    flashlightDataModel.menuType = VideoMenuTypesFlashlight;
    [menuButtonArray addObject:flashlightDataModel];
    
    SDVideoMenuDataModel *countDownDataModel = [[SDVideoMenuDataModel alloc] init];
    countDownDataModel.menuType = VideoMenuTypesCountDown;
    [menuButtonArray addObject:countDownDataModel];
    
    self.menuDataArray = menuButtonArray;
}

- (void)loadPreviewTextColorArray {
    
    self.previewColorArray = @[@"ffffff",
                               @"010101",
                               @"ff484e",
                               @"bd01cc",
                               @"4e49cc",
                               @"1b8cef",
                               @"31d366",
                               @"ffc62e",
                               @"ff8840",
                               @"66c19d",
                               @"ffa29e",
                               @"a17d4d",
                               @"005f84",
                               @"1f4a33",
                               @"858c93",
                               @"2d2d2d"];
}

#pragma mark - 接口方法

- (void)configDataSelfCheckAction {
    
    // 设置了配音,但是没有设置配音类型
    if (self.audioURL != nil && self.audioURLType == AudioURLTypeNone) {
        NSLog(@"SDVideoConfig设置了配音,但是没有设置配音类型👇👇👇");
        NSString *exceptionContent = [NSString stringWithFormat:@"audioURL 不为nil时,self.audioURLType不能为AudioURLTypeNone"];
        @throw [NSException exceptionWithName:@"audioURLType has not Setting" reason:exceptionContent userInfo:nil];
    }
    
    // 设置了配音,但是没有设置配音名称
    if (self.audioURL != nil && self.audioName == nil) {
        NSLog(@"SDVideoConfig设置了配音,但是没有设置配音名称👇👇👇");
        NSString *exceptionContent = [NSString stringWithFormat:@"audioURL 不为nil时,self.audioName不能为nil"];
        @throw [NSException exceptionWithName:@"audioName has not Setting" reason:exceptionContent userInfo:nil];
    }
}


@end

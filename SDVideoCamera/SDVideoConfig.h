//
//  SDVideoConfig.h
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/14.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SDVideoMenuDataModel.h"
#import "SDVideoCameraHeader.h"
#import "SDVideoMusicModel.h"

#define MenuViewVerticalDistance (15.0f) // 控件垂直方向上的间距
#define MenuProgressTopDistance (10.0f) // 进度条的头部间距
#define MenuProgressLeftDistance (10.0f) // 进度条的左边间距

typedef enum : NSUInteger {
    AudioURLTypeNone, // 没有配音
    AudioURLTypeLocal, // 本地配音
    AudioURLTypeWeb, // 网络配音
} AudioURLType;

typedef enum : NSUInteger {
    MaxVideoDurationTypeDuration,
    MaxVideoDurationTypeAudio,
} MaxVideoDurationType;

typedef void(^CameraReturnBlock)(NSString *mergeVideoPathString);

// 用户完成选择
typedef void(^UserSelectMusicFinishBlock)(SDVideoMusicModel *selectModel);

@interface SDVideoConfig : NSObject

// SDVideoConfig 是相机的配置项

// 返回时回调的Block
@property(nonatomic,copy)CameraReturnBlock returnBlock;

// 需要返回到哪个控制器
@property(nonatomic,weak)UIViewController *returnViewController;

// 录制最大时长策略,一共有两种模式,一 由配置中的最大时长决定 , 二 由配音时长决定
@property(nonatomic,assign)MaxVideoDurationType durationType;

// 最大录制时长,默认为15秒
@property(nonatomic,assign)NSTimeInterval maxVideoDuration;

// 配音类型
@property(nonatomic,assign)AudioURLType audioURLType;

// 配音URL
@property(nonatomic,copy)NSString *audioURL;

// 配音名称,默认为空
@property(nonatomic,copy)NSString *audioName;

// 分段视频存放路径,默认为VideoFilePathTypeTmpPath
@property(nonatomic,assign)VideoFilePathType videoFilePathType;

// 分段视频前缀,默认为"SD_Record_Video",
@property(nonatomic,copy)NSString *videoFileNamePrefix;

// 合成视频路径,默认为VideoFilePathTypeCachesPath
@property(nonatomic,assign)VideoFilePathType mergeFilePathType;

// 合成视频名称,默认为"SD_" + "时间戳_" + 0~999随机数 + ".mov"
@property(nonatomic,copy)NSString *mergeFileName;

/************************UI部分************************/

// 整体主色,默认为#fb1e4d
@property(nonatomic,copy)NSString *tintColor;

// 进度条颜色,默认为#fbc835
@property(nonatomic,copy)NSString *progressColor;

// 功能菜单列表数组
@property(nonatomic,copy)NSArray <SDVideoMenuDataModel *>*menuDataArray;

// 默认摄像头,默认为后置摄像头(AVCaptureDevicePositionBack)
@property(nonatomic,assign)AVCaptureDevicePosition devicePosition;

// 闪光灯开关,默认为关闭
@property(nonatomic,assign)BOOL isOpenFlashlight;

// 最大焦距倍数,默认为6,注:不可以超过6
@property(nonatomic,assign)CGFloat maxVideoZoomFactor;

// 配置自我检测,可以检测配置是否存在错误
- (void)configDataSelfCheckAction;


/************************预览设置部分************************/

// 推荐配乐列表
@property(nonatomic,copy)NSArray <SDVideoMusicModel *>*recommendMusicList;

// 更多配乐的控制器
@property(nonatomic,weak)UIViewController *moreMusicViewController;

// 更多配乐选择完成需要 **调用(非实现)** 的block,用于把数据进行回传.
@property(nonatomic,strong)UserSelectMusicFinishBlock finishBlock;

// 字体颜色数组
@property(nonatomic,copy)NSArray <NSString *>*previewColorArray;

// 预览界面贴纸名称数组
@property(nonatomic,copy)NSArray <NSString *>*previewTagImageNameArray;


@end

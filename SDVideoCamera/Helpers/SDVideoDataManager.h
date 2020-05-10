//
//  SDVideoDataManager.h
//  FamilyClassroom
//
//  Created by 王巍栋 on 2020/1/13.
//  Copyright © 2020 Dong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDVideoCameraHeader.h"
#import "SDVideoDataModel.h"
#import "SDVideoConfig.h"

@interface SDVideoDataManager : NSObject

// SDVideoDataManager 是视频数据管理单例类

+ (SDVideoDataManager *)defaultManager;

@property(nonatomic,strong)SDVideoConfig *config; // 用户的配置项
@property(nonatomic,assign)VideoCameraState cameraState;//相机的状态
@property(nonatomic,assign,readonly)float videoSecondTime;//最大录制时长,根据用户配置项获得
@property(nonatomic,assign)float totalVideoTime; //录制的总计时长
@property(nonatomic,assign)float progress; //进度
@property(nonatomic,assign)NSInteger videoNumber; //视频的个数,没法直接监听数组元素的变化
@property(nonatomic,strong,readonly)NSMutableArray <SDVideoDataModel *>*videoDataArray;

/// 添加一条新的分段视频
- (void)addVideoModel:(SDVideoDataModel *)videoModel;

/// 删除最后的分段视频
- (void)deleteLastVideoModel;

/// 删除所有的分段视频
- (void)deleteAllVideoModel;

@end

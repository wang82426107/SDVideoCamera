//
//  SDVideoDataModel.h
//  FamilyClassroom
//
//  Created by 王巍栋 on 2020/1/13.
//  Copyright © 2020 Dong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDVideoDataModel : NSObject

// SDVideoDataModel 是分段视频的数据模型

@property(nonatomic,strong)NSURL *pathURL;
@property(nonatomic,assign)float duration;//时长进度
@property(nonatomic,assign)float progress;//进度
@property(nonatomic,assign)float durationWeight;//时长权重

- (void)deleteLocalVideoFileAction;

@end


//
//  SDVideoCameraHeader.h
//  FamilyClassroom
//
//  Created by 王巍栋 on 2020/1/13.
//  Copyright © 2020 Dong. All rights reserved.
//

#ifndef SDVideoCameraHeader_h
#define SDVideoCameraHeader_h

#import "UIView+Extension.h"
#import "UIColor+HexStringColor.h"

typedef enum : NSUInteger {
    VideoCameraStateIdle,//空闲状态
    VideoCameraStateInProgress,//录制状态
    VideoCameraStatePause,//暂停状态
    VideoCameraStateStop,//停止状态
} VideoCameraState;

typedef enum : NSUInteger {
    VideoFilePathTypeCachesPath,// 获取Library/Caches目录
    VideoFilePathTypeTmpPath,// 获取tmp目录
    VideoFilePathTypeDocumentsPath,// 获取Documents目录
    VideoFilePathTypeLibraryPath,// 获取Library目录
    VideoFilePathTypePreferencesPath,// 获取Library/Preferences目录
} VideoFilePathType;

typedef enum : NSUInteger {
    TouchMoveOrientationUp,
    TouchMoveOrientationDown,
} TouchMoveOrientation;


#define KNoSafeHeight [UIScreen mainScreen].bounds.size.height
#define StatusHeight  ((KNoSafeHeight == 812 || KNoSafeHeight == 896) ? 44.0f : 20.0f)
#define KmainHeight  ((KNoSafeHeight == 812 || KNoSafeHeight == 896) ? (KNoSafeHeight - 34) : KNoSafeHeight )
#define KmainWidth  [UIScreen mainScreen].bounds.size.width
#define NavigationBarHeight  (44.0f)

#endif /* SDVideoCameraHeader_h */

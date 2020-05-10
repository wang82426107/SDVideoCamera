//
//  SDVideoMenuDataModel.h
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/15.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    VideoMenuTypesTurnOver,// 翻转按钮
    VideoMenuTypesFlashlight,// 闪光灯
    VideoMenuTypesCountDown,// 倒计时
} VideoMenuType;

typedef void(^ButtonActionBlock)(UIButton *sender);

@interface SDVideoMenuDataModel : NSObject

// SDVideoMenuDataModel 是侧边按钮数据Model

@property(nonatomic,assign)VideoMenuType menuType;
@property(nonatomic,copy)NSString *normalImageName;
@property(nonatomic,copy)NSString *selectImageName;
@property(nonatomic,copy)NSString *normalTitle;
@property(nonatomic,copy)NSString *selectTitle;

@end

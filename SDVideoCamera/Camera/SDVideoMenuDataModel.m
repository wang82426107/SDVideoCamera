//
//  SDVideoMenuDataModel.m
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/15.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDVideoMenuDataModel.h"

@implementation SDVideoMenuDataModel

- (void)setMenuType:(VideoMenuType)menuType {

    _menuType = menuType;
    
    NSArray *normalImageNameArray = @[@"sd_camera_turn_over",
                                      @"sd_camera_flash_light_off",
                                      @"sd_camera_count_down",
                                      @"sd_camera_original_off"];
    NSArray *selectImageNameArray = @[@"sd_camera_turn_over",
                                      @"sd_camera_flash_light_on",
                                      @"sd_camera_count_down",
                                      @"sd_camera_original_on"];
    NSArray *normalTitleArray = @[@"翻转",@"闪光灯",@"倒计时",@"关闭原声"];
    NSArray *selectTitleArray = @[@"翻转",@"闪光灯",@"倒计时",@"打开原声"];
    
    self.normalImageName = normalImageNameArray[menuType];
    self.selectImageName = selectImageNameArray[menuType];
    self.normalTitle = normalTitleArray[menuType];
    self.selectTitle = selectTitleArray[menuType];
}


@end

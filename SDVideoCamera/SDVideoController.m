//
//  SDVideoController.m
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/18.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDVideoController.h"

@implementation SDVideoController

- (instancetype)initWithCameraConfig:(SDVideoConfig *)config {
    
    if (config.returnViewController == nil) {
        NSString *exceptionContent = [NSString stringWithFormat:@"需要设置根控制器,以便于dismiss使用"];
        @throw [NSException exceptionWithName:@"returnViewController has not Setting" reason:exceptionContent userInfo:nil];
    }
    
    SDVideoCameraController *cameraController = [[SDVideoCameraController alloc] initWithCameraConfig:config];
    if (self = [super initWithRootViewController:cameraController]) {
        self.cameraController = cameraController;
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

@end

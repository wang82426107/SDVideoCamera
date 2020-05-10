//
//  SDVideoDataModel.m
//  FamilyClassroom
//
//  Created by 王巍栋 on 2020/1/13.
//  Copyright © 2020 Dong. All rights reserved.
//

#import "SDVideoDataModel.h"

@implementation SDVideoDataModel

- (void)deleteLocalVideoFileAction {
    
    if (_pathURL != nil) {
        dispatch_queue_t global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(global, ^{
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtURL:self.pathURL error:nil];
            self.pathURL = nil;
        });
    }
}

@end

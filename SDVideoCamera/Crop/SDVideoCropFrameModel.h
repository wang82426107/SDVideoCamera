//
//  SDVideoCropFrameModel.h
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/22.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SDVideoCropFrameModel : NSObject

@property(nonatomic,assign)NSInteger dataIndex;
@property(nonatomic,strong)AVAsset *superAsset;
@property(nonatomic,strong)UIImage *frameImage;
@property(nonatomic,assign)CMTime startTime; // 在全局中起始时间
@property(nonatomic,assign)CMTime duration;

@end


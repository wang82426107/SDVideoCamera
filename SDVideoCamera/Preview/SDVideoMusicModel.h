//
//  SDVideoMusicModel.h
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/30.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    SDVideoMusicStateUnKnow,
    SDVideoMusicStateWeb, // 数据网络化
    SDVideoMusicStateDownLoad, // 数据正在下载
    SDVideoMusicStateLocal, //数据已本地化
} SDVideoMusicState;

@interface SDVideoMusicModel : NSObject

// SDVideoMusicModel 是配乐的Model

@property(nonatomic,assign)SDVideoMusicState state;
@property(nonatomic,copy)NSString *musicTitle;
@property(nonatomic,copy)NSString *musicImageName; // 本地封面图的地址
@property(nonatomic,copy)NSString *musicImageURL; // 网络封面图片的地址
@property(nonatomic,copy)NSString *musicPathURL; // 本地资源的地址
@property(nonatomic,copy)NSString *musicWebURL; // 网络资源的地址,设置后会转化为musicPathURL
@property(nonatomic,copy)NSData *musicImageData; // 从网络缓存的图片数据

@end

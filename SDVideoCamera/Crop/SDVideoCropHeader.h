//
//  SDVideoCropHeader.h
//  SDVideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/24.
//  Copyright © 2020 骚栋. All rights reserved.
//

#ifndef SDVideoCropHeader_h
#define SDVideoCropHeader_h

@protocol SDVideoCropVideoDragDelegate <NSObject>

@optional

// 用户开始拖拽视频左右或进度按钮
- (void)userStartChangeVideoTimeRangeAction;

// 用户正在拖拽视频左右或进度按钮,数据已经同步到SDVideoCropDataManager中
- (void)userChangeVideoTimeRangeAction;

// 用户结束拖拽视频左右按钮或者进度按钮
- (void)userEndChangeVideoTimeRangeAction;

@end

#endif /* SDVideoCropHeader_h */

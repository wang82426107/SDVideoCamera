//
//  SDVideoMusicModel.m
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/30.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "SDVideoMusicModel.h"

@implementation SDVideoMusicModel

- (instancetype)init {
    
    if (self = [super init]) {
        self.state = SDVideoMusicStateUnKnow;
    }
    return self;
}

- (void)setMusicWebURL:(NSString *)musicWebURL {
    
    _musicWebURL = musicWebURL;
    self.state = SDVideoMusicStateWeb;
}

- (void)setMusicPathURL:(NSString *)musicPathURL {
    
    _musicPathURL = musicPathURL;
    self.state = SDVideoMusicStateLocal;
}

@end

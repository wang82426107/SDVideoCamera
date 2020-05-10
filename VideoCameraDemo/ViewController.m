//
//  ViewController.m
//  VideoCameraDemo
//
//  Created by 王巍栋 on 2020/4/26.
//  Copyright © 2020 骚栋. All rights reserved.
//

#import "ViewController.h"
#import "SDVideoController.h"

@interface ViewController ()

@property(nonatomic,strong)UIButton *button;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.button = [[UIButton alloc] initWithFrame:CGRectMake(10, 200, self.view.width - 20, 40)];
    self.button.backgroundColor = [UIColor orangeColor];
    self.button.layer.cornerRadius = 4.0f;
    self.button.layer.masksToBounds = YES;
    [self.button setTitle:@"弹出SDVideoCamera" forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(presentSDVideoCameraAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
}

- (void)presentSDVideoCameraAction {
    
    SDVideoConfig *config = [[SDVideoConfig alloc] init];
    config.returnViewController = self;
    config.returnBlock = ^(NSString *mergeVideoPathString) {
        NSLog(@"合成路径 %@",mergeVideoPathString);
    };

    SDVideoMusicModel *musicModel = [[SDVideoMusicModel alloc] init];
    musicModel.musicTitle = @"你是人间四月天";
    musicModel.musicImageName = @"music_image.jpg";
    musicModel.musicWebURL = @"https://zhike-oss.oss-cn-beijing.aliyuncs.com/tmp/test_music.mp3";
    
    SDVideoMusicModel *otherMusicModel = [[SDVideoMusicModel alloc] init];
    otherMusicModel.musicTitle = @"郊外静音";
    otherMusicModel.musicImageName = @"music_image.jpg";
    otherMusicModel.musicWebURL = @"https://zhike-oss.oss-cn-beijing.aliyuncs.com/tmp/test_music2.mp3";
    
    config.recommendMusicList = @[musicModel,otherMusicModel];
    
    config.previewTagImageNameArray = @[@"circle_add_friend_icon",@"circle_apply_friend_icon"];
    
    SDVideoController *videoController = [[SDVideoController alloc] initWithCameraConfig:config];
    [self presentViewController:videoController animated:YES completion:nil];
}

@end

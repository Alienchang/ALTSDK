//
//  ViewController.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/12.
//  Copyright © 2019年 Alienchang. All rights reserved.
//

#import "ViewController.h"
#import "ALTPlayer.h"
#import "ALTWebviewController.h"
#import "ALTVideoControlView.h"
#import "ALTCommonMacro.h"
#import "ALTPlayerController.h"
#import "ImageViewController.h"
#import "ALTHUD.h"
#import "SeekCell.h"
#import "PreloadViewController.h"
#import "NEAudioPlayer.h"
#import "ALTPlayerController+Event.h"
#import "PlayByIdCell.h"
#import "avformat.h"
#import "TextFieldCell.h"
@interface ViewController ()<ALTPlayerDelegate ,UITableViewDelegate ,UITableViewDataSource ,UIPickerViewDelegate ,ALTPlayerControllerDelegate ,UIPickerViewDataSource> {
    NSArray *_videos;
}
@property (nonatomic ,assign) BOOL onLoop;
@property (nonatomic ,strong) UISlider *slider;
@property (nonatomic ,strong) UIView *containView;
@property (nonatomic ,strong) ALTPlayerController *playerController;
@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) UIPickerView *pickerView;
@property (nonatomic ,strong) UISegmentedControl *segmentedControl;
@property (nonatomic ,strong) UILabel *cacheProgressLabel;
@property (nonatomic ,strong) UILabel *playProgressLabel;
@property (nonatomic ,strong) UILabel *fpsLabel;
@property (nonatomic ,strong) UILabel *timeLabel;
@property (nonatomic ,strong) UIView  *titleView;
@property (nonatomic ,strong) NEAudioPlayer *audioPlayer;

@property (nonatomic ,strong) UITextField *projectIdTextField;
@property (nonatomic ,strong) UITextField *episodeIdTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /// 监听横竖屏
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    NSString *path = NSHomeDirectory();
    NSLog(@"app path = %@",path);
    
    _videos = @[@"http://192.168.1.244/group1/M00/00/DD/wKgB9FzTluWAUXH7AJDDvGspOMU991.mp4",
                @"http://192.168.1.244/group1/M00/00/E1/wKgB9FziUI2AGfR4AHwO14ZxWRU751.mp4",
                @"http://192.168.1.244/group1/M00/00/E1/wKgB9FziW_qAVaoCAIucIlLAot4324.mp4",
                @"http://192.168.1.244/group1/M00/00/E7/wKgB9FzuNdqAGFChAFz1pZQiPZ0548.mp4",
                @"http://192.168.1.244/group1/M00/00/E7/wKgB9FzuPQGAYJRIAGI7lMh1reM346.mp4"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.containView];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = width * 9 / 16;
    [self.containView setFrame:CGRectMake(0, 0, width, height)];

    self.playerController = [[ALTPlayerController alloc] initWithFrame:self.containView.bounds containView:self.containView];
    [self.playerController setDelegate:self];
    [self.view addSubview:self.segmentedControl];
    [self.segmentedControl setFrame:CGRectMake(0, CGRectGetMaxY(self.containView.frame), CGRectGetWidth(self.view.frame), 30)];
    [self.view addSubview:self.tableView];
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    [self.tableView setFrame:CGRectMake(0, CGRectGetMaxY(self.segmentedControl.frame), CGRectGetWidth(self.view.frame), screenHeight - CGRectGetMaxY(self.segmentedControl.frame) - 64)];
    [self.navigationItem setTitleView:self.titleView];
    [self.titleView setFrame:CGRectMake(0, 0, 44, 200)];
    NSLog(@"%@",[ALTPlayerController cachedList]);
}


#pragma mark -- getter
- (UIView *)titleView {
    if (!_titleView) {
        _titleView = [UIView new];
        [_titleView addSubview:self.playProgressLabel];
        [_titleView addSubview:self.cacheProgressLabel];
        [_titleView addSubview:self.fpsLabel];
        [_titleView addSubview:self.timeLabel];
        [self.playProgressLabel setText:@"播放进度"];
        [self.cacheProgressLabel setText:@"缓存进度"];
        [self.playProgressLabel setFrame:CGRectMake(0, 0, 100, 40)];
        [self.cacheProgressLabel setFrame:CGRectMake(100, 0, 100, 40)];
        [self.fpsLabel setFrame:CGRectMake(-100, 0, 100, 40)];
        [self.timeLabel setFrame:CGRectMake(-150, 0, 40, 40)];
    }
    return _titleView;
}
- (UILabel *)fpsLabel {
    if (!_fpsLabel) {
        _fpsLabel = [UILabel new];
        [_fpsLabel setText:@"fps"];
        [_fpsLabel setTextAlignment:NSTextAlignmentCenter];
        [_fpsLabel setTextColor:[UIColor whiteColor]];
    }
    return _fpsLabel;
}
- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        [_timeLabel setTextAlignment:NSTextAlignmentCenter];
        [_timeLabel setTextColor:[UIColor whiteColor]];
    }
    return _timeLabel;
}
- (UILabel *)playProgressLabel {
    if (!_playProgressLabel) {
        _playProgressLabel = [UILabel new];
        [_playProgressLabel setFont:[UIFont systemFontOfSize:12]];
        [_playProgressLabel setNumberOfLines:0];
        [_playProgressLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_playProgressLabel setTextAlignment:NSTextAlignmentCenter];
        [_playProgressLabel setTextColor:[UIColor whiteColor]];
    }
    return _playProgressLabel;
}
- (UILabel *)cacheProgressLabel {
    if (!_cacheProgressLabel) {
        _cacheProgressLabel = [UILabel new];
        [_cacheProgressLabel setFont:[UIFont systemFontOfSize:12]];
        [_cacheProgressLabel setNumberOfLines:0];
        [_cacheProgressLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_cacheProgressLabel setTextAlignment:NSTextAlignmentCenter];
        [_cacheProgressLabel setTextColor:[UIColor whiteColor]];
    }
    return _cacheProgressLabel;
}
- (UISegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"0.5",@"1",@"1.5",@"2"]];
        [_segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentedControl;
}
- (UIPickerView *)pickerView {
    if (!_pickerView) {
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        CGFloat width  = [UIScreen mainScreen].bounds.size.width;
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, height - 300, width, 300)];
        [_pickerView setDelegate:self];
        [_pickerView setDataSource:self];
    }
    return _pickerView;
}
- (UIView *)containView {
    if (!_containView) {
        _containView = [UIView new];
        [_containView setBackgroundColor:[UIColor blackColor]];
    }
    return _containView;
}
- (UITableView *)tableView {
    if (!_tableView) {
//        CGFloat height = [UIScreen mainScreen].bounds.size.height - CGRectGetMaxY(self.containView.frame);
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setEstimatedRowHeight:0];
        [_tableView setEstimatedSectionFooterHeight:0];
        [_tableView setEstimatedSectionHeaderHeight:0];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        [_tableView registerClass:[SeekCell class] forCellReuseIdentifier:@"seekCell"];
        [_tableView registerClass:[PlayByIdCell class] forCellReuseIdentifier:@"PlayByIdCell"];
        [_tableView registerClass:[TextFieldCell class] forCellReuseIdentifier:@"TextFieldCell"];
        [_tableView setKeyboardDismissMode:UIScrollViewKeyboardDismissModeOnDrag];
    }
    return _tableView;
}

#pragma mark -- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 9;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TextFieldCell"];
        TextFieldCell *textFieldCell = (TextFieldCell *)cell;
        ALTWeakSelf;
        [textFieldCell setConfirmBlock:^(NSString * _Nonnull text) {
            [weakSelf.playerController playWithUrl:text];
        }];
    } else if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        [cell.textLabel setText:@"截图"];
    } else if (indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        [cell.textLabel setText:@"切换视频"];
    } else if (indexPath.row == 3) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        [cell.textLabel setText:[NSString stringWithFormat:@"缓存 %lld",[ALTPlayerController calculateCachedSizeWithError:nil]]];
    } else if (indexPath.row == 4) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"seekCell"];
        ALTWeakSelf;
        [(SeekCell *)cell setSeekBlock:^(NSTimeInterval time) {
            [weakSelf.playerController seek:time];
        }];
    } else if (indexPath.row == 5) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        [cell.textLabel setText:@"预加载"];
    } else if (indexPath.row == 6) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        [cell.textLabel setText:@"播放音乐"];
    } else if (indexPath.row == 7) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"PlayByIdCell"];
        PlayByIdCell *playByIdCell = (PlayByIdCell *)cell;
        [playByIdCell.playButton addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
//        [cell.textLabel setText:@"播放音乐"];
        [self setProjectIdTextField:playByIdCell.projectTextField];
        [self setEpisodeIdTextField:playByIdCell.episodeTextField];
        
        [self.projectIdTextField setText:@"4975011"];
        [self.episodeIdTextField setText:@"262"];
    } else if (indexPath.row == 8) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        [cell.textLabel setText:@"重置视频"];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}
- (void)playVideo {
    if (self.projectIdTextField.text.length && self.episodeIdTextField.text.length) {
        [self.playerController playWithProjectId:self.projectIdTextField.text
                                       episodeId:self.episodeIdTextField.text
                                    configParsed:^(BOOL success) {
                                        NSLog(@"11");
                                    }];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        //    NSString *videoUrl = @"https://m4.pptvyun.com/pvod/e11a0/ijblO6coKRX6a8NEQgg8LDZcqPY/eyJkbCI6MTUxNjYyNTM3NSwiZXMiOjYwNDgwMCwiaWQiOiIwYTJkbnEtWG82S2VvcTZMNEsyZG9hZmhvNkNjbTY2WXB3IiwidiI6IjEuMCJ9/0a2dnq-Xo6Keoq6L4K2doafho6Ccm66Ypw.mp4";
        
        NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"out5" ofType:@"mp4"];
        [self.playerController playWithUrl:videoPath];
    } else if (indexPath.row == 1) {
        ImageViewController *imageViewController = [ImageViewController new];
        [self.navigationController pushViewController:imageViewController animated:YES];
        [self.playerController syncVideoShort:^(UIImage * _Nonnull shortImage) {
            [imageViewController.imageView setImage:shortImage];
        }];
    } else if (indexPath.row == 2) {
        [self.view addSubview:self.pickerView];
    } else if (indexPath.row == 3) {
        [ALTPlayerController cleanAllCacheWithError:nil];
        [tableView reloadData];
    } else if (indexPath.row == 4) {
        
    } else if (indexPath.row == 5) {
        PreloadViewController *viewController = [PreloadViewController new];
        [viewController setVideoUrlArray:_videos];
        [self.navigationController pushViewController:viewController animated:YES];
    } else if (indexPath.row == 6) {
        if (self.audioPlayer.playing) {
            [self.audioPlayer stop];
        } else {
            NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"demoMusic" ofType:@"mp3"];
            [self setAudioPlayer:[[NEAudioPlayer alloc] initWithUrl:musicPath]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.audioPlayer play];
                [self.audioPlayer setVolume:1];
            });
        }
    } else if (indexPath.row == 8) {
        [self.playerController videoStop];
        [self.playerController audioStop];
        [self.playerController resetData];
    }
}

#pragma mark -- UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _videos.count;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *videoUrlString = _videos[row];
    [self.playerController playWithUrl:videoUrlString];
    [pickerView removeFromSuperview];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *videoUrlString = _videos[row];
    return videoUrlString;
}

#pragma mark -- ALTPlayerControllerDelegate
- (void)playEvent:(ALT_ENUM_PLAYEVENT)event
            error:(NSError *)error {
    if (event == PLAY_EVENT_VIDEO_READYTOPLAY) {
        [self.fpsLabel setText:[NSString stringWithFormat:@"fps: %d",self.playerController.fps]];
    }
}

- (void)playProgress:(float)progress
         currentTime:(NSTimeInterval)currentTime {
    [self.slider setValue:progress];
    [self.playProgressLabel setText:[NSString stringWithFormat:@"播放进度\n%d%% %f",(int)(100 * progress) ,currentTime]];
    [self.timeLabel setText:[NSString stringWithFormat:@"%d",(int)currentTime]];
}

- (void)cacheProgress:(float)progress {
    [self.cacheProgressLabel setText:[NSString stringWithFormat:@"缓存进度\n%d%%",(int)(100 * progress)]];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    [cell.textLabel setText:[NSString stringWithFormat:@"缓存 %lld",[ALTPlayerController calculateCachedSizeWithError:nil]]];
}
- (void)cacheFinished {
    [ALTHUD alertWithText:@"缓存完成" dismissDelay:2];
}
#pragma mark -- action
- (void)segmentAction:(UISegmentedControl *)segmentedControl {
    if (segmentedControl.selectedSegmentIndex == 0) {
        [self.playerController setRate:0.5];
    } else if (segmentedControl.selectedSegmentIndex == 1) {
        [self.playerController setRate:1];
    } else if (segmentedControl.selectedSegmentIndex == 2) {
        [self.playerController setRate:1.5];
    } else if (segmentedControl.selectedSegmentIndex == 3) {
        [self.playerController setRate:2];
    }
}

#pragma mark -- 横竖屏监听
- (void)deviceOrientationDidChange {
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait) {
        [self orientationChange:NO];
    } else if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
        [self orientationChange:YES];
    }
}

- (void)orientationChange:(BOOL)landscape {
    [self.segmentedControl setHidden:landscape];
    [self.tableView setHidden:landscape];
    if (landscape) {
        CGFloat width  = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        [self.containView setFrame:CGRectMake(0, 0, width, height)];
    } else {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = width * 9 / 16;
        [self.containView setFrame:CGRectMake(0, 0, width, height)];
    }
    [self.playerController reLayout];
}
@end

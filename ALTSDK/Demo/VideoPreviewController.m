//
//  VideoPreviewController.m
//  ALTSDK
//
//  Created by Alienchang on 2019/6/3.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "VideoPreviewController.h"
#import "ALTPlayerController+Event.h"
#import "UIView+LQPanScale.h"
#import "UIWindow+NEExt.h"
#import "EventMessageCell.h"

@interface VideoPreviewController () <ALTPlayerControllerDelegate ,UITableViewDelegate ,UITableViewDataSource>
@property (nonatomic ,strong) UIView *containView;
@property (nonatomic ,strong) ALTPlayerController *playerController;
@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSMutableArray *videoEventArray;
@end

@implementation VideoPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:31 /255. green:30 /255. blue:29 /255. alpha:1]];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = width * 2 / 3;

    UIView *statusBarBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, [UIWindow keyWindowSafeAreaInsets].top)];
    [statusBarBGView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:statusBarBGView];
    
    [self.view addSubview:self.imageView];
    [self.imageView setFrame:CGRectMake(0, [UIWindow keyWindowSafeAreaInsets].top, width, height)];
    [self.imageView addSubview:self.containView];
    [self.containView setFrame:self.imageView.bounds];
    
    self.playerController = [[ALTPlayerController alloc] initWithFrame:self.containView.bounds containView:self.containView];
    [self.playerController setDelegate:self];
    [self.playerController playWithUrl:self.videoUrl];
    
    __weak typeof(self)weakself = self;
    [self.containView panToScaleViewWithHandler:^{
        [weakself dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [self.view addSubview:self.tableView];
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    [self.tableView setFrame:CGRectMake(0, CGRectGetMaxY(self.imageView.frame), width, viewHeight - CGRectGetMaxY(self.imageView.frame))];
}

#pragma mark -- getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setBackgroundColor:[UIColor clearColor]];
        [_tableView registerClass:[EventMessageCell class] forCellReuseIdentifier:NSStringFromClass([EventMessageCell class])];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return _tableView;
}
- (UIView *)containView {
    if (!_containView) {
        _containView = [UIView new];
    }
    return _containView;
}
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
        [_imageView setContentMode:UIViewContentModeScaleAspectFill];
        [_imageView.layer setMasksToBounds:YES];
        [_imageView setBackgroundColor:[UIColor colorWithRed:41. /255 green:42. /255 blue:47. /255 alpha:1]];
        [_imageView setUserInteractionEnabled:YES];
    }
    return _imageView;
}

- (NSMutableArray *)videoEventArray {
    if (!_videoEventArray) {
        _videoEventArray = [NSMutableArray new];
    }
    return _videoEventArray;
}
#pragma mark -- UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videoEventArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([EventMessageCell class])];
    NSDictionary *videoEventInfoDic = self.videoEventArray[indexPath.row];
    [cell.timeLabel setText:videoEventInfoDic[@"paramater"][@"currentTime"]];
    [cell.eventLabel setText:videoEventInfoDic[@"event"]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 20;
}

#pragma mark -- ALTPlayerControllerDelegate
- (void)interactiveEvent:(ALTEventType)event paramater:(NSDictionary *)paramater error:(NSError *)error {
    NSDictionary *videoEventInfoDic = @{@"event":event,
                                        @"paramater":paramater
                                        };
    [self.videoEventArray addObject:videoEventInfoDic];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.videoEventArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    });
}
@end

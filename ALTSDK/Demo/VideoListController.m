//
//  VideoListController.m
//  ALTSDK
//
//  Created by Alienchang on 2019/6/3.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "VideoListController.h"
#import "VideoCell.h"
#import "ALTPlayerController.h"
#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"
#import "UIAlertController+NEExt.h"
#import "UITableViewCell+LQScaleAnimate.h"
#import "UIViewController+LQPresentAnimate.h"
#import "VideoPreviewController.h"

@interface VideoListController () <UITableViewDelegate ,UITableViewDataSource>
@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSMutableArray *videoUrls;

@end

@implementation VideoListController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *image = [UIImage imageNamed:@"timg (3).jpeg"];
    UIColor *color = [UIColor colorWithPatternImage:image];
    [self.view setBackgroundColor:color];
    
    CGRect tableViewFrame = self.view.bounds;
    tableViewFrame.size.height -= ([UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height);
    [self.tableView setFrame:tableViewFrame];
    
    NSDictionary * dict = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    [self setTitle:@"播放列表"];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.view addSubview:self.tableView];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(nextPage)]];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addVideo)]];
    
}

- (void)addVideo {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"添加视频地址" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField = textField;
    }];
    UITextField *textField = alertController.textFields[0];
    __weak typeof(self)weakself = self;
    [alertController addConfirmActionWithText:@"确定" textColor:nil font:nil alignment:NSTextAlignmentCenter click:^(UIAlertAction *alertAction) {
        VideoPreviewController *viewController = [VideoPreviewController new];
        [viewController setVideoUrl:textField.text];
        [weakself presentViewController:viewController animated:YES completion:nil];
    }];
    [alertController addCancelActionWithText:@"取消" textColor:nil font:nil alignment:NSTextAlignmentCenter click:^(UIAlertAction *alertAction) {
        
    }];
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

- (void)nextPage {
    ViewController *viewController = [ViewController new];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setVideoUrls:[[ALTPlayerController cachedUrls] mutableCopy]];
    [self.tableView reloadData];
}

#pragma mark -- getter
- (NSMutableArray *)videoUrls {
    if (!_videoUrls) {
        _videoUrls = [NSMutableArray new];
    }
    return _videoUrls;
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView registerClass:[VideoCell class] forCellReuseIdentifier:NSStringFromClass([VideoCell class])];
        [_tableView setBackgroundColor:[UIColor clearColor]];
    }
    return _tableView;
}

#pragma mark -- UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videoUrls.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VideoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([VideoCell class])];
    NSString *url = self.videoUrls[indexPath.row];
    [cell.fileNameLabel setText:url];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *videoPath = [ALTPlayerController localPathWithUrl:url];
        UIImage *image = [self thumbnailImageForVideo:[NSURL fileURLWithPath:videoPath] atTime:1];
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.coverImageView setImage:image];
        });
    });
    
    __weak typeof(self)weakself = self;
    [cell setMoreButtonBlock:^{
        UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:@"是否删除" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [actionSheetController addConfirmActionWithText:@"删除" textColor:nil font:nil alignment:NSTextAlignmentCenter click:^(UIAlertAction *alertAction) {
            [weakself.videoUrls removeObject:url];
            [weakself.tableView reloadData];
            [ALTPlayerController cleanCacheForURL:[NSURL URLWithString:url] error:nil];
        }];
        [actionSheetController addCancelActionWithText:@"取消" textColor:nil font:nil alignment:NSTextAlignmentCenter click:nil];
        [weakself presentViewController:actionSheetController animated:YES completion:nil];
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    VideoCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *url = self.videoUrls[indexPath.row];
    VideoPreviewController *viewController = [VideoPreviewController new];
    [viewController setVideoUrl:url];
    [viewController setTransitioningDelegate:self];
    [viewController setOriginView:cell.coverImageView];
    [self setOriginView:cell.coverImageView];
    [viewController.imageView setImage:cell.coverImageView.image];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [VideoCell cellHeight];
}


- (UIImage *)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [VideoCell cellHeight];
    [assetImageGenerator setMaximumSize:CGSizeMake(width, height)];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 1) actualTime:NULL error:&thumbnailImageGenerationError];
    if (thumbnailImageGenerationError) {
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    }
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    return thumbnailImage;
}
@end

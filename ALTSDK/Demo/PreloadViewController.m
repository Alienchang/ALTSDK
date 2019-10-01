//
//  PreloadViewController.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/26.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "PreloadViewController.h"
#import "ALTPlayer.h"
#import "PreloadCell.h"
//#import "ALTAVPlayer/ALTPlayer.h"
@interface PreloadViewController () <UITableViewDelegate ,UITableViewDataSource ,ALTPlayerDelegate>
@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) ALTPlayer *player;
@end

@implementation PreloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.tableView];
    [self.tableView setFrame:self.view.bounds];
    // Do any additional setup after loading the view.
}

#pragma mark -- getter
- (ALTPlayer *)player {
    if (!_player) {
        _player = [ALTPlayer new];
        [_player setDelegate:self];
    }
    return _player;
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        [_tableView setEstimatedRowHeight:0];
        [_tableView setEstimatedSectionFooterHeight:0];
        [_tableView setEstimatedSectionHeaderHeight:0];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        [_tableView registerClass:[PreloadCell class] forCellReuseIdentifier:@"PreloadCell"];
    }
    return _tableView;
}

#pragma mark -- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videoUrlArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PreloadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PreloadCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.urlLabel setText:self.videoUrlArray[indexPath.row]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *urlString = self.videoUrlArray[indexPath.row];
    [self.player preload:urlString loadSize:3 * 1024 * 1024];
}

- (void)preloadProgress:(float)progress
               finished:(BOOL)finished
                    url:(NSString *)url {
    NSInteger index = [self.videoUrlArray indexOfObject:url];
    dispatch_async(dispatch_get_main_queue(), ^{
        PreloadCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        if (finished) {
            [cell.progressLabel setText:@"下载完成"];
            NSLog(@"%@ 完成",url);
        } else {
            [cell.progressLabel setText:[NSString stringWithFormat:@"进度 %d%%",(int)(progress * 100)]];
            NSLog(@"%@ 进度 %d%%",url,(int)(progress * 100));
        }
    });
}
@end

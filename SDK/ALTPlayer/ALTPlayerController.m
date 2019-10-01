//
//  ALTPlayerController.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/21.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "ALTPlayerController.h"
#import "ALTAVPlayer/ALTPlayer.h"
#import "NEAudioPlayer.h"
#import "PlayerControl/ALTVideoControlView.h"
#import "ALTUtil.h"
#import "ALTCommonMacro.h"
#import "ALTEventTrigger.h"

#import "ALTWebView.h"
#import "ALTWebviewController.h"
#import "ALTEventConst.h"
#import "ALTPlayerController+Event.h"
#import "ALTConfigParser.h"
#import "ALTSafeThread.h"
#import "ALTNetworkService.h"
#import "ALTParserUtil.h"
#import "ALTIVFDecoder.h"
#import "ALTPlayerControl.h"
#import "ALTEventRouter.h"

@interface ALTPlayerController()<ALTPlayerDelegate ,ALTVideoControlEvent> {
    UIView *_playerView;
}
@property (nonatomic ,strong) ALTPlayer       *player;
@property (nonatomic ,strong) UIView          *containView;
@property (nonatomic ,strong) ALTEventTrigger *eventTrigger;
@property (nonatomic ,strong) NEAudioPlayer   *audioPlayer;
@property (nonatomic ,strong) ALTVideoControlView *playerControl;
@property (nonatomic ,strong) ALTWebviewController *webviewController;
@property (nonatomic ,strong) ALTProjectDataSource *projectDataSource;
@property (nonatomic ,copy)   void(^playBackBlock)(ALT_ENUM_PLAYEVENT event);
@property (nonatomic ,strong) ALTIVFDecoder   *ivfDecoder;

@end
@implementation ALTPlayerController
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
/// 初始化，需要显示的位置与载体view
- (instancetype)initWithFrame:(CGRect)frame
                  containView:(UIView *)containView {
    self = [self init];
    if (self) {
        self.player = [[ALTPlayer alloc] initWithFrame:frame containView:containView];
        [self.player setDelegate:self];
        [containView addSubview:self.playerControl];
        CGRect controlFrame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        [self.playerControl setFrame:controlFrame];
        [self.playerControl layout];
        [self setContainView:containView];
        [self setupWithEventTrigger:self.eventTrigger];
        [self.ivfDecoder setupVideoContainWidth:CGRectGetWidth(self.containView.frame) videoContainHeight:CGRectGetHeight(self.containView.frame)];
    }
    return self;
}

#pragma mark -- setter
- (void)setVolume:(float)volume {
    _volume = volume;
}

- (void)setRate:(float)rate {
    _rate = rate;
    [self.player setRate:rate];
}

#pragma mark -- getter
- (ALTIVFDecoder *)ivfDecoder {
    if (!_ivfDecoder) {
        _ivfDecoder = [[ALTIVFDecoder alloc] initWithVideoContainWidth:CGRectGetWidth(self.containView.frame) videoContainHeight:CGRectGetHeight(self.containView.frame)];
    }
    return _ivfDecoder;
}
- (ALTWebviewController *)webviewController {
    if (!_webviewController) {
        _webviewController = [ALTWebviewController new];
    }
    return _webviewController;
}

- (ALTEventTrigger *)eventTrigger {
    if (!_eventTrigger) {
        if (!self.projectDataSource) {
            return nil;
        } else {
            _eventTrigger = [[ALTEventTrigger alloc] initWithProjectDataSource:self.projectDataSource];
        }
    }
    return _eventTrigger;
}

- (NEAudioPlayer *)audioPlayer {
    if (!_audioPlayer) {
        _audioPlayer = [NEAudioPlayer new];
    }
    return _audioPlayer;
}
- (int)fps {
    return self.player.currentFps;
}
- (ALTVideoControlView *)playerControl {
    if (!_playerControl) {
        _playerControl = [ALTVideoControlView new];
        [_playerControl setDelegate:self];
        [_playerControl show:NO];
        ALTWeakSelf;
        [_playerControl setPlayCallBack:^(BOOL play) {
            if (play) {
                [weakSelf.player resume];
            } else {
                [weakSelf.player pause];
            }
        }];
    }
    return _playerControl;
}
#pragma mark -- private func
- (void)setupWithEventTrigger:(ALTEventTrigger *)eventTrigger {    
    if ([self.projectDataSource.project.videoFit isEqualToString:kContain]) {
        [self.player setContentMode:ALTVideoGravityResizeAspect];
    } else {
        [self.player setContentMode:ALTVideoGravityResizeAspectFill];
    }
}

- (void)playWithUrl:(NSString *)url
           callBack:(void (^)(ALT_ENUM_PLAYEVENT event))callBack {
    
    [self setPlayBackBlock:callBack];
    [self playWithUrl:url];
};

#pragma mark -- public func
- (void)playAudio:(NSString *)audioUrl {
    [self.audioPlayer playWithUrl:audioUrl];
}
- (void)audioPause {
    [self.audioPlayer pause];
}
- (void)audioStop {
    [self.audioPlayer stop];
}
- (void)audioResume {
    [self.audioPlayer resume];
}

- (void)videoPause {
    [self.player pause];
}
- (void)videoStop {
    [self.player stop];
}
- (void)videoResume {
    [self.player resume];
}

- (UIImage *)videoShort {
    return [self.player videoShort];
}

/**
 播放视频，url可以是本地和网络地址
 */
- (void)playWithUrl:(NSString *)url {
    if ([url isEqualToString:self.player.currentSourceUrl]) {
        return;
    }
    [self resetData];
    NSURL *tempUrl = nil;
    if ([url containsString:@"http"]) {
        tempUrl = [NSURL URLWithString:url];
        [self.player playWithUrl:tempUrl];
    } else {
        tempUrl = [NSURL fileURLWithPath:url];
        [self.player playWithUrl:tempUrl];
        dispatch_queue_t queue = dispatch_queue_create("com.event.parseConfig.queue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(queue, ^{
            self.projectDataSource = [self.ivfDecoder parseVideoConfigWithIVFPath:self.player.currentSourceUrl data:nil];
        });
    }
}
- (void)resetData {
    [self setEventTrigger:nil];
    [self setProjectDataSource:nil];
    [self.playerControl removeAllComponent];
    [self.player reset];
}

- (void)playWithProjectId:(NSString *)projectId
                episodeId:(NSString *)episodeId
             configParsed:(void(^)(BOOL success))parsed {
    ALTWeakSelf;
    [[ALTNetworkService service] loadConfigWithProjectId:projectId
                                               episodeId:episodeId
                                            successBlock:^(NSData * _Nonnull data) {
                                                weakSelf.projectDataSource = [ALTConfigParser parseConfigWithData:data fps:25];
                                                [weakSelf.projectDataSource.project setPlayerWidth:CGRectGetWidth(self.containView.frame)];
                                                [weakSelf.projectDataSource.project setPlayerHeight:CGRectGetHeight(self.containView.frame)];
                                                if (parsed) {
                                                    parsed(YES);
                                                }
                                                NSString *videoUrl = [ALTParserUtil videoUrlWithPath:[weakSelf.projectDataSource startVideoResource].br dataSource:weakSelf.projectDataSource];
                                                [weakSelf playWithUrl:videoUrl];
    } failureBlock:^(NSError * _Nonnull error) {
        
    }];
}

- (void)reLayout {
    [self.projectDataSource.project setPlayerWidth:CGRectGetWidth(self.containView.bounds)];
    [self.projectDataSource.project setPlayerHeight:CGRectGetHeight(self.containView.bounds)];
    [self.player setPlayerFrame:self.containView.bounds];
    [self.playerControl setFrame:self.containView.bounds];
}
+ (void)initCache {
    [ALTPlayer setupCache];
}
+ (unsigned long long)calculateCachedSizeWithError:(NSError **)error {
    return [ALTPlayer calculateCachedSizeWithError:error];
}

+ (void)cleanAllCacheWithError:(NSError **)error {
    [ALTPlayer cleanAllCacheWithError:error];
}

+ (void)cleanCacheForURL:(NSURL *)url error:(NSError **)error {
    [ALTPlayer cleanCacheForURL:url error:error];
}
+ (NSArray <NSString *>*)cachedUrls {
    return [ALTPlayer cachedUrls];
}
+ (NSArray <NSString *>*)cachedList {
    return [ALTPlayer cachedFiles];
}

+ (NSString *)localPathWithUrl:(NSString *)url {
    return [ALTPlayer cachePathWithUrlString:url];
}

- (void)syncVideoShort:(void(^)(UIImage *shortImage))callBack {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = self.videoShort;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callBack) {
                callBack(image);
            }
        });
    });
}

#pragma mark -- ALTPlayerDelegate
- (void)playbackData:(NSData *)data {
    self.projectDataSource = [self.ivfDecoder parseVideoConfigWithIVFPath:self.player.currentSourceUrl data:data];
}

- (void)cacheFinished {
    if ([self.delegate respondsToSelector:@selector(cacheFinished)]) {
        if ([NSThread isMainThread]) {
            [self.delegate cacheFinished];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate cacheFinished];
            });
        }
    }
}

- (void)cacheProgress:(float)progress {
    if ([self.delegate respondsToSelector:@selector(cacheProgress:)]) {
        if ([NSThread isMainThread]) {
            [self.delegate cacheProgress:progress];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate cacheProgress:progress];
            });
        }
    }
}

- (void)playEvent:(ALT_ENUM_PLAYEVENT)event
            error:(NSError *)error {
    [ALTSafeThread safe_async_main:^{
        if (event == PLAY_EVENT_VIDEO_READYTOPLAY) {
            /// 准备开始播放
            [self.playerControl show:YES];
            [self.playerControl setPlaying:YES];
            if ([self.delegate respondsToSelector:@selector(playEvent:error:)]) {
                [self.delegate playEvent:event error:error];
            }
            [self.playerControl removeAllComponent];
        } else if (event == PLAY_EVENT_VIDEO_PLAY_FINISHED) {
            [self.eventTrigger callEventWhenFinished];
            if ([self.delegate respondsToSelector:@selector(playEvent:error:)]) {
                [self.delegate playEvent:event error:error];
            }
        }
        if (self.playBackBlock) {
            self.playBackBlock(event);
        }
    }];
}

- (void)playProgress:(float)progress
         currentTime:(NSTimeInterval)currentTime {
    /// 触发事件
    ALTWeakSelf;
    [self.eventTrigger callEventWithTime:currentTime eventBlock:^(ALTEventType  _Nonnull eventType, NSDictionary * _Nonnull paramater) {
        [weakSelf callEventWithType:eventType paramater:paramater];
    }];

    if ([self.delegate respondsToSelector:@selector(playProgress:currentTime:)]) {
        [self.delegate playProgress:progress currentTime:currentTime];
    }
}


#pragma mark -- ALTVideoControlEvent
- (void)callEvent:(NSString *)eventId dataSource:(ALTProjectDataSource *)dataSource {
    [ALTEventRouter executeEventWithEventId:eventId projectDataSource:dataSource eventBlock:^(ALTEventType  _Nonnull eventType, NSDictionary * _Nonnull paramater) {
        [self callEventWithType:eventType paramater:paramater];
    }];
}

- (void)dealloc {
    
}

#pragma mark -- private




@end

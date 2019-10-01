//
//  ALTPlayer.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/18.
//  Copyright © 2019年 Alienchang. All rights reserved.
//

#import "ALTPlayer.h"
#import <AVKit/AVKit.h>
#import "ALTMediaCache.h"
#import "ALTMediaCacheWorker.h"

@interface ALTPlayer() <ALTMediaDownloaderDelegate ,ALTResourceLoaderManagerDelegate> {
    NSString *_currentPlayUrl;
    CGRect   _playerFrame;
}
@property (nonatomic ,strong) AVPlayer       *player;
@property (nonatomic ,strong) AVPlayerItem   *playerItem;
@property (nonatomic ,strong) UIView         *containView;
@property (nonatomic ,strong) AVPlayerLayer  *playerLayer;
@property (nonatomic ,assign) CGFloat        progress;
@property (nonatomic ,assign) NSTimeInterval loopBeginTime; /// 标记开始循环时间
@property (nonatomic ,assign) NSTimeInterval loopEndTime;   /// 标记开始循环时间
@property (nonatomic ,strong) AVPlayerItemVideoOutput *videoOutput; /// 视频输出对象
@property (nonatomic ,assign) BOOL           seeking;       /// 是否正在seek

/// 视频下载管理器
@property (nonatomic ,strong) ALTResourceLoaderManager *resourceLoaderManager;
@property (nonatomic ,strong) NSMutableArray <ALTMediaDownloader *>*mediaDownloaders;

@property (nonatomic ,assign) float currentVideoCacheProgress;
@end

@implementation ALTPlayer
+ (void)setupCache {
    [ALTCacheManager setCacheDirectory:[NSTemporaryDirectory() stringByAppendingPathComponent:@"ALTMedia"]];
}
- (instancetype)initWithFrame:(CGRect)frame
                  containView:(UIView *)containView {
    self = [super init];
    if (self) {
        [self setContainView:containView];
        _playerFrame = frame;
        _resourceLoaderManager = [ALTResourceLoaderManager new];
        [_resourceLoaderManager setDelegate:self];
    }
    return self;
}

- (void)playWithUrl:(NSURL *)url range:(NSRange)range {
    [self setProgress:0];
    _currentPlayUrl = [url.absoluteString copy];
    [self.resourceLoaderManager cancelLoaders];
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(status))];
    }
    
    if ([url.absoluteString containsString:@"http"]) {
        self.playerItem = [self.resourceLoaderManager playerItemWithURL:url];
    } else {
        self.playerItem = [[AVPlayerItem alloc] initWithURL:url];
    }
    self.videoOutput = [AVPlayerItemVideoOutput new];
    [self.playerItem addOutput:self.videoOutput];
    [self.playerItem addObserver:self forKeyPath:NSStringFromSelector(@selector(status)) options:NSKeyValueObservingOptionNew context:nil];
    if (self.player) {
        [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    } else {
        self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
        if (@available(iOS 10.0, *)) {
            [self.player setAutomaticallyWaitsToMinimizeStalling:NO];
        }
        __weak typeof(self) weakSelf = self;
        [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 10) queue:nil usingBlock:^(CMTime time) {
            if (self.playerStatus == ALT_ENUM_PLAYER_PLAYING)
                if ([weakSelf.delegate respondsToSelector:@selector(playProgress:currentTime:)]) {
                    /// 获取当前播放时间
                    float currentTime = (float)CMTimeGetSeconds(weakSelf.playerItem.currentTime);
                    
                    float progress = currentTime / CMTimeGetSeconds(weakSelf.playerItem.duration);
                    if (progress > 1) {
                        progress = 1;
                    }
                    if (progress < 0) {
                        progress = 0;
                    }
                    [weakSelf setProgress:progress];
                    [weakSelf.delegate playProgress:progress currentTime:currentTime];
                }
            
            if (weakSelf.loop && weakSelf.loopBeginTime != 0 && weakSelf.loopEndTime > weakSelf.loopBeginTime) {
                CGFloat currentTime = CMTimeGetSeconds(weakSelf.playerItem.currentTime);
                if (currentTime >= weakSelf.loopEndTime) {
                    [weakSelf pause];
                    [weakSelf seek:weakSelf.loopBeginTime];
                    return;
                }
            }
        }];
    }
    if (!self.playerLayer) {
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        [self.playerLayer setFrame:_playerFrame];
        [self.playerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
        [self.containView.layer insertSublayer:self.playerLayer atIndex:0];
    }
    /// 添加事件监听
    [self addNotification];
    [self.player play];
    _playerStatus = ALT_ENUM_PLAYER_PLAYING;
}
- (void)playWithUrl:(NSURL *)url {
    [self playWithUrl:url range:NSMakeRange(0, 0)];
}

#pragma mark -- private func
- (void)mediaCacheDidChanged:(NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(cacheProgress:)]) {
        NSDictionary *userInfo = notification.userInfo;
        ALTCacheConfiguration *configuration = userInfo[ALTCacheConfigurationKey];

        if ([configuration.url.absoluteString isEqualToString:self.currentSourceUrl]) {
            NSArray<NSValue *> *cachedFragments = configuration.cacheFragments;
            long long contentLength = configuration.contentInfo.contentLength;
            NSInteger number = 100;
            __weak typeof(self) weakSelf = self;
            [cachedFragments enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSRange range = obj.rangeValue;
                NSInteger length = roundf((range.length / (double)contentLength) * number);
                float progress = length / 100.0;
                [self.delegate cacheProgress:progress];
                [weakSelf setCurrentVideoCacheProgress:progress];
            }];
        }
    }
}

- (void)mediaCacheFinished:(NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(cacheFinished)]) {
        [self.delegate cacheFinished];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(status))] && self.playerItem == object) {
        if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
            /// 获取当前播放视频的fps
            for (AVPlayerItemTrack *track in self.playerItem.tracks) {
                if ([track.assetTrack.mediaType isEqualToString:AVMediaTypeVideo]) {
                    _currentFps = track.assetTrack.nominalFrameRate;
                }
            }
            
            /// 准备开始播放
            if ([self.delegate respondsToSelector:@selector(playEvent:error:)]) {
                [self.delegate playEvent:PLAY_EVENT_VIDEO_READYTOPLAY error:nil];
            }
        } else if (self.playerItem.status == AVPlayerItemStatusFailed) {
            _currentFps = 0;
            /// 播放失败
            if ([self.delegate respondsToSelector:@selector(playEvent:error:)]) {
                [self.delegate playEvent:PLAY_EVENT_VIDEO_PLAYER_ERROR error:nil];
            }
        } else {
            /// 未知状态
            
        }
    }
}
- (void)addNotification {
    /// 添加视频缓存进度
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaCacheDidChanged:) name:ALTCacheManagerDidUpdateCacheNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaCacheFinished:) name:ALTCacheManagerDidFinishCacheNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
//
//    AVF_EXPORT NSString *const AVPlayerItemTimeJumpedNotification             NS_AVAILABLE(10_7, 5_0);    // the item's current time has changed discontinuously
//    AVF_EXPORT NSString *const AVPlayerItemDidPlayToEndTimeNotification      NS_AVAILABLE(10_7, 4_0);   // item has played to its end time
//    AVF_EXPORT NSString *const AVPlayerItemFailedToPlayToEndTimeNotification NS_AVAILABLE(10_7, 4_3);   // item has failed to play to its end time
//    AVF_EXPORT NSString *const AVPlayerItemPlaybackStalledNotification       NS_AVAILABLE(10_9, 6_0);    // media did not arrive in time to continue playback
//    AVF_EXPORT NSString *const AVPlayerItemNewAccessLogEntryNotification     NS_AVAILABLE(10_9, 6_0);    // a new access log entry has been added
//    AVF_EXPORT NSString *const AVPlayerItemNewErrorLogEntryNotification         NS_AVAILABLE(10_9, 6_0);    // a new error log entry has been added
//
//    // notification userInfo key                                                                    type
//    AVF_EXPORT NSString *const AVPlayerItemFailedToPlayToEndTimeErrorKey
}
- (void)playbackFinished:(NSNotification *)notification {
    if ([notification.object isMemberOfClass:[AVPlayerItem class]] && self.playerItem == notification.object) {
        if (self.loop) {
            [self.player seekToTime:CMTimeMake(0, 1)];
        } else {
            _playerStatus = ALT_ENUM_PLAYER_FINISHED;
            [self.delegate playEvent:PLAY_EVENT_VIDEO_PLAY_FINISHED error:nil];
        }
    }
}

#pragma mark -- public func
- (void)reset {
    _currentPlayUrl = nil;
}
- (void)setContentMode:(ALTVideoFillMode)contentMode {
    switch (contentMode) {
        case ALTVideoGravityResizeAspect:
            [self.playerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
            break;
        case ALTVideoGravityResizeAspectFill:
            [self.playerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
            break;
        case ALTVideoGravityResize:
            [self.playerLayer setVideoGravity:AVLayerVideoGravityResize];
            break;
        default:
            [self.playerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
            break;
    }
}

- (void)setPlayerFrame:(CGRect)frame {
    [self.playerLayer setFrame:frame];
    [self.playerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
}
+ (unsigned long long)calculateCachedSizeWithError:(NSError **)error {
    return [ALTCacheManager calculateCachedSizeWithError:error];
}
+ (void)cleanAllCacheWithError:(NSError **)error {
    [ALTCacheManager cleanAllCacheWithError:error];
}
+ (void)cleanCacheForURL:(NSURL *)url error:(NSError **)error {
    [ALTCacheManager cleanCacheForURL:url error:error];
}
+ (NSArray <NSArray *>*)cachedUrls {
    return [ALTCacheManager cachedUrls];
}
+ (NSArray <NSArray *>*)cachedFiles {
    return [ALTCacheManager cachedFiles];
}
+ (NSString *)cachePathWithUrlString:(NSString *)urlString {
    return [ALTCacheManager cachedFilePathForURL:[NSURL URLWithString:urlString]];
}
- (void)loopInBegin:(NSTimeInterval)begin
                end:(NSTimeInterval)end {
    [self setLoopBeginTime:begin];
    [self setLoopEndTime:end];
    [self setLoop:YES];
}

- (void)preload:(NSString *)url
    startOffset:(unsigned long long)startOffset
       loadSize:(unsigned long long)size {
    NSURL *temp = [NSURL URLWithString:url];
    ALTMediaCacheWorker *cacheWorker = [[ALTMediaCacheWorker alloc] initWithURL:temp];
    ALTMediaDownloader *mediaDownloader = [[ALTMediaDownloader alloc] initWithURL:temp cacheWorker:cacheWorker];
    [mediaDownloader setDelegate:self];
    [mediaDownloader downloadTaskFromOffset:startOffset length:size toEnd:NO];
    [self.mediaDownloaders addObject:mediaDownloader];
}
- (void)preload:(NSString *)url
       loadSize:(unsigned long long)size {
    [self preload:url startOffset:0 loadSize:size];
}
- (void)preloadAtOffset:(long long)offset
               loadSize:(long long )size {
    [self.resourceLoaderManager asyncLoadAt:offset size:size videourl:self.currentSourceUrl];
}

- (void)stop {
    _playerStatus = ALT_ENUM_PLAYER_FINISHED;
    [self.player pause];
    [self.playerLayer removeFromSuperlayer];
    [self setPlayerLayer:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)pause {
    _playerStatus = ALT_ENUM_PLAYER_PAUSE;
    [self.player pause];
}

- (void)resume {
    _playerStatus = ALT_ENUM_PLAYER_PLAYING;
    [self.player play];
}

- (void)setMute:(BOOL)mute {
    [self.player setMuted:mute];
}
/// 跳转
- (void)seek:(NSTimeInterval)time {
    if (self.seeking) {
        return;
    }
    [self setSeeking:YES];
    [self.player pause];
    __weak typeof(self) weakSelf = self;
    
    [self.player seekToTime:CMTimeMake(time * 600, 600) toleranceBefore:CMTimeMake(1, 600) toleranceAfter:CMTimeMake(1, 600) completionHandler:^(BOOL finished) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (self.delegate && [self.delegate respondsToSelector:@selector(playEvent:error:)]) {
            [self.delegate playEvent:PLAY_EVENT_DID_SEEK_COMPLETE error:nil];
        }
        [strongSelf resume];
        [self setSeeking:NO];
    }];
}

- (void)seekAtOffset:(long long)offset  {
    [self stop];
    [self playWithUrl:[NSURL URLWithString:self.currentSourceUrl]];
}

- (UIImage *)videoShort {
    CMTime itemTime = self.playerItem.currentTime;
    CVPixelBufferRef pixelBuffer = [self.videoOutput copyPixelBufferForItemTime:itemTime itemTimeForDisplay:nil];
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer))];
    UIImage *currentImage = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);
    return currentImage;
}

/// 播放速率 0.5 - 2 ，超出范围按照极值计算
- (void)setRate:(float)rate {
    _rate = rate;
    [self.player setRate:rate];
}
#pragma mark -- setter
- (void)setLoop:(BOOL)loop {
    _loop = loop;
    if (!loop) {
        _loopBeginTime = 0;
        _loopEndTime = 0;
    }
}
#pragma mark -- getter
- (long long)currentPreloadOffset {
    ALTResourceLoader *resourceLoader = [self.resourceLoaderManager resourceLoaderWithVideoUrl:self.currentSourceUrl];
    return resourceLoader.mediaDownloader.currentDownloadEndOffset;
}

- (NSMutableArray *)mediaDownloaders {
    if (!_mediaDownloaders) {
        _mediaDownloaders = [NSMutableArray new];
    }
    return _mediaDownloaders;
}
- (float)currentCacheProgress {
    return self.currentVideoCacheProgress;
}
- (NSString *)currentSourceUrl {
    return _currentPlayUrl;
}
- (NSTimeInterval)duration {
    return (NSTimeInterval)CMTimeGetSeconds(self.playerItem.duration);
}

- (NSTimeInterval)currentTime {
    return (NSTimeInterval)CMTimeGetSeconds(self.playerItem.currentTime);
}
#pragma mark -- ALTResourceLoaderManagerDelegate
- (void)resourceLoaderManagerLoadData:(NSData *)data {
    if ([self.delegate respondsToSelector:@selector(playbackData:)]) {
        [self.delegate playbackData:data];
    }
}

- (void)resourceLoaderManagerLoadURL:(NSURL *)url didFailWithError:(NSError *)error {
    
}

#pragma mark -- ALTMediaDownloaderDelegate
- (void)mediaDownloader:(ALTMediaDownloader *)downloader didReceiveResponse:(NSURLResponse *)response {
    if ([self.delegate respondsToSelector:@selector(preloadProgress:finished:url:cachePath:)]) {
        [self.delegate preloadProgress:downloader.progress finished:NO url:downloader.url.absoluteString cachePath:downloader.cacheWorker.cacheConfiguration.filePath];
    }
}
- (void)mediaDownloader:(ALTMediaDownloader *)downloader didReceiveData:(NSData *)data {
    if ([self.delegate respondsToSelector:@selector(preloadProgress:finished:url:cachePath:)]) {
        [self.delegate preloadProgress:downloader.progress finished:NO url:downloader.url.absoluteString cachePath:downloader.cacheWorker.cacheConfiguration.filePath];
    }
}
- (void)mediaDownloader:(ALTMediaDownloader *)downloader didFinishedWithError:(NSError *)error {
    if (!error) {
        if ([self.delegate respondsToSelector:@selector(preloadProgress:finished:url:cachePath:)]) {
            [self.delegate preloadProgress:1 finished:YES url:downloader.url.absoluteString cachePath:downloader.cacheWorker.cacheConfiguration.filePath];
        }
        [self.mediaDownloaders removeObject:downloader];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end

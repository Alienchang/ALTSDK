////
////  ALTPlayer.m
////  ALTSDK
////
////  Created by Alienchang on 2019/3/13.
////  Copyright © 2019年 Alienchang. All rights reserved.
////
//
//#import "ALTPlayer.h"
//#import <IJKMediaFramework/IJKMediaFramework.h>
//#import "ALTGLView.h"
//#import "ALTUtil.h"
//@interface ALTPlayer() {
//    NSString *_currentPlayUrl;
//    BOOL _DID_FFP_MSG_VIDEO_RENDERING_START;
//}
///// 默认音量
//@property (nonatomic ,assign) CGFloat defaultVolume;
//@property (nonatomic ,strong) UIView *containView;
//@property (nonatomic ,strong) IJKFFMoviePlayerController *ijkPlayer;
///// 用于检测视频播放进度
//@property (nonatomic ,strong) CADisplayLink *displayLink;
//@property (nonatomic ,assign) CGFloat progress;
//
//@end
//@implementation ALTPlayer
//- (instancetype)initWithFrame:(CGRect)frame
//                  containView:(UIView *)containView {
//    self = [super init];
//    if (self) {
//        [self setContainView:containView];
//        [self addPlayStatusObserver];
//    }
//    return self;
//}
//
//#pragma mark -- public func
//- (NSString *)currentSourceUrl {
//    return [NSString stringWithFormat:@"%@",_currentPlayUrl];
//}
//
//- (void)playWithUrl:(NSString *)url
//       videoQuality:(ALT_ENUM_VIDEO_QUALITY)videoQuality {
//
//    _currentPlayUrl = [url copy];
//    _videoQuality = videoQuality;
//
//    IJKFFOptions *ffOptions = [IJKFFOptions optionsByDefault];
//    self.ijkPlayer = [[IJKFFMoviePlayerController alloc] initWithContentURL:[ALTUtil urlStringWithUrlString:url videoQuality:videoQuality] withOptions:ffOptions];
//    [self.containView addSubview:self.ijkPlayer.view];
//    [self.ijkPlayer.view setFrame:self.containView.bounds];
//    [self.ijkPlayer.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
//    [self.ijkPlayer setScalingMode:IJKMPMovieScalingModeAspectFit];
//    [self.ijkPlayer setShouldAutoplay:YES];
//    [self.ijkPlayer prepareToPlay];
//    [self.ijkPlayer play];
//    [self setupDisplaylink];
//}
//
//- (void)stop {
//    [self.displayLink invalidate];
//    [self.ijkPlayer stop];
//}
//- (void)pause {
//    [self.ijkPlayer pause];
//}
//- (void)resume {
//    [self.ijkPlayer play];
//}
//
//- (void)setMute:(BOOL)mute {
//    if (mute) {
//        [self.ijkPlayer setPlaybackVolume:0];
//    } else {
//        [self.ijkPlayer setPlaybackVolume:self.defaultVolume];
//    }
//}
//
//- (void)setRate:(float)rate {
//    [self.ijkPlayer setPlaybackRate:rate];
//}
//
//- (void)seek:(NSTimeInterval)time {
//    [self.ijkPlayer setCurrentPlaybackTime:time];
//}
//#pragma mark -- private func
//
///**
// 用于监测播放进度
// */
//- (void)setupDisplaylink {
//    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(uploadProgress)];
//    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
//}
//- (void)uploadProgress {
//    if (!_DID_FFP_MSG_VIDEO_RENDERING_START) {
//        return;
//    }
//    if (self.ijkPlayer.isPlaying && self.delegate && [self.delegate respondsToSelector:@selector(playProgress:currentTime:)]) {
//        CGFloat progress = self.ijkPlayer.currentPlaybackTime / self.ijkPlayer.duration;
//        if (progress > 1) {
//            progress = 1;
//        }
//        if (progress < 0) {
//            progress = 0;
//        }
//        [self setProgress:progress];
//        [self.delegate playProgress:progress currentTime:self.ijkPlayer.currentPlaybackTime];
//    }
//}
//
//- (void)addPlayStatusObserver {
//    /// 初始化监听对象
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished) name:IJKMPMoviePlayerPlaybackDidFinishNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFristFrameRendered) name:IJKMPMoviePlayerFirstVideoFrameRenderedNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preparedToPlayDidChange) name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateDidChange) name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadStateDidChange) name:IJKMPMoviePlayerLoadStateDidChangeNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(airPlayVideoActiveDidChange) name:IJKMPMoviePlayerIsAirPlayVideoActiveDidChangeNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDecoderOpen) name:IJKMPMoviePlayerVideoDecoderOpenNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstAudioFrameRendered) name:IJKMPMoviePlayerFirstAudioFrameRenderedNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstAudioFrameDecoded) name:IJKMPMoviePlayerFirstAudioFrameDecodedNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstVideoFrameDecoded) name:IJKMPMoviePlayerFirstVideoFrameDecodedNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerOpenInput) name:IJKMPMoviePlayerOpenInputNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findStreamInfo) name:IJKMPMoviePlayerFindStreamInfoNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerComponentOpen) name:IJKMPMoviePlayerComponentOpenNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidSeekComplete) name:IJKMPMoviePlayerDidSeekCompleteNotification object:nil];
//    // 还有几个，不太常用
//}
//
//#pragma mark -- play status call back
//- (void)playFinished {
//    if (self.loop) {
//        [self seek:0];
//        [self.ijkPlayer prepareToPlay];
//        [self.ijkPlayer play];
//    }
//}
//
//- (void)didFristFrameRendered {
//    _DID_FFP_MSG_VIDEO_RENDERING_START = YES;
//    if (self.delegate && [self.delegate respondsToSelector:@selector(playEvent:error:)]) {
//        [self.delegate playEvent:PLAY_EVENT_VIDEO_FIRST_FRAME_RENDERED error:nil];
//    }
//}
//
//- (void)preparedToPlayDidChange {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(playEvent:error:)]) {
//        [self.delegate playEvent:PLAY_EVENT_PREPARED_TO_PLAY_CHANGE error:nil];
//    }
//}
//
//- (void)stateDidChange {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(playEvent:error:)]) {
//        [self.delegate playEvent:PLAY_EVENT_STATUS_CHANGE error:nil];
//    }
//}
//
//- (void)loadStateDidChange {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(playEvent:error:)]) {
//        [self.delegate playEvent:PLAY_EVENT_LOAD_STATUS_CHANGE error:nil];
//    }
//}
//
//- (void)airPlayVideoActiveDidChange {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(playEvent:error:)]) {
//        [self.delegate playEvent:PLAY_EVENT_AIRPLAY_VIDEO_ACTIVE_DIDCHANGE error:nil];
//    }
//}
//- (void)videoDecoderOpen {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(playEvent:error:)]) {
//        [self.delegate playEvent:PLAY_EVENT_VIDEO_DECODER_OPEN error:nil];
//    }
//}
//- (void)firstAudioFrameRendered {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(playEvent:error:)]) {
//        [self.delegate playEvent:PLAY_EVENT_AUDIO_FIRST_FRAME_DECODED error:nil];
//    }
//}
//- (void)firstAudioFrameDecoded {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(playEvent:error:)]) {
//        [self.delegate playEvent:PLAY_EVENT_AUDIO_FIRST_FRAME_DECODED error:nil];
//    }
//}
//- (void)firstVideoFrameDecoded {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(playEvent:error:)]) {
//        [self.delegate playEvent:PLAY_EVENT_VIDEO_FIRST_FRAME_DECODED error:nil];
//    }
//}
//- (void)playerOpenInput {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(playEvent:error:)]) {
//        [self.delegate playEvent:PLAY_EVENT_PLAYER_OPEN_INPUT error:nil];
//    }
//}
//- (void)findStreamInfo {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(playEvent:error:)]) {
//        [self.delegate playEvent:PLAY_EVENT_FIND_STREAM_INFO error:nil];
//    }
//}
//- (void)playerComponentOpen {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(playEvent:error:)]) {
//        [self.delegate playEvent:PLAY_EVENT_PLAYER_COMPONENT_OPEN error:nil];
//    }
//}
//- (void)playerDidSeekComplete {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(playEvent:error:)]) {
//        [self.delegate playEvent:PLAY_EVENT_DID_SEEK_COMPLETE error:nil];
//    }
//}
//- (NSTimeInterval)duration {
//    return self.ijkPlayer.duration;
//}
//
//- (void)dealloc {
//    [self.displayLink invalidate];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}
//@end

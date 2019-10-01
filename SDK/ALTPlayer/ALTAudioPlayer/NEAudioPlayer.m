//
//  NEAudioPlayer.m
//  Musicash
//
//  Created by Chang Liu on 10/25/18.
//  Copyright © 2018 Chang Liu. All rights reserved.
//

#import "NEAudioPlayer.h"
#import <AVKit/AVKit.h>
@interface NEAudioPlayer()<AVAudioPlayerDelegate> {
    BOOL _inPlaying;
}
@property (nonatomic ,strong) AVAudioPlayer *avAudioPlayer;
@property (nonatomic ,strong) CADisplayLink *displayLink;
@property (nonatomic ,copy)   NSString      *url;
@end
@implementation NEAudioPlayer
+ (instancetype)instanceWithUrl:(NSString *)stringUrl {
    NEAudioPlayer *audioPlayer = [[NEAudioPlayer alloc] initWithUrl:stringUrl];
    return audioPlayer;
}

- (instancetype)initWithUrl:(NSString *)stringUrl {
    self = [super init];
    if (self) {
        NSURL *audioUrl = [NSURL fileURLWithPath:stringUrl];
        if (!audioUrl) {
            audioUrl = [NSURL URLWithString:stringUrl];
        }
        NSError *error = nil;
        self.avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:&error];
        [self.avAudioPlayer setVolume:0.5];     // 默认
        [self.avAudioPlayer prepareToPlay];
        [self.avAudioPlayer setDelegate:self];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
#pragma mark -- getter
- (BOOL)playing {
    return _inPlaying;
}
#pragma mark -- setter
- (void)setVolume:(CGFloat)volume {
    _volume = volume;
    [self.avAudioPlayer setVolume:volume];
}
- (void)setRepeatCount:(NSInteger)repeatCount {
    _repeatCount = repeatCount;
    [self.avAudioPlayer setNumberOfLoops:repeatCount];
}

#pragma mark -- public func
- (void)playWithUrl:(NSString *)url {
    NSURL *audioUrl = nil;
    if ([url containsString:@"http"]) {
        audioUrl = [NSURL URLWithString:url];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *audioData = [NSData dataWithContentsOfURL:audioUrl];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = nil;
                self.avAudioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
                [self.avAudioPlayer setVolume:0.5];     // 默认
                [self.avAudioPlayer prepareToPlay];
                [self.avAudioPlayer play];
            });
        });
    } else {
        NSError *error = nil;
        audioUrl = [NSURL fileURLWithPath:url];
        self.avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:&error];
        [self.avAudioPlayer setVolume:0.5];     // 默认
        [self.avAudioPlayer prepareToPlay];
        [self.avAudioPlayer play];
    }
}
- (void)play {
    [self.avAudioPlayer play];
    _inPlaying = YES;
}
- (void)stop {
    [self.avAudioPlayer stop];
    _inPlaying = NO;
}
- (void)pause {
    [self.avAudioPlayer pause];
}
- (void)resume {
    [self.avAudioPlayer play];
}
- (void)playFromTime:(NSTimeInterval)fromTime {
    [self.avAudioPlayer playAtTime:fromTime];
}

- (void)seekTo:(NSTimeInterval)toTime {
    [self.avAudioPlayer setCurrentTime:toTime];
}


#pragma mark -- private func
- (void)setupDisplaylink {
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(uploadProgress)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}
- (void)stopDisplayLink {
    [self.displayLink invalidate];
    [self setDisplayLink:nil];
}
- (void)uploadProgress {
    
}

#pragma mark -- AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    _inPlaying = NO;
}
@end

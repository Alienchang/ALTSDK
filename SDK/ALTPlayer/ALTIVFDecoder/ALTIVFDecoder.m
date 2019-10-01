//
//  ALTIVFDecoder.m
//  ALTSDK
//
//  Created by Alienchang on 2019/5/13.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "ALTIVFDecoder.h"

// 解析配置
#include "alt_mp4_parser.h"
#import "ALTPlayer.h"
#import "ALTConfigParser.h"

// 解析box
#include "mov-reader.h"
#include "mov-format.h"
#include "mov-internal.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>


@interface ALTIVFDecoder() {
   
    int _video_index;
    long _firstSamplePosition;
    // 解析控制
    BOOL _didFFmpegInit;
    BOOL _inPasing;
    NSMutableData *_videoHeaderBuffer;
}
@property (nonatomic ,strong) ALTPlayer       *player;
@property (nonatomic ,assign) CGFloat containViewWidth;
@property (nonatomic ,assign) CGFloat containViewHeight;
@property (nonatomic ,strong) ALTProjectDataSource *dataSource;
@property (nonatomic ,strong) NSMutableDictionary *positionAndPts;
@end
@implementation ALTIVFDecoder
- (instancetype)initWithVideoContainWidth:(CGFloat)videoContainWidth
                       videoContainHeight:(CGFloat)videoContainHeight {
    self = [super init];
    if (self) {
        [self setContainViewWidth:videoContainWidth];
        [self setContainViewHeight:videoContainHeight];
        _videoHeaderBuffer = [NSMutableData new];
    }
    return self;
}
- (void)setupVideoContainWidth:(CGFloat)videoContainWidth
            videoContainHeight:(CGFloat)videoContainHeight {
    [self setContainViewWidth:videoContainWidth];
    [self setContainViewHeight:videoContainHeight];
}

/// 解析视频文件，如果sliceData为nil，则视为播放本地视频
- (ALTProjectDataSource *)parseVideoConfigWithIVFPath:(NSString *)ivfPath
                                                 data:(nullable NSData *)sliceData {
    @synchronized (self) {
        if (!_didFFmpegInit) {
            [_videoHeaderBuffer appendData:sliceData];
            if (_videoHeaderBuffer.length < 8) {
                return nil;
            }
            char *zeroSign[4] = {0 ,0 ,0 ,0};
            BOOL didLoadMdat = NO;
            if (memcmp([_videoHeaderBuffer bytes], zeroSign, 4) == 0) {
                didLoadMdat = did_load_mdat([_videoHeaderBuffer bytes] + 2, _videoHeaderBuffer.length - 2);
            } else {
                didLoadMdat = did_load_mdat([_videoHeaderBuffer bytes], _videoHeaderBuffer.length);
            }
            // 判断完全加载moov之后再初始化ffmpeg
            if (didLoadMdat) {
                NSString *videoCachePath = [ALTPlayer cachePathWithUrlString:ivfPath];
                NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:videoCachePath];
                NSData *videoCacheData = [fileHandle readDataToEndOfFile];
                _firstSamplePosition = firstSamplePosition([videoCacheData bytes]);
                _didFFmpegInit = YES;
                _videoHeaderBuffer = nil;
            } else if (!sliceData) {
                NSString *videoCachePath = [ALTPlayer cachePathWithUrlString:self.player.currentSourceUrl];
                NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:videoCachePath];
                NSData *videoCacheData = [fileHandle readDataToEndOfFile];
                _firstSamplePosition = firstSamplePosition([videoCacheData bytes]);
                _didFFmpegInit = YES;
                _videoHeaderBuffer = nil;
            }
        }
        
        if (_firstSamplePosition && !_inPasing && !self.dataSource) {
            _inPasing = YES;
            NSString *videoCachePath = [ALTPlayer cachePathWithUrlString:ivfPath];
            NSFileHandle *videoCacheHandle = [NSFileHandle fileHandleForReadingAtPath:videoCachePath];
            NSData *fullData = [videoCacheHandle readDataToEndOfFile];
            NSData *cahceData = [fullData subdataWithRange:NSMakeRange(_firstSamplePosition, fullData.length - _firstSamplePosition)];
            long dataSize;
            int ret;
            char *configDataBuffer = parserSample((char *)[cahceData bytes], &dataSize ,&ret);
            
            if (ret) {
                NSData *configData = [NSData dataWithBytes:configDataBuffer length:dataSize];
                int fps = [self parseMp4box:videoCachePath];
                self.dataSource = [ALTConfigParser parseConfigWithData:configData fps:fps];
                [self.dataSource.positionAndPts addEntriesFromDictionary:self.positionAndPts];
                [self.dataSource setVideoUrl:ivfPath];
                [self.dataSource.project setPlayerWidth:self.containViewWidth];
                [self.dataSource.project setPlayerHeight:self.containViewHeight];
                [videoCacheHandle closeFile];
            }
            _inPasing = NO;
        }
    }
    return self.dataSource;
}

// ***********************************  test  ********************************************************************
#if defined(_WIN32) || defined(_WIN64)
#define fseek64 _fseeki64
#define ftell64 _ftelli64
#else
#define fseek64 fseek
#define ftell64 ftell
#endif

static int mov_file_read(void* fp, void* data, uint64_t bytes)
{
    if (bytes == fread(data, 1, bytes, (FILE*)fp))
        return 0;
    return 0 != ferror((FILE*)fp) ? ferror((FILE*)fp) : -1 /*EOF*/;
}

static int mov_file_write(void* fp, const void* data, uint64_t bytes)
{
    return bytes == fwrite(data, 1, bytes, (FILE*)fp) ? 0 : ferror((FILE*)fp);
}

static int mov_file_seek(void* fp, uint64_t offset)
{
    return fseek64((FILE*)fp, offset, SEEK_SET);
}

static uint64_t mov_file_tell(void* fp)
{
    return ftell64((FILE*)fp);
}

const struct mov_buffer_t* mov_file_buffer(void)
{
    static struct mov_buffer_t s_io = {
        mov_file_read,
        mov_file_write,
        mov_file_seek,
        mov_file_tell,
    };
    return &s_io;
}

- (int)parseMp4box:(NSString *)path {
    FILE *fp = fopen([path UTF8String], "rb");
    mov_reader_t* mov = mov_reader_create(mov_file_buffer(), fp);
    int trackCount = 0;
    self.positionAndPts = [NSMutableDictionary new];
    for (int i = 0; i < mov->mov.track_count; ++i) {
        struct mov_track_t track = mov->mov.tracks[i];
        for (int j = 0; j < track.sample_count; ++j) {
            trackCount ++;
            struct mov_sample_t sample = track.samples[j];
            float pts = sample.pts * 1.0 / 100;
            NSString *key = [NSString stringWithFormat:@"%lld",sample.offset];
            NSString *value = [NSString stringWithFormat:@"%f",pts];
            [self.positionAndPts setObject:value forKey:key];
        }
    }
    int fps = ceil(1 / (mov->mov.mvhd.duration * 1.0 / (trackCount  * mov->mov.mvhd.timescale)));
    return fps;
}


@end

//
//  ALTEnum.h
//  ALTSDK
//
//  Created by Alienchang on 2019/3/13.
//  Copyright © 2019年 Alienchang. All rights reserved.
//

#ifndef ALTEnum_h
#define ALTEnum_h

/// 视频清晰度选择
typedef NS_ENUM(NSInteger, ALT_ENUM_VIDEO_QUALITY) {
    PLAY_QUALITY_AUTO     = 0,          // 自适应
    PLAY_QUALITY_360_640  = 1,
    PLAY_QUALITY_540_960  = 2,
    PLAY_QUALITY_720_1280 = 3,
};

typedef NS_ENUM(NSInteger, ALT_ENUM_PLAYEVENT) {
    PLAY_EVENT_VIDEO_FIRST_FRAME_RENDERED = 4,       // 视频第一帧已渲染
    PLAY_EVENT_PREPARED_TO_PLAY_CHANGE = 5,          // 准备播放状态变更
    PLAY_EVENT_STATUS_CHANGE = 7,                    // 播放状态变更
    PLAY_EVENT_LOAD_STATUS_CHANGE = 8,               // 加载状态变更
    PLAY_EVENT_AIRPLAY_VIDEO_ACTIVE_DIDCHANGE = 9,   // airPlay激活状态变更
    PLAY_EVENT_VIDEO_DECODER_OPEN = 10,              // 视频解码器打开
    PLAY_EVENT_AUDIO_FIRST_FRAME_RENDERED = 11,      // 音频第一帧已渲染
    PLAY_EVENT_AUDIO_FIRST_FRAME_DECODED = 12,       // 音频第一帧解码
    PLAY_EVENT_VIDEO_FIRST_FRAME_DECODED = 13,       // 视频第一帧解码
    PLAY_EVENT_PLAYER_OPEN_INPUT = 14,               // 播放器打开输入管道
    PLAY_EVENT_FIND_STREAM_INFO = 15,                // 查找流信息
    PLAY_EVENT_PLAYER_COMPONENT_OPEN = 16,           // 播放组件打开
    PLAY_EVENT_DID_SEEK_COMPLETE = 17,               // 定位播放点完成
    PLAY_EVENT_VIDEO_READYTOPLAY = 18,               // 准备播放
    PLAY_EVENT_VIDEO_PLAYER_ERROR = 19,              // 准备播放
    PLAY_EVENT_VIDEO_PLAY_FINISHED = 20              // 播放结束
};

/// 当前播放器状态
typedef NS_ENUM(NSInteger, ALT_ENUM_PLAYER_STATUS) {
    ALT_ENUM_PLAYER_UNKNOW     = 0,          
    ALT_ENUM_PLAYER_PLAYING    = 1,
    ALT_ENUM_PLAYER_PAUSE      = 2,
    ALT_ENUM_PLAYER_FINISHED   = 3,
};


#endif /* ALTEnum_h */

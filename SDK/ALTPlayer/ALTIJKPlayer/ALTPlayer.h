//
//  ALTPlayer.h
//  ALTSDK
//
//  Created by Alienchang on 2019/3/13.
//  Copyright © 2019年 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ALTEnum.h"
#import "ALTListener.h"
#import "ALTPlayConfig.h"

NS_ASSUME_NONNULL_BEGIN


@interface ALTPlayer : NSObject
/// 视频播放回调事件
@property (nonatomic ,weak) id  <ALTPlayerDelegate> delegate;
/// 交互视频播放事件回调
@property (nonatomic ,weak) id  <ALTPlayerInteractiveDelegate> interactiveDelegate;
/// 视频播放配置
@property (nonatomic ,strong)   ALTPlayConfig *playConfig;
/// 视频清晰度设置，支持动态改变视频清晰度，根据业务获取不同的视频url
@property (nonatomic ,assign)   ALT_ENUM_VIDEO_QUALITY videoQuality;
/// 是否启用默认基本UI
@property (nonatomic ,assign)   BOOL enableBaseUI;
/// 是否开启SDK根据交互视频自动控制，如果不开启，则可以自己通过ALTPlayerInteractiveDelegate去实现功能（默认开启）
@property (nonatomic ,assign)   BOOL enableInteractiveEventControl;
/// 当前播放的内容
@property (nonatomic ,readonly) NSString *currentSourceUrl;
/// 是否循环播放，默认否
@property (nonatomic ,assign)   BOOL loop;
/// 当前视频时长
@property (nonatomic ,readonly) NSTimeInterval duration;
/// 播放器播放状态
@property (nonatomic ,readonly) ALT_ENUM_PLAYER_STATUS playerStatus;
/// 初始化，需要显示的位置与载体view
- (instancetype)initWithFrame:(CGRect)frame
                  containView:(UIView *)containView;

/// 播放视频，url可以是本地和网络地址
- (void)playWithUrl:(NSString *)url
       videoQuality:(ALT_ENUM_VIDEO_QUALITY)videoQuality;

/// 播放互动视频，配置文件以及资源路径，需要等待资源与配置下载完成后才能播放
- (void)playWithVideoUrl:(NSString *)videoUrl
               configUrl:(NSString *)configUrl
             resourceUrl:(NSString *)resourceUrl
       videoQuality:(ALT_ENUM_VIDEO_QUALITY)videoQuality;

/// 播放互动视频，只加载部分资源与配置文件，根据配置文件需求延迟加载所需配置文件与资源，网络波动情况下可能会造成播放中缺少资源而停止播放，加载资源以后再继续播放
- (void)asyncPlayWithVideoUrl:(NSString *)videoUrl
                    configUrl:(NSString *)configUrl
                  resourceUrl:(NSString *)resourceUrl
                 videoQuality:(ALT_ENUM_VIDEO_QUALITY)videoQuality;

/// 停止播放
- (void)stop;
/// 暂停播放
- (void)pause;
/// 恢复播放
- (void)resume;
/// 设置静音
- (void)setMute:(BOOL)mute;
/// 跳转
- (void)seek:(NSTimeInterval)time;
/// 根据时间预览某一帧
- (UIImage *)preivewFrameAt:(CGFloat)time;
/// 异步获取截图
- (void)previewFrameAtTimes:(NSArray <NSNumber *>*)times
                   callBack:(void(^)(NSArray <UIImage *>* images))callBack;
/// 播放速率 0.5 - 2 ，超出范围按照极值计算
- (void)setRate:(CGFloat)rate;
/// 预加载，必须是网络资源
- (void)preload:(NSString *)url;
- (void)preloadVideoUrl:(NSString *)videoUrl
              configUrl:(NSString *)configUrl
            resourceUrl:(NSString *)resourceUrl
           videoQuality:(ALT_ENUM_VIDEO_QUALITY)videoQuality;
@end

NS_ASSUME_NONNULL_END

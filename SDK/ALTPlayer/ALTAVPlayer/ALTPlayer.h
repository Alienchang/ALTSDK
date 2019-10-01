//
//  ALTPlayer.h
//  ALTSDK
//
//  Created by Alienchang on 2019/3/18.
//  Copyright © 2019年 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALTEnum.h"
#import "ALTListener.h"

typedef enum : NSUInteger {
    ALTVideoGravityResizeAspect,
    ALTVideoGravityResizeAspectFill,
    ALTVideoGravityResize,
} ALTVideoFillMode;

NS_ASSUME_NONNULL_BEGIN

@interface ALTPlayer : NSObject
/// 视频播放回调事件
@property (nonatomic ,weak) id  <ALTPlayerDelegate> delegate;
/// 交互视频播放事件回调
@property (nonatomic ,weak) id  <ALTPlayerInteractiveDelegate> interactiveDelegate;
/// 是否启用默认基本UI
@property (nonatomic ,assign)   BOOL enableBaseUI;
/// 当前播放的内容
@property (nonatomic ,readonly) NSString *currentSourceUrl;
/// 是否循环播放，默认否
@property (nonatomic ,assign)   BOOL loop;
/// 当前视频时长
@property (nonatomic ,readonly) NSTimeInterval duration;
/// 当前播放时长
@property (nonatomic ,readonly) NSTimeInterval currentTime;
/// 播放器播放状态
@property (nonatomic ,readonly) ALT_ENUM_PLAYER_STATUS playerStatus;
/// 播放速率 0.5 - 2 ，超出范围按照极值计算 （iOS系统只支持这个区间）
@property (nonatomic ,assign)   float rate;
/// 当前播放视频的fps
@property (nonatomic ,readonly) int currentFps;

@property (nonatomic ,readonly) float currentCacheProgress;
/// 当前正在进行的preload的尾部偏移量
@property (nonatomic ,readonly) long long currentPreloadOffset;

/// 初始化，需要显示的位置与载体view
- (instancetype)initWithFrame:(CGRect)frame
                  containView:(UIView *)containView;
/// 设置播放器窗口frame
- (void)setPlayerFrame:(CGRect)frame;
/// 在某一时间段循环播放，调用本方法后loop属性会被置为YES，取消字节设置loop为NO
- (void)loopInBegin:(NSTimeInterval)begin
                end:(NSTimeInterval)end;
/// 播放视频，url可以是本地和网络地址
- (void)playWithUrl:(NSURL *)url;
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
- (void)seekAtOffset:(long long)offset;
/// 获取当前截图
- (UIImage *)videoShort;
/// 预加载，必须是网络资源，size是需要加载的大小
- (void)preload:(NSString *)url
       loadSize:(unsigned long long)size;
// 预加载，按照偏移量预加载
- (void)preloadAtOffset:(long long)offset
               loadSize:(long long )size;
- (void)preload:(NSString *)url
    startOffset:(unsigned long long)startOffset
       loadSize:(unsigned long long)size;
/// 视频填充方式
- (void)setContentMode:(ALTVideoFillMode)contentMode;
/// 缓存相关
+ (void)setupCache;
+ (unsigned long long)calculateCachedSizeWithError:(NSError **)error;
+ (NSArray <NSArray *>*)cachedFiles;
+ (NSArray <NSArray *>*)cachedUrls;
+ (void)cleanAllCacheWithError:(NSError **)error;
+ (void)cleanCacheForURL:(NSURL *)url error:(NSError **)error;
+ (NSString *)cachePathWithUrlString:(NSString *)urlString;
- (void)reset;
@end

NS_ASSUME_NONNULL_END

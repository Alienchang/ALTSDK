//
//  ALTControllerListener.h
//  ALTSDK
//
//  Created by Alienchang on 2019/3/22.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#ifndef ALTControllerListener_h
#define ALTControllerListener_h

#import <UIKit/UIKit.h>
#import "ALTEnum.h"
#import "ALTEventConst.h"

/// 正常播放视频写有
@protocol ALTPlayerControllerDelegate <NSObject>
@optional
/// 播放事件回调，error信息可能有网络、鉴权、url不正确等等。。
- (void)playEvent:(ALT_ENUM_PLAYEVENT)event
            error:(NSError *)error;

/**
 播放进度回调
 
 @param progress 进度（百分比）
 @param currentTime 当前进度（时间）
 */
- (void)playProgress:(float)progress
         currentTime:(NSTimeInterval)currentTime;
/**
 视频缓存进度
 */
- (void)cacheProgress:(float)progress;

/**
 缓存结束
 */
- (void)cacheFinished;


/**
 event 执行
 */
- (void)interactiveEvent:(ALTEventType)event
               paramater:(NSDictionary *)paramater
                   error:(NSError *)error;
@end



#endif /* ALTControllerListener_h */

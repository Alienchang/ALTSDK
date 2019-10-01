//
//  ALTEventTrigger.h
//  ALTSDK
//
//  Created by Alienchang on 2019/3/29.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALTProjectDataSource.h"
NS_ASSUME_NONNULL_BEGIN

@interface ALTEventTrigger : NSObject
- (instancetype)initWithProjectDataSource:(ALTProjectDataSource *)projectDataSource;
/**
 根据时间触发事件

 @param time 视频播放时间
 */
- (void)callEventWithTime:(NSTimeInterval)time;
- (void)callEventWithTime:(NSTimeInterval)time
               eventBlock:(nullable void(^)(ALTEventType eventType ,NSDictionary *paramater))eventBlock;
- (void)callEventWhenFinished;

@end

NS_ASSUME_NONNULL_END

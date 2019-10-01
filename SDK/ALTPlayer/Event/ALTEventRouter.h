//
//  ALTEventRoute.h
//  ALTSDK
//
//  Created by Alienchang on 2019/3/28.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALTPlayer.h"
#import "ConfigParser/ALTEventItem.h"
#import "ALTVideoEvent.h"
#import "ALTProjectDataSource.h"
#import "ALTEventConst.h"
NS_ASSUME_NONNULL_BEGIN

@interface ALTEventRouter : NSObject

/**
 根据eventType执行方法，多用于jsBridge

 @param object 自定义参数
 */
+ (void)executeEventWithEventType:(ALTEventType)eventType
                           object:(NSDictionary *)object;
+ (void)executeEventWithEventTypeString:(NSString *)eventTypeString
                                 object:(NSDictionary *)object;
/**
 执行事件方法
 */
+ (BOOL)executeEvent:(ALTEventItem *)event;

/**
 执行事件方法

 @param object 自定义参数
 */
+ (BOOL)executeEvent:(ALTEventItem *)event
              object:(NSDictionary *)object;


/**
 根据时间id执行事件
 */
+ (void)executeEventWithEventId:(NSString *)eventId
              projectDataSource:(ALTProjectDataSource *)projectDataSource;

/**
 执行事件组
 */
+ (BOOL)executeVideoEventsWith:(ALTVideoEvent *)videoEvent
                withDataSource:(ALTProjectDataSource *)dataSource;
+ (BOOL)executeVideoEventsWith:(ALTVideoEvent *)videoEvent
                withDataSource:(ALTProjectDataSource *)dataSource
                    eventBlock:(nullable void(^)(ALTEventType eventType ,NSDictionary *paramater))eventBlock;
+ (void)executeEventWithEventId:(NSString *)eventId
              projectDataSource:(ALTProjectDataSource *)projectDataSource
                     eventBlock:(nullable void(^)(ALTEventType eventType ,NSDictionary *paramater))eventBlock;
@end

NS_ASSUME_NONNULL_END

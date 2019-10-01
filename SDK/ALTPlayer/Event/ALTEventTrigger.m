//
//  ALTEventTrigger.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/29.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "ALTEventTrigger.h"
#import "ConfigParser/ALTConfigParser.h"
#import "ALTEventRouter.h"
#import "ALTParserUtil.h"
@interface ALTEventTrigger()
@property (nonatomic ,weak) ALTProjectDataSource *projectDataSource;
@property (nonatomic ,strong) ALTEventRouter *eventRouter;
@property (nonatomic ,copy)   NSString *currentVideoId;
@property (nonatomic ,strong) dispatch_queue_t eventExcuteQueue;
@end

@implementation ALTEventTrigger

- (instancetype)initWithProjectDataSource:(ALTProjectDataSource *)projectDataSource {
    self = [super init];
    if (self) {
        [self setProjectDataSource:projectDataSource];
    }
    return self;
}
- (void)callEventWithTime:(NSTimeInterval)time
               eventBlock:(nullable void(^)(ALTEventType eventType ,NSDictionary *paramater))eventBlock {
    dispatch_async(self.eventExcuteQueue, ^{
        if ([self.projectDataSource haveNextEvent]) {
            ALTVideoEvent *videoEvent = [self.projectDataSource currentEvent];
            
            // 当前分支视频在ivf文件中的偏移时间
            NSTimeInterval videoOffsetTime = self.projectDataSource.currentVideoResource.offsetTime;
            if (!videoEvent) {
                return;
            }
            while ((time > videoEvent.endTime + videoOffsetTime && time > videoEvent.startTime + videoOffsetTime && videoEvent.endTime != 0)) {
                [self.projectDataSource nextEvent];
                videoEvent = [self.projectDataSource currentEvent];
            }
            
            // 如果分支播放结束，执行结束事件
            if (time >= self.projectDataSource.currentVideoResource.duration + videoOffsetTime && videoEvent.startTime == MAXFLOAT) {
                NSLog(@"结束事件");
                [self.projectDataSource nextEvent];
                [ALTEventRouter executeVideoEventsWith:videoEvent withDataSource:self.projectDataSource eventBlock:eventBlock];
            }
            // 如果当前播放进度的时间已经>=事件执行时间，则执行事件
            else if (time > (videoEvent.startTime + videoOffsetTime) && (time < (videoEvent.endTime + videoOffsetTime) || videoEvent.endTime == 0)) {
                [self.projectDataSource nextEvent];
                [ALTEventRouter executeVideoEventsWith:videoEvent withDataSource:self.projectDataSource eventBlock:eventBlock];
            }
        }
    });
}
- (void)callEventWithTime:(NSTimeInterval)time {
    [self callEventWithTime:time eventBlock:nil];
}

- (void)callEventWhenFinished {
    dispatch_async(self.eventExcuteQueue, ^{
        if ([self.projectDataSource haveNextEvent]) {
            ALTVideoEvent *videoEvent = [self.projectDataSource currentEvent];
            if (videoEvent.eventGroup.count && [videoEvent.triggerStart isEqualToString:@"end"]) {
                for (NSString *eventItemId in videoEvent.eventGroup) {
                    [ALTEventRouter executeEventWithEventId:eventItemId projectDataSource:self.projectDataSource];
                }
            }
        }
    });
}

#pragma mark -- getter
- (dispatch_queue_t)eventExcuteQueue {
    if (!_eventExcuteQueue) {
        _eventExcuteQueue = dispatch_queue_create("com.event.execute.queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return _eventExcuteQueue;
}
@end

//
//  ALTProjectDataSource.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/29.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "ALTProjectDataSource.h"
#import "ALTVideo.h"
@interface ALTProjectDataSource()
@property (nonatomic ,assign) int currentEventIndex;
@property (nonatomic ,copy)   NSString *videoId;
@end
@implementation ALTProjectDataSource

- (ALTVideoEvent *)currentEvent {
    ALTVideo *video = self.videosDictionary[self.videoId];
//    ALTVideo *video = self.videosDictionary[@"1002"];
    if (video.videoEvents.count > self.currentEventIndex) {
        ALTVideoEvent *videoEvent = video.videoEvents[self.currentEventIndex];
        return videoEvent;
    } else {
        return nil;
    }
}
- (void)nextEvent {
    self.currentEventIndex ++;
}
- (BOOL)haveNextEvent {
    ALTVideo *video = self.videosDictionary[self.videoId];
    if (video.videoEvents.count > 0) {
        return YES;
    } else {
        return NO;
    }
}
- (void)resetEventExcute {
    
}

- (void)checkVideoBranch:(NSString *)videoId {
    [self setCurrentEventIndex:0];
    [self setVideoId:videoId];
}

- (ALTVideoEvent *)eventWithEventId:(NSString *)eventId {
    ALTVideoEvent *event = self.eventsDictionary[eventId];
    return event;
}

- (ALTEventItem *)eventItemWithItemId:(NSString *)itemId {
    ALTEventItem *item = self.eventsDictionary[itemId];
    return item;
}

- (ALTVideoResource *)startVideoResource {
    ALTVideoResource *videoSource = self.videoSourceDictionary[self.project.startVideoId];
    return videoSource;
}

- (NSMutableDictionary *)positionAndPts {
    if (!_positionAndPts) {
        _positionAndPts = [NSMutableDictionary new];
    }
    return _positionAndPts;
}

- (ALTVideoResource *)currentVideoResource {
    return self.videoSourceDictionary[self.videoId];
}
@end

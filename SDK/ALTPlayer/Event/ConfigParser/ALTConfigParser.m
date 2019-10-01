//
//  ALTConfigParser.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/28.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "ALTConfigParser.h"
#import <YYModel/YYModel.h>
#import "ALTProject.h"
#import "ALTVideoEvent.h"
#import "ALTVideo.h"
#import "ALTParserUtil.h"
#import "ALTVar.h"
#import "ALTComponentItem.h"
#import "ALTVideoResource.h"
#import "ALTImageSource.h"
@implementation ALTConfigParser
+ (ALTProjectDataSource *)parseConfigWithData:(NSData *)data fps:(int)fps {
    // 临时是ivf
    BOOL isIvf = NO;
    ALTProjectDataSource *dataSource = [ALTProjectDataSource new];
    NSError *error = nil;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (jsonDictionary[@"json"]) {
        jsonDictionary = jsonDictionary[@"json"];
    }
    /// Project
    ALTProject *project = [ALTProject yy_modelWithJSON:jsonDictionary[@"project"]];
    [dataSource setProject:project];
    [dataSource checkVideoBranch:project.startVideoId];
    if (!fps && project.fps) {
        fps = project.fps;
    }
    /// Videos
    NSMutableDictionary *videoItemDictionary = [NSMutableDictionary new];
    NSDictionary *videosDictionarhy = jsonDictionary[@"video"];
    for (NSString *videoKey in videosDictionarhy.allKeys) {
        ALTVideo *video = [ALTVideo new];
        [video setVideoId:videoKey];
        NSMutableArray <ALTVideoEvent*>*videoEvents = [NSMutableArray new];
        for (NSDictionary *videoEventDictionary in videosDictionarhy[videoKey]) {
            ALTVideoEvent *videoEvent = [ALTVideoEvent yy_modelWithJSON:videoEventDictionary];
            
            if (videoEvent.triggerStart.length < 8 && ![videoEvent.triggerStart isEqualToString:@"start"] && ![videoEvent.triggerStart isEqualToString:@"end"]) {
                continue;
            }
            if (isIvf) {
                // 明天写
            } else {
                /// 按照事件开始事件排序，从小到大
                if ([videoEvent.triggerStart isEqualToString:@"end"]) {
                    [videoEvent setStartTime:MAXFLOAT];
                    // 结束事件
                } else {
                    [videoEvent setStartTime:[ALTParserUtil timeWithFormatedTimeString:videoEvent.triggerStart fps:fps]];
                    [videoEvent setEndTime:[ALTParserUtil timeWithFormatedTimeString:videoEvent.triggerEnd fps:fps]];
                }
            }
            
            
            if (videoEvents.count) {
                for (int i = 0; i < videoEvents.count; ++i) {
                    if (i == videoEvents.count - 1) {
                        [videoEvents addObject:videoEvent];
                        break;
                    } else if (videoEvent.startTime > videoEvents[i].startTime && videoEvent.startTime < videoEvents[i + 1].startTime) {
                        [videoEvents insertObject:videoEvent atIndex:i + 1];
                        break;
                    } else if (i == 0 && videoEvent.startTime < videoEvents[i + 1].startTime) {
                        [videoEvents insertObject:videoEvent atIndex:0];
                        break;
                    }
                }
            } else {
                [videoEvents addObject:videoEvent];
            }
        }
        [video setVideoEvents:videoEvents];
        [videoItemDictionary setObject:video forKey:videoKey];
    }
    [dataSource setVideosDictionary:videoItemDictionary];
    
    /// Component
    NSDictionary *componentsDictionary = jsonDictionary[@"component"];
    NSMutableDictionary *componentItemsDictionary = [NSMutableDictionary new];
    for (NSString *componentKey in componentsDictionary.allKeys) {
        ALTComponentItem *componentItem = [ALTComponentItem yy_modelWithJSON:componentsDictionary[componentKey]];
        if (componentItem.duration == 0) {
            [componentItem setDuration:MAXFLOAT];
        }
        [componentItemsDictionary setValue:componentItem forKey:componentKey];
    }
    [dataSource setComponentsDictionary:componentItemsDictionary];
    
    /// Resource
    /// Video resource
    NSDictionary *videoResourceDictionary = jsonDictionary[@"resource"][@"video"];
    NSMutableDictionary *videoResourceItemDictionary = [NSMutableDictionary new];
    for (NSString *videoSourceKey in videoResourceDictionary.allKeys) {
        ALTVideoResource *videoSource = [ALTVideoResource new];
        NSDictionary *videoSourceDictionary = videoResourceDictionary[videoSourceKey];
        [videoSource setVideoId:videoSourceDictionary[@"from"][@"videoId"]];
        [videoSource setStart:videoSourceDictionary[@"from"][@"start"]];
        [videoSource setEnd:videoSourceDictionary[@"from"][@"end"]];
        [videoSource setIvfOffset:videoSourceDictionary[@"ivf"][@"offset"]];
        [videoSource setSize:videoSourceDictionary[@"ivf"][@"size"]];
        NSString *offsetTimeString = videoSourceDictionary[@"ivf"][@"offsetTime"];
        NSTimeInterval offsetTime = [ALTParserUtil timeWithFormatedTimeString:offsetTimeString];
        [videoSource setOffsetTime:offsetTime];
        if ([videoSourceDictionary[@"bitrate"] isKindOfClass:[NSDictionary class]]) {
            [videoSource setFast:videoSourceDictionary[@"bitrate"][@"fast"]];
            [videoSource setSd:videoSourceDictionary[@"bitrate"][@"sd"]];
            [videoSource setHd:videoSourceDictionary[@"bitrate"][@"hd"]];
            [videoSource setSuperHd:videoSourceDictionary[@"bitrate"][@"super"]];
            [videoSource setBr:videoSourceDictionary[@"bitrate"][@"br"]];
            [videoResourceItemDictionary setObject:videoSource forKey:videoSourceKey];
        }
        // 计算视频时长
        if (videoSource.start && videoSource.end) {
            videoSource.duration = [ALTParserUtil timeWithFormatedTimeString:videoSource.end] - [ALTParserUtil timeWithFormatedTimeString:videoSource.start];
        }
    }
    [dataSource setVideoSourceDictionary:videoResourceItemDictionary];
    
    /// Event
    NSDictionary *eventsDictionary = jsonDictionary[@"event"];
    NSMutableDictionary *eventItemDictionary = [NSMutableDictionary new];
    int loopSign = 0;
    for (NSString *eventKey in eventsDictionary.allKeys) {
        ALTEventItem *eventItem = [ALTEventItem yy_modelWithJSON:eventsDictionary[eventKey]];
        [eventItem setEventId:eventKey];
        [eventItemDictionary setObject:eventItem forKey:eventKey];
    }
    [dataSource setEventsDictionary:eventItemDictionary];
    
    /// 创建虚拟预加载视频event以及eventItem
    for (ALTEventItem *eventItem in eventItemDictionary.allValues) {
        if ([eventItem.type isEqualToString:kVideoPlay]) {
            ++ loopSign;
            // 如果是视频分支播放事件，倒叙查找出事件触发事件，模拟出一个视频预加载的ALTVideoEvent，一般分支事件会在component的事件中触发，所以遍历component
            for (ALTComponentItem *componentItem in dataSource.componentsDictionary.allValues) {
                if ([componentItem.eventGroup containsObject:eventItem.eventId]) {
                    ALTVideo *video = dataSource.videosDictionary[dataSource.project.startVideoId];
                    NSMutableArray *mainBranchEvents = video.videoEvents;
                    for (ALTVideoEvent *videoEvent in [mainBranchEvents copy]) {
                        for (NSString *eventItemId in videoEvent.eventGroup) {
                            ALTEventItem *tempEventItem = [dataSource eventItemWithItemId:eventItemId];
                            NSArray *uiIdGroup = tempEventItem.argMap[@"uiIdGroup"];
                            if ([uiIdGroup containsObject:componentItem.buttonId]) {
                                // 找到UI_Show事件时间
                                // 创建视频预加载虚拟事件
                                ALTVideoEvent *videoPreloadEvent = [ALTVideoEvent new];
                                NSString *eventItemId = [NSString stringWithFormat:@"videoPreload_%d",loopSign];
                                [videoPreloadEvent setEventGroup:@[eventItemId]];
                                [videoPreloadEvent setStartTime:videoEvent.startTime - 3];
                                [videoPreloadEvent setEndTime:videoEvent.startTime];
                                for (int i = (int)[mainBranchEvents indexOfObject:videoEvent]; i >= 0; -- i) {
                                    ALTVideoEvent *tempVideoEvent = mainBranchEvents[i];
                                    if (videoPreloadEvent.startTime < tempVideoEvent.startTime) {
                                        [video.videoEvents insertObject:videoPreloadEvent atIndex:i];
                                        // 创建虚拟eventItem
                                        ALTEventItem *preloadEventItem = [ALTEventItem new];
                                        [preloadEventItem setType:kVideoPreload];
                                        [preloadEventItem setEventId:eventItemId];
                                        ALTVideoResource *videoResource = dataSource.videoSourceDictionary[eventItem.argMap[@"videoId"]];
                                        NSMutableDictionary *argMap = [NSMutableDictionary new];
                                        videoResource.fast?argMap[@"fast"] = videoResource.fast:nil;
                                        videoResource.sd?argMap[@"sd"] = videoResource.sd:nil;
                                        videoResource.hd?argMap[@"hd"] = videoResource.hd:nil;
                                        videoResource.superHd?argMap[@"superHd"] = videoResource.superHd:nil;
                                        videoResource.br?argMap[@"br"] = videoResource.br:nil;
                                        videoResource.ivfOffset?argMap[@"ivfOffset"] = videoResource.ivfOffset:nil;
                                        videoResource.size?argMap[@"size"] = videoResource.size:nil;
                                
                                        [preloadEventItem setArgMap:argMap];
                                        [dataSource.eventsDictionary setValue:preloadEventItem forKey:preloadEventItem.eventId];
                                        break;
                                    } else if (i == 0) {
                                        [video.videoEvents insertObject:videoPreloadEvent atIndex:0];
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// Variable
    NSMutableDictionary *varImtesDictionary = [NSMutableDictionary new];
    NSDictionary *varsDictionary = jsonDictionary[@"variable"];
    for (NSString *varKey in varsDictionary.allKeys) {
        ALTVar *var = [ALTVar yy_modelWithJSON:varsDictionary[varKey]];
        [var setVarId:varKey];
        [varImtesDictionary setObject:var forKey:varKey];
    }
    [dataSource setVarsDictionary:varImtesDictionary];
   
    
    return dataSource;
    /// Image resource
    //    NSDictionary *imageResourceDictionary = jsonDictionary[@"resource"][@"image"];
    //    for (NSString *imageSourceKey in imageResourceDictionary.allKeys) {
    //        ALTImageSource *imageSource = [ALTImageSource new];
    //
    //    }
    
}

+ (ALTProjectDataSource *)parseConfigWithPath:(NSString *)path {
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    return [self parseConfigWithData:jsonData fps:0];
}


/**
 把配置文件给的事件触发事件转换为timeInterval
 */
+ (NSTimeInterval)timeIntervalWithFormatedTime:(NSString *)timeString {
    int fps = 25;   // 配置文件提供
    NSTimeInterval timeInterval = 0.;
    long hours   = [[timeString substringToIndex:1] integerValue] * 3600;
    long minutes = [[timeString substringWithRange:NSMakeRange(3, 2)] integerValue] * 60;
    long seconds = [[timeString substringWithRange:NSMakeRange(6, 2)] integerValue];
    if ([timeString containsString:@"#"]) {
        long frame   = [[timeString substringWithRange:NSMakeRange(9, 2)] integerValue];
        NSTimeInterval frameTime = (float)frame / fps;
        timeInterval = frameTime + seconds + minutes + hours;
    } else {
        long millisecond = [[timeString substringWithRange:NSMakeRange(6, 2)] integerValue];
        timeInterval = millisecond + seconds + minutes + hours;
    }
    return timeInterval;
}
@end

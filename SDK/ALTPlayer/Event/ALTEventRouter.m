//
//  ALTEventRoute.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/28.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "ALTEventRouter.h"
#import <MGJRouter/MGJRouter.h>
#import "ConfigParser/ALTEventConst.h"
#import "ALTEventItem.h"
#import "ALTParserUtil.h"

@interface ALTEventRouter()
@property (nonatomic ,strong) NSDictionary *events;
@property (nonatomic ,strong) NSMutableArray <NSNumber *>*eventIds;
@end

@implementation ALTEventRouter

/**
 全局注册事件
 */
+ (void)load {
    [MGJRouter registerURLPattern:kALTSwitchBranck toHandler:^(NSDictionary *routerParameters) {
        ALTPlayer *player = routerParameters[@"player"];
        NSURL *url = routerParameters[@"url"];
        [player playWithUrl:url];
    }];
    
    [MGJRouter registerURLPattern:kALTVideoSeek toHandler:^(NSDictionary *routerParameters) {
        ALTPlayer *player = routerParameters[@"player"];
        NSTimeInterval time = [routerParameters[@"time"] doubleValue];
        [player seek:time];
    }];
    
    [MGJRouter registerURLPattern:kALTButtonHide toHandler:^(NSDictionary *routerParameters) {
        UIButton *button = routerParameters[@"button"];
        [button setHidden:YES];
    }];
    
    [MGJRouter registerURLPattern:kALTButtonShow toHandler:^(NSDictionary *routerParameters) {
        UIButton *button = routerParameters[@"button"];
        [button setHidden:NO];
    }];
}

+ (BOOL)executeEvent:(ALTEventItem *)event {
    return [self executeEvent:event object:@{}];
}

+ (BOOL)executeEvent:(ALTEventItem *)event
              object:(NSDictionary *)object {
    
    NSString *schemeUrl = [self schemeUrlWithEventType:event.type];
    [MGJRouter openURL:schemeUrl withUserInfo:object completion:^(id result) {
        
    }];
    return YES;
}

+ (void)executeEventWithEventType:(ALTEventType)eventType
                           object:(NSDictionary *)object {
    
}

+ (void)executeEventWithEventTypeString:(NSString *)eventTypeString
                                 object:(NSDictionary *)object {
    [self executeEventWithEventType:eventTypeString object:object];
}

+ (void)executeEventItem:(ALTEventItem *)eventItem
          withDataSource:(ALTProjectDataSource *)dataSource
              eventBlock:(void(^)(ALTEventType eventType ,NSDictionary *paramater))eventBlock {
    if ([eventItem.type isEqualToString:kVideoPlay]) {
        NSString *videoId = eventItem.argMap[@"videoId"];
        [dataSource checkVideoBranch:videoId];
        NSString *time = eventItem.argMap[@"time"];
        NSString *volume = eventItem.argMap[@"volume"];
        
        NSMutableDictionary *userInfo = [NSMutableDictionary new];
        ALTVideoResource *videoResource = dataSource.videoSourceDictionary[videoId];
        
        NSString *ivfOffset = videoResource.ivfOffset;
        NSString *size = videoResource.size;
        if (![videoResource.br isKindOfClass:[NSNull class]]) {
            userInfo[@"videoUrl"] = videoResource.br;
        }
        if (![time isKindOfClass:[NSNull class]]) {
            userInfo[@"startTime"] = time;
        }
        if (![volume isKindOfClass:[NSNull class]]) {
            userInfo[@"volume"] = volume;
        }
        if (![ivfOffset isKindOfClass:[NSNull class]]) {
            userInfo[@"ivfOffset"] = ivfOffset;
        }
        if (![size isKindOfClass:[NSNull class]]) {
            userInfo[@"size"] = size;
        }
        if (eventBlock) {
            eventBlock(kVideoPlay ,userInfo);
        }
    } else if ([eventItem.type isEqualToString:kVideoPause]) {
        if (eventBlock) {
            eventBlock(kVideoPause ,nil);
        }
    } else if ([eventItem.type isEqualToString:kVideoResume]) {
        if (eventBlock) {
            eventBlock(kVideoResume ,nil);
        }
    } else if ([eventItem.type isEqualToString:kVideoVolume]) {
        NSString *volume = eventItem.argMap[@"volume"];
        if (eventBlock) {
            eventBlock(kVideoResume ,@{@"volume":volume});
        }
    } else if ([eventItem.type isEqualToString:kVideoLoop]) {
        NSString *startTime = eventItem.argMap[@"startTime"];
        NSString *endTime = eventItem.argMap[@"endTime"];
        if (eventBlock) {
            eventBlock(kVideoResume ,@{@"startTime":startTime,
                @"endTime":endTime
            });
        }
    } else if ([eventItem.type isEqualToString:kAudioPlay]) {
        NSString *volume = eventItem.argMap[@"volume"]?eventItem.argMap[@"volume"]:@"1";
        NSString *endTime = eventItem.argMap[@"endTime"]?eventItem.argMap[@"endTime"]:@"0";
        NSString *loop = eventItem.argMap[@"loop"]?eventItem.argMap[@"loop"]:@"0";
        NSString *resume = eventItem.argMap[@"resume"]?eventItem.argMap[@"resume"]:@"0";
        NSString *audioId = eventItem.argMap[@"audioId"]?eventItem.argMap[@"audioId"]:@"0";
        if (eventBlock) {
            eventBlock(kAudioPlay ,@{@"volume":volume,
                                     @"endTime":endTime,
                                     @"loop":loop,
                                     @"resume":resume,
                                     @"audioId":audioId
                                     });
        }
    } else if ([eventItem.type isEqualToString:kAudioPause]) {
        if (eventBlock) {
            eventBlock(kAudioPause ,nil);
        }
    } else if ([eventItem.type isEqualToString:kAudioResume]) {
        if (eventBlock) {
            eventBlock(kVideoResume ,nil);
        }
    } else if ([eventItem.type isEqualToString:kAudioVolume]) {
        NSString *volume = eventItem.argMap[@"volume"];
        if (eventBlock) {
            eventBlock(kVideoResume ,@{@"volume":volume});
        }
    } else if ([eventItem.type isEqualToString:kUIShow]) {
        NSArray <NSString *>*uiIdGroup = eventItem.argMap[@"uiIdGroup"];
        for (NSString *uiId in uiIdGroup) {
            if (eventBlock) {
                eventBlock(kUIShow ,@{@"uiId":uiId});
            }
        }
    } else if ([eventItem.type isEqualToString:kUIHide]) {
        NSArray <NSString *>*uiIdGroup = eventItem.argMap[@"uiIdGroup"];
        if (eventBlock) {
            eventBlock(kUIHide ,@{@"uiIdGroup":uiIdGroup});
        }
    } else if ([eventItem.type isEqualToString:kUIStateChange]) {
        NSArray <NSString *>*uiIdGroup = eventItem.argMap[@"uiIdGroup"];
        NSString *state = eventItem.argMap[@"state"];
        if (eventBlock) {
            eventBlock(kUIStateChange ,@{@"uiIdGroup":uiIdGroup,
                                         @"state":state
                                         });
        }
    } else if ([eventItem.type isEqualToString:kWebOpen]) {
        NSString *url = eventItem.argMap[@"url"];
        if (eventBlock) {
            eventBlock(kWebOpen ,@{@"url":url});
        }
    } else if ([eventItem.type isEqualToString:kWebClose]) {
        if (eventBlock) {
            eventBlock(kWebClose ,nil);
        }
    } else if ([eventItem.type isEqualToString:kVarUpdate]) {
        if (eventBlock) {
            eventBlock(kVarUpdate ,nil);
        }
    } else if ([eventItem.type isEqualToString:kCondition]) {
        /// 解析condition
        NSString *conditionString  = eventItem.argMap[@"condition"];
        NSArray  <NSString *>*successEvents = eventItem.argMap[@"successEventGroup"];
        NSArray  <NSString *>*failEvents    = eventItem.argMap[@"failEvents"];
        if ([ALTParserUtil judgeWithCondition:conditionString projectDataSource:dataSource]) {
            for (NSString *eventId in successEvents) {
                [self executeEventWithEventId:eventId projectDataSource:dataSource];
            }
        } else {
            for (NSString *eventId in failEvents) {
                [self executeEventWithEventId:eventId projectDataSource:dataSource];
            }
        }
    } else if ([eventItem.type isEqualToString:kVideoPreload]) {
        if (eventBlock) {
            eventBlock(kVideoPreload ,eventItem.argMap);
        }
    }
}
+ (void)executeEventItem:(ALTEventItem *)eventItem
          withDataSource:(ALTProjectDataSource *)dataSource {
    [self executeEventItem:eventItem withDataSource:dataSource eventBlock:nil];
}

+ (BOOL)executeVideoEventsWith:(ALTVideoEvent *)videoEvent
                withDataSource:(ALTProjectDataSource *)dataSource {
    return [self executeVideoEventsWith:videoEvent withDataSource:dataSource eventBlock:nil];
}

+ (BOOL)executeVideoEventsWith:(ALTVideoEvent *)videoEvent
                withDataSource:(ALTProjectDataSource *)dataSource
                    eventBlock:(nullable void(^)(ALTEventType eventType ,NSDictionary *paramater))eventBlock {
    for (NSString *eventId in videoEvent.eventGroup) {
        ALTEventItem *eventItem = [dataSource eventItemWithItemId:eventId];
        [self executeEventItem:eventItem withDataSource:dataSource eventBlock:eventBlock];
    }
    return YES;
}

+ (void)executeEventWithEventId:(NSString *)eventId
              projectDataSource:(ALTProjectDataSource *)projectDataSource
                     eventBlock:(nullable void(^)(ALTEventType eventType ,NSDictionary *paramater))eventBlock {
    ALTEventItem *eventItem = [projectDataSource eventItemWithItemId:eventId];
    [self executeEventItem:eventItem withDataSource:projectDataSource eventBlock:eventBlock];
}
+ (void)executeEventWithEventId:(NSString *)eventId
              projectDataSource:(ALTProjectDataSource *)projectDataSource {
    ALTEventItem *eventItem = [projectDataSource eventItemWithItemId:eventId];
    [self executeEventItem:eventItem withDataSource:projectDataSource eventBlock:^(ALTEventType eventType, NSDictionary *paramater) {
        
    }];
}

#pragma mark -- private func
+ (NSString *)schemeUrlWithEventType:(ALTEventType)eventType {
    return nil;
}

@end

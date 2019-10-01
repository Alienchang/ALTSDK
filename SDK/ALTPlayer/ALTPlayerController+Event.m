//
//  ALTPlayerController+Event.m
//  ALTSDK
//
//  Created by Alienchang on 2019/4/8.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "ALTPlayerController+Event.h"
#import "ALTWebviewController.h"
#import "PlayerControl/ALTVideoControlView.h"
#import "ALTPlayer.h"
#import "ALTParserUtil.h"
#import "ALTComponentFactory.h"
#import "ALTSafeThread.h"
#import "NEAudioPlayer.h"
#import "ALTParserUtil.h"
#import "ALTVar.h"
@interface ALTPlayerController()
@property (nonatomic ,strong) ALTPlayer *player;
@property (nonatomic ,strong) UIView    *containView;
@property (nonatomic ,strong) ALTWebviewController *webviewController;
@property (nonatomic ,strong) ALTVideoControlView  *playerControl;
@property (nonatomic ,strong) NEAudioPlayer   *audioPlayer;
@property (nonatomic ,strong) ALTProjectDataSource *projectDataSource;

@end
@implementation ALTPlayerController (Event)
/**
 根据通知添加组件，key是组件id，value是组件，返回的组件是已经绘制完UI的
 */
- (void)addUIComponent:(NSNotification *)notification {
    NSDictionary *componentInfo = notification.userInfo;
    [ALTSafeThread safe_async_main:^{
        for (NSString *uiId in componentInfo.allValues) {
            UIControl *control = [ALTComponentFactory generateControlWithUIID:uiId projectDataSource:self.projectDataSource callBackController:self];
            [self.playerControl addUIComponentWithKey:uiId component:control];
        }
    }];
}

/**
 根据key移除组件
 */
- (void)removeUIComponent:(NSNotification *)notification {
    if ([notification.name isEqualToString:kUIHide]) {
        NSArray *componentKeys = notification.userInfo[@"uiIdGroup"];
        [ALTSafeThread safe_async_main:^{
            for (NSString *componentKey in componentKeys) {
                [self.playerControl removeUIComponentWithKey:componentKey];
            }
        }];
    }
}

#pragma mark -- public func
- (void)callEventWithType:(ALTEventType)eventType
                paramater:(NSDictionary *)parameter {
    if ([eventType isEqualToString:kVideoPreload]) {
        NSString *ivfOffset = parameter[@"ivfOffset"];
        NSString *size = parameter[@"size"];
        if (size.length && ivfOffset.length) {
            if (self.player.duration * (self.player.currentCacheProgress?self.player.currentCacheProgress:1) > (self.player.currentTime + 3)) {
                unsigned offset = 0;
                NSScanner *offsetCcanner = [NSScanner scannerWithString:ivfOffset];
                [offsetCcanner setScanLocation:0]; // bypass '#' character
                [offsetCcanner scanHexInt:&offset];
                
                unsigned videoSize = 0;
                NSScanner *sizeScanner = [NSScanner scannerWithString:size];
                [sizeScanner setScanLocation:0]; // bypass '#' character
                [sizeScanner scanHexInt:&videoSize];
                if (self.player.currentPreloadOffset <= offset) {
                    [self.player preload:self.player.currentSourceUrl startOffset:offset loadSize:videoSize];
                }
            }
        } else {
            NSString *hdUrl = parameter[@"hd"];
            if (hdUrl) {
                // 不影响主视频的情况下进行预加载
                if (self.player.duration * self.player.currentCacheProgress > (self.player.currentTime + 3)) {
                    [self.player preload:hdUrl loadSize:2 * 1024 * 1024];
                }
            }
        }
    } else if ([eventType isEqualToString:kVarUpdate]) {
        NSDictionary *argMap = parameter[@"argMap"];
        ALTVar *var = self.projectDataSource.varsDictionary[@"happy"];
        if ([var.type isEqualToString:@"number"]) {
            NSString *compute = argMap[@"compute"];
            int value = [argMap[@"value"] intValue];
            int varVale = var.value.intValue;
            if ([compute isEqualToString:@"+"]) {
                varVale += value;
            } else if ([compute isEqualToString:@"-"]) {
                varVale -= value;
            }
            var.value = [NSString stringWithFormat:@"%d",varVale];
        }
    } else if ([eventType isEqualToString:kUIStateChange]) {
        NSArray <NSString *>*uiIdGroup = parameter[@"uiIdGroup"];
        NSString *state = parameter[@"state"];
        [ALTSafeThread safe_async_main:^{
            for (NSString *uiId in uiIdGroup) {
                [self.playerControl updateUIComponentWithKey:uiId withState:state];
            }
        }];
    } else if ([eventType isEqualToString:kAudioVolume]) {
        NSString *volume = parameter[@"volume"];
        [self.audioPlayer setVolume:volume.floatValue];
    } else if ([eventType isEqualToString:kAudioPlay]) {
        NSString *volume = parameter[@"volume"];
        NSTimeInterval endTime = [ALTParserUtil timeWithFormatedTimeString:parameter[@"endTime"] fps:self.player.currentFps];
        BOOL loop = [parameter[@"loop"] boolValue];
        BOOL resume = [parameter[@"resume"] boolValue];
        NSString *audioId = parameter[@"audioId"];
        [ALTSafeThread safe_async_main:^{
            if (loop) {
                //                [self.player loopInBegin:0 end:endTime];
            } else {
                NSString *audioUrl = [self.projectDataSource.project.audioBaseUrl stringByAppendingString:audioId];
                [self playAudio:audioUrl];
            }
        }];
    } else if ([eventType isEqualToString:kVideoLoop]) {
        NSTimeInterval startTime = [ALTParserUtil timeWithFormatedTimeString:parameter[@"startTime"] fps:self.player.currentFps];
        NSTimeInterval endTime = [ALTParserUtil timeWithFormatedTimeString:parameter[@"endTime"] fps:self.player.currentFps];
        [ALTSafeThread safe_async_main:^{
            [self.player loopInBegin:startTime end:endTime];
        }];
    } else if ([eventType isEqualToString:kVideoVolume]) {
        NSString *volume = parameter[@"volume"];
        [ALTSafeThread safe_async_main:^{
            [self setVolume:volume.floatValue];
        }];
    } else if ([eventType isEqualToString:kWebOpen]) {
        NSString *url = parameter[@"url"];
        [ALTSafeThread safe_async_main:^{
            [self videoStop];
            [self audioStop];
            [self.webviewController showIn:self.containView];
            [self.webviewController requestWithUrl:url];
        }];
    } else if ([eventType isEqualToString:kVideoPlay]) {
        [self audioStop];
        NSString *videoUrl  = parameter[@"videoUrl"];
        NSString *startTime = parameter[@"startTime"];
        NSString *volume    = parameter[@"volume"];
        
        NSString *ivfOffset = parameter[@"ivfOffset"];
        NSString *size      = parameter[@"size"];
        
        [ALTSafeThread safe_async_main:^{
            if (ivfOffset.length && size.length) {
                unsigned result = 0;
                NSScanner *scanner = [NSScanner scannerWithString:ivfOffset];
                [scanner setScanLocation:0]; // bypass '#' character
                [scanner scanHexInt:&result];
                [self setVolume:volume.floatValue];
                
                NSString *ptsValue = self.projectDataSource.positionAndPts[[NSString stringWithFormat:@"%u",result]];
                float pts = ptsValue.floatValue;
                [self seek:pts];
            } else {
                NSString *tempVideoUrl = [ALTParserUtil videoUrlWithPath:videoUrl dataSource:self.projectDataSource];
                [self playWithUrl:tempVideoUrl callBack:^(ALT_ENUM_PLAYEVENT event) {
                    if (event == PLAY_EVENT_VIDEO_READYTOPLAY) {
                        [self seek:startTime.doubleValue];
                        [self setVolume:volume.floatValue];
                    }
                }];
            }
        }];
    } else if ([eventType isEqualToString:kUIShow]) {
        [ALTSafeThread safe_async_main:^{
            for (NSString *uiId in parameter.allValues) {
                UIControl *control = [ALTComponentFactory generateControlWithUIID:uiId projectDataSource:self.projectDataSource callBackController:self];
                [self.playerControl addUIComponentWithKey:uiId component:control];
            }
        }];
    } else if ([eventType isEqualToString:kVideoPause]) {
        [ALTSafeThread safe_async_main:^{
            [self audioPause];
            [self videoPause];
        }];
    }
    if ([self.delegate respondsToSelector:@selector(interactiveEvent:paramater:error:)]) {
        NSMutableDictionary *mutableParamater = [NSMutableDictionary new];
        [mutableParamater addEntriesFromDictionary:parameter];
        mutableParamater[@"currentTime"] = [NSString stringWithFormat:@"%lf",self.player.currentTime];
        [self.delegate interactiveEvent:eventType paramater:mutableParamater error:nil];
    }
}

- (void)seek:(NSTimeInterval)time {
    [self.player seek:time];
    [self.playerControl removeAllComponent];
}

@end

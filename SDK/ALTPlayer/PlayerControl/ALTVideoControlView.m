//
//  VideoControlView.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/21.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "ALTVideoControlView.h"
#import "UIImage+ALTSource.h"
#import "ALTButton.h"
#import "ALTComponentProtocol.h"
#import <MSWeakTimer.h>
@interface ALTVideoControlView()
@property (nonatomic ,strong) NSMutableDictionary *componentStoreDictionary;
@property (nonatomic ,strong) UIButton *playButton;
@property (nonatomic ,strong) MSWeakTimer *timer;
@end
@implementation ALTVideoControlView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.playButton];
        self.timer = [MSWeakTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(scheduledTimerAction) userInfo:nil repeats:YES dispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return self;
}



- (void)layout {
//    CGFloat width  = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    [self.playButton setFrame:CGRectMake(0, height - 10 - 24, 40, 40)];
    [self.playButton setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
}
#pragma mark -- getter
- (NSMutableDictionary *)componentStoreDictionary {
    if (!_componentStoreDictionary) {
        _componentStoreDictionary = [NSMutableDictionary new];
    }
    return _componentStoreDictionary;
}
- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton new];
        [_playButton addTarget:self action:@selector(playButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_playButton setImage:[UIImage alt_imageOfPauseIcon] forState:UIControlStateNormal];
    }
    return _playButton;
}
#pragma mark -- public func
- (void)show:(BOOL)show {
    [UIView animateWithDuration:0.25 animations:^{
        [self setAlpha:show];
    }];
}

- (void)addUIComponentWithKey:(NSString *)key
                    component:(UIControl *)component {
    if ([self.componentStoreDictionary valueForKey:key]) {
        return;
    } else {
        [self.componentStoreDictionary setObject:component forKey:key];
        [self addSubview:component];
    }
}

- (void)removeUIComponentWithKey:(NSString *)key {
    UIControl *control = [self.componentStoreDictionary valueForKey:key];
    [control removeFromSuperview];
    [self.componentStoreDictionary removeObjectForKey:key];
}

- (void)removeAllComponent {
    for (NSString *key in self.componentStoreDictionary.allKeys) {
        UIControl *control = self.componentStoreDictionary[key];
        [self.componentStoreDictionary removeObjectForKey:key];
        [control removeFromSuperview];
    }
}

- (void)updateUIComponentWithKey:(NSString *)key
                       withState:(NSString *)state {
    
}

#pragma mark -- private func
- (void)playButtonAction {
    [self setPlaying:!self.playing];
    if (self.playing) {
        [self.playButton setImage:[UIImage alt_imageOfPauseIcon] forState:UIControlStateNormal];
    } else {
        [self.playButton setImage:[UIImage alt_imageOfPlayIcon] forState:UIControlStateNormal];
    }
    if (self.playCallBack) {
        self.playCallBack(self.playing);
    }
}

- (void)scheduledTimerAction {
    for (NSString *key in self.componentStoreDictionary.allKeys) {
        UIControl <ALTComponentProtocol> *control = self.componentStoreDictionary[key];
        if ([control conformsToProtocol:@protocol(ALTComponentProtocol)]) {
            control.duration -= 1;
            if (control.duration < 0) {
                [self.componentStoreDictionary removeObjectForKey:key];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [control removeFromSuperview];
                    if ([self.delegate respondsToSelector:@selector(callEvent:dataSource:)]) {
                        for (NSString *eventId in control.componentItem.eventGroup) {
                            [self.delegate callEvent:eventId dataSource:control.projectDataSource];
                        }
                    }
                });
            }
        }
    }
}
- (void)dealloc {
    [self.timer invalidate];
}
@end

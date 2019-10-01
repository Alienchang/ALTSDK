//
//  VideoControlView.h
//  ALTSDK
//
//  Created by Alienchang on 2019/3/21.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALTEventConst.h"
#import "ALTProjectDataSource.h"
#import "ALTProjectDataSource.h"
NS_ASSUME_NONNULL_BEGIN

@protocol ALTVideoControlEvent <NSObject>
- (void)callEvent:(NSString *)eventId dataSource:(ALTProjectDataSource *)dataSource;
@end

@interface ALTVideoControlView : UIView
/// 是否正在播放
@property (nonatomic ,assign) BOOL playing;
/// 默认开启
@property (nonatomic ,assign) BOOL enableFullScreenTouch;
@property (nonatomic ,strong) void(^playCallBack)(BOOL play);
@property (nonatomic ,strong) void(^volumeChangeCallBack)(float volume);
@property (nonatomic ,strong) id <ALTVideoControlEvent>delegate;
- (void)layout;
- (void)show:(BOOL)show;
- (void)addUIComponentWithKey:(NSString *)key
                    component:(UIControl *)component;
- (void)removeUIComponentWithKey:(NSString *)key;
- (void)updateUIComponentWithKey:(NSString *)key
                       withState:(NSString *)state;
- (void)removeAllComponent;
@end

NS_ASSUME_NONNULL_END

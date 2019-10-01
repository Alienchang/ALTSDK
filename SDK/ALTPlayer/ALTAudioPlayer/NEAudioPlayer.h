//
//  NEAudioPlayer.h
//  Musicash
//
//  Created by Chang Liu on 10/25/18.
//  Copyright © 2018 Chang Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NEAudioPlayer : NSObject
@property (nonatomic ,assign) CGFloat   volume;
@property (nonatomic ,assign) NSInteger repeatCount;
@property (nonatomic ,readonly) BOOL    playing;

+ (instancetype)instanceWithUrl:(NSString *)stringUrl;
- (instancetype)initWithUrl:(NSString *)stringUrl;
- (void)play;
- (void)pause;
- (void)resume;
- (void)stop;
- (void)playWithUrl:(NSString *)url;
- (void)playFromTime:(NSTimeInterval)fromTime;
- (void)seekTo:(NSTimeInterval)toTime;
@end


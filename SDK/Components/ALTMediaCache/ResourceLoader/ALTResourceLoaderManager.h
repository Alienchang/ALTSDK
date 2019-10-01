//
//  ALTResourceLoaderManager.h
//  ALTSDK
//
//  Created by Alienchang on 2019/3/26.
//  Copyright © 2019年 Alienchang. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "ALTResourceLoader.h"

@import AVFoundation;
@protocol ALTResourceLoaderManagerDelegate;

@interface ALTResourceLoaderManager : NSObject <AVAssetResourceLoaderDelegate>
@property (nonatomic, assign) NSRange playRange;        // 播放区间，字节长度
@property (nonatomic, strong) NSMutableDictionary<id<NSCoding>, ALTResourceLoader *> *loaders;
@property (nonatomic, weak) id<ALTResourceLoaderManagerDelegate> delegate;
- (void)asyncLoadAt:(long long)startOffset size:(long long)size videourl:(NSString *)videoUrl;
/**
 Normally you no need to call this method to clean cache. Cache cleaned after AVPlayer delloc.
 If you have a singleton AVPlayer then you need call this method to clean cache at suitable time.
 */
- (void)cleanCache;

/**
 Cancel all downloading loaders.
 */
- (void)cancelLoaders;

- (ALTResourceLoader *)resourceLoaderWithVideoUrl:(NSString *)videoUrl;

@end

@protocol ALTResourceLoaderManagerDelegate <NSObject>
- (void)resourceLoaderManagerLoadData:(NSData *)data;
- (void)resourceLoaderManagerLoadURL:(NSURL *)url didFailWithError:(NSError *)error;


@end

@interface ALTResourceLoaderManager (Convenient)

+ (NSURL *)assetURLWithURL:(NSURL *)url;
- (AVPlayerItem *)playerItemWithURL:(NSURL *)url;

@end

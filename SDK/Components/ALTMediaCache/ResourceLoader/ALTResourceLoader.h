//
//  ALTResoureLoader.h
//  ALTSDK
//
//  Created by Alienchang on 2019/3/26.
//  Copyright © 2019年 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALTMediaCacheWorker.h"
#import "ALTMediaDownloader.h"

@import AVFoundation;
@protocol ALTResourceLoaderDelegate;

@interface ALTResourceLoader : NSObject
@property (nonatomic, strong) ALTMediaDownloader *mediaDownloader;
@property (nonatomic, strong) ALTMediaCacheWorker *cacheWorker;
@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, weak) id<ALTResourceLoaderDelegate> delegate;

- (instancetype)initWithURL:(NSURL *)url;

- (void)addRequest:(AVAssetResourceLoadingRequest *)request;
- (void)removeRequest:(AVAssetResourceLoadingRequest *)request;

- (void)cancel;
- (void)asyncLoadArobablyStart:(long long)startOffset size:(long long)size;
@end

@protocol ALTResourceLoaderDelegate <NSObject>
- (void)resourceLoaderData:(NSData *)data;
- (void)resourceLoader:(ALTResourceLoader *)resourceLoader didFailWithError:(NSError *)error;

@end

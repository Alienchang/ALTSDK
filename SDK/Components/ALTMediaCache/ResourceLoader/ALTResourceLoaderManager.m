//
//  ALTResourceLoaderManager.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/26.
//  Copyright © 2019年 Alienchang. All rights reserved.
//
#import "ALTResourceLoaderManager.h"

static NSString *kCacheScheme = @"__ALTMediaCache___:";

@interface ALTResourceLoaderManager () <ALTResourceLoaderDelegate>



@end

@implementation ALTResourceLoaderManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _loaders = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)cleanCache {
    [self.loaders removeAllObjects];
}

- (void)cancelLoaders {
    [self.loaders enumerateKeysAndObjectsUsingBlock:^(id<NSCoding>  _Nonnull key, ALTResourceLoader * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj cancel];
    }];
    [self.loaders removeAllObjects];
}

- (void)asyncLoadAt:(long long)startOffset size:(long long)size videourl:(NSString *)videoUrl {
    ALTResourceLoader *resourceLoader = [self resourceLoaderWithVideoUrl:videoUrl];
    [resourceLoader asyncLoadArobablyStart:startOffset size:size];
}
- (ALTResourceLoader *)resourceLoaderWithVideoUrl:(NSString *)videoUrl {
    NSString *key = nil;
    if(![videoUrl hasPrefix:kCacheScheme]){
        key = [NSString stringWithFormat:@"%@%@",kCacheScheme,videoUrl];
    } else {
        key = videoUrl;
    }
    ALTResourceLoader *resourceLoader = self.loaders[key];
    return resourceLoader;
}
#pragma mark - AVAssetResourceLoaderDelegate

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest  {
    NSURL *resourceURL = [loadingRequest.request URL];
    if ([resourceURL.absoluteString hasPrefix:kCacheScheme]) {
        ALTResourceLoader *loader = [self loaderForRequest:loadingRequest];
        if (!loader) {
            NSURL *originURL = nil;
            NSString *originStr = [resourceURL absoluteString];
            originStr = [originStr stringByReplacingOccurrencesOfString:kCacheScheme withString:@""];
            originURL = [NSURL URLWithString:originStr];
            loader = [[ALTResourceLoader alloc] initWithURL:originURL];
            loader.delegate = self;
            NSString *key = [self keyForResourceLoaderWithURL:resourceURL];
            self.loaders[key] = loader;
        }
        [loader addRequest:loadingRequest];
        return YES;
    }
    
    return NO;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    ALTResourceLoader *loader = [self loaderForRequest:loadingRequest];
    [loader removeRequest:loadingRequest];
}

#pragma mark - ALTResourceLoaderDelegate
- (void)resourceLoaderData:(NSData *)data {
    if ([self.delegate respondsToSelector:@selector(resourceLoaderManagerLoadData:)]) {
        [self.delegate resourceLoaderManagerLoadData:data];
    }
}
- (void)resourceLoader:(ALTResourceLoader *)resourceLoader didFailWithError:(NSError *)error {
    [resourceLoader cancel];
    if ([self.delegate respondsToSelector:@selector(resourceLoaderManagerLoadURL:didFailWithError:)]) {
        [self.delegate resourceLoaderManagerLoadURL:resourceLoader.url didFailWithError:error];
    }
}

#pragma mark - Helper
- (NSString *)keyForResourceLoaderWithURL:(NSURL *)requestURL {
    if([[requestURL absoluteString] hasPrefix:kCacheScheme]){
        NSString *s = requestURL.absoluteString;
        return s;
    } else {

    }
    return nil;
}

- (ALTResourceLoader *)loaderForRequest:(AVAssetResourceLoadingRequest *)request {
    NSString *requestKey = [self keyForResourceLoaderWithURL:request.request.URL];
    ALTResourceLoader *loader = self.loaders[requestKey];
    return loader;
}

@end

@implementation ALTResourceLoaderManager (Convenient)

+ (NSURL *)assetURLWithURL:(NSURL *)url {
    if (!url) {
        return nil;
    }

    NSURL *assetURL = [NSURL URLWithString:[kCacheScheme stringByAppendingString:[url absoluteString]]];
    return assetURL;
}

- (AVPlayerItem *)playerItemWithURL:(NSURL *)url {
    NSURL *assetURL = [ALTResourceLoaderManager assetURLWithURL:url];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    [urlAsset.resourceLoader setDelegate:self queue:dispatch_get_main_queue()];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:urlAsset];
    if ([playerItem respondsToSelector:@selector(setCanUseNetworkResourcesForLiveStreamingWhilePaused:)]) {
        playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = YES;
    }
    return playerItem;
}

@end

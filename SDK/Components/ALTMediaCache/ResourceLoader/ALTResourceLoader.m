//
//  ALTResoureLoader.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/26.
//  Copyright © 2019年 Alienchang. All rights reserved.
//

#import "ALTResourceLoader.h"
#import "ALTResourceLoadingRequestWorker.h"
#import "ALTContentInfo.h"

NSString * const MCResourceLoaderErrorDomain = @"LSFilePlayerResourceLoaderErrorDomain";

@interface ALTResourceLoader () <ALTResourceLoadingRequestWorkerDelegate>

@property (nonatomic, strong, readwrite) NSURL *url;

@property (nonatomic, strong) NSMutableArray<ALTResourceLoadingRequestWorker *> *pendingRequestWorkers;

@property (nonatomic, getter=isCancelled) BOOL cancelled;

@end

@implementation ALTResourceLoader


- (void)dealloc {
    [_mediaDownloader cancel];
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _url = url;
        _cacheWorker = [[ALTMediaCacheWorker alloc] initWithURL:url];
        _mediaDownloader = [[ALTMediaDownloader alloc] initWithURL:url cacheWorker:_cacheWorker];
        _pendingRequestWorkers = [NSMutableArray array];
    }
    return self;
}

- (instancetype)init {
    NSAssert(NO, @"Use - initWithURL: instead");
    return nil;
}

- (void)addRequest:(AVAssetResourceLoadingRequest *)request {
    if (self.pendingRequestWorkers.count > 0) {
        [self startNoCacheWorkerWithRequest:request];
    } else {
        [self startWorkerWithRequest:request];
    }
}

- (void)removeRequest:(AVAssetResourceLoadingRequest *)request {
    __block ALTResourceLoadingRequestWorker *requestWorker = nil;
    [self.pendingRequestWorkers enumerateObjectsUsingBlock:^(ALTResourceLoadingRequestWorker *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.request == request) {
            requestWorker = obj;
            *stop = YES;
        }
    }];
    if (requestWorker) {
        [requestWorker finish];
        [self.pendingRequestWorkers removeObject:requestWorker];
    }
}

- (void)cancel {
    [self.mediaDownloader cancel];
    [self.pendingRequestWorkers removeAllObjects];
    [[ALTMediaDownloaderStatus shared] removeURL:self.url];
}

- (void)asyncLoadArobablyStart:(long long)startOffset size:(long long)size {
    [self.mediaDownloader asyncDownloadStartOffset:startOffset size:size];
}
#pragma mark - ALTResourceLoadingRequestWorkerDelegate

- (void)resourceLoadingRequestWorker:(ALTResourceLoadingRequestWorker *)requestWorker didCompleteWithError:(NSError *)error {
    [self removeRequest:requestWorker.request];
    if (error && [self.delegate respondsToSelector:@selector(resourceLoader:didFailWithError:)]) {
        [self.delegate resourceLoader:self didFailWithError:error];
    }
    if (self.pendingRequestWorkers.count == 0) {
        [[ALTMediaDownloaderStatus shared] removeURL:self.url];
    }
}

- (void)resourceLoadingData:(NSData *)data {
    if ([self.delegate respondsToSelector:@selector(resourceLoaderData:)]) {
        [self.delegate resourceLoaderData:data];
    }
}

#pragma mark - Helper

- (void)startNoCacheWorkerWithRequest:(AVAssetResourceLoadingRequest *)request {
    [[ALTMediaDownloaderStatus shared] addURL:self.url];
    ALTMediaDownloader *mediaDownloader = [[ALTMediaDownloader alloc] initWithURL:self.url cacheWorker:self.cacheWorker];
    ALTResourceLoadingRequestWorker *requestWorker = [[ALTResourceLoadingRequestWorker alloc] initWithMediaDownloader:mediaDownloader
                                                                                               resourceLoadingRequest:request];
    [self.pendingRequestWorkers addObject:requestWorker];
    requestWorker.delegate = self;
    [requestWorker startWork];
}

- (void)startWorkerWithRequest:(AVAssetResourceLoadingRequest *)request {
    [[ALTMediaDownloaderStatus shared] addURL:self.url];
    ALTResourceLoadingRequestWorker *requestWorker = [[ALTResourceLoadingRequestWorker alloc] initWithMediaDownloader:self.mediaDownloader
                                                                                             resourceLoadingRequest:request];
    [self.pendingRequestWorkers addObject:requestWorker];
    requestWorker.delegate = self;
    [requestWorker startWork];
    
}

- (NSError *)loaderCancelledError {
    NSError *error = [[NSError alloc] initWithDomain:MCResourceLoaderErrorDomain
                                                code:-3
                                            userInfo:@{NSLocalizedDescriptionKey:@"Resource loader cancelled"}];
    return error;
}

@end

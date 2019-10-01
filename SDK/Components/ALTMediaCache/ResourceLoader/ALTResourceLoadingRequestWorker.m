//
//  ALTMediaDownloader.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/26.
//  Copyright © 2019年 Alienchang. All rights reserved.
//


#import "ALTResourceLoadingRequestWorker.h"
#import "ALTMediaDownloader.h"
#import "ALTContentInfo.h"

@import MobileCoreServices;
@import AVFoundation;
@import UIKit;

@interface ALTResourceLoadingRequestWorker () <ALTMediaDownloaderDelegate>

@property (nonatomic, strong, readwrite) AVAssetResourceLoadingRequest *request;
@property (nonatomic, strong) ALTMediaDownloader *mediaDownloader;

@end

@implementation ALTResourceLoadingRequestWorker

- (instancetype)initWithMediaDownloader:(ALTMediaDownloader *)mediaDownloader resourceLoadingRequest:(AVAssetResourceLoadingRequest *)request {
    self = [super init];
    if (self) {
        _mediaDownloader = mediaDownloader;
        _mediaDownloader.delegate = self;
        _request = request;
        
        [self fullfillContentInfo];
    }
    return self;
}

- (void)startWork {
    AVAssetResourceLoadingDataRequest *dataRequest = self.request.dataRequest;
    long long offset = dataRequest.requestedOffset;
    NSInteger length = dataRequest.requestedLength;
    if (dataRequest.currentOffset != 0) {
        offset = dataRequest.currentOffset;
    }
    
    BOOL toEnd = NO;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        if (dataRequest.requestsAllDataToEndOfResource) {
            toEnd = YES;
        }
    }
    [self.mediaDownloader downloadTaskFromOffset:offset length:length toEnd:toEnd];
}

- (void)cancel {
    [self.mediaDownloader cancel];
}

- (void)finish {
    if (!self.request.isFinished) {
        [self.request finishLoadingWithError:[self loaderCancelledError]];
    }
}

- (NSError *)loaderCancelledError{
    NSError *error = [[NSError alloc] initWithDomain:@"com.resourceloader"
                                                code:-3
                                            userInfo:@{NSLocalizedDescriptionKey:@"Resource loader cancelled"}];
    return error;
}

- (void)fullfillContentInfo {
    AVAssetResourceLoadingContentInformationRequest *contentInformationRequest = self.request.contentInformationRequest;
    if (self.mediaDownloader.info && !contentInformationRequest.contentType) {
        // Fullfill content information
        contentInformationRequest.contentType = self.mediaDownloader.info.contentType;
        contentInformationRequest.contentLength = self.mediaDownloader.info.contentLength;
        contentInformationRequest.byteRangeAccessSupported = self.mediaDownloader.info.byteRangeAccessSupported;
    }
}

#pragma mark - ALTMediaDownloaderDelegate

- (void)mediaDownloader:(ALTMediaDownloader *)downloader didReceiveResponse:(NSURLResponse *)response {
    [self fullfillContentInfo];
}

- (void)mediaDownloader:(ALTMediaDownloader *)downloader didReceiveData:(NSData *)data {
    [self.request.dataRequest respondWithData:data];
    if ([self.delegate respondsToSelector:@selector(resourceLoadingData:)]) {
        [self.delegate resourceLoadingData:data];
    }
}

- (void)mediaDownloader:(ALTMediaDownloader *)downloader didFinishedWithError:(NSError *)error {
    if (error.code == NSURLErrorCancelled) {
        return;
    }
    
    if (!error) {
        [self.request finishLoading];
    } else {
        [self.request finishLoadingWithError:error];
    }
    
    [self.delegate resourceLoadingRequestWorker:self didCompleteWithError:error];
}

@end

//
//  ALTMediaDownloader.h
//  ALTSDK
//
//  Created by Alienchang on 2019/3/26.
//  Copyright © 2019年 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ALTMediaDownloader, AVAssetResourceLoadingRequest;
@protocol ALTResourceLoadingRequestWorkerDelegate;

@interface ALTResourceLoadingRequestWorker : NSObject

- (instancetype)initWithMediaDownloader:(ALTMediaDownloader *)mediaDownloader resourceLoadingRequest:(AVAssetResourceLoadingRequest *)request;

@property (nonatomic, weak) id<ALTResourceLoadingRequestWorkerDelegate> delegate;

@property (nonatomic, strong, readonly) AVAssetResourceLoadingRequest *request;

- (void)startWork;
- (void)cancel;
- (void)finish;

@end

@protocol ALTResourceLoadingRequestWorkerDelegate <NSObject>
- (void)resourceLoadingData:(NSData *)data ;
- (void)resourceLoadingRequestWorker:(ALTResourceLoadingRequestWorker *)requestWorker didCompleteWithError:(NSError *)error;

@end

//
//  ALTMediaDownloader.h
//  ALTSDK
//
//  Created by Alienchang on 2019/3/26.
//  Copyright © 2019年 Alienchang. All rights reserved.
//


#import <Foundation/Foundation.h>

@protocol ALTMediaDownloaderDelegate;
@class ALTContentInfo;
@class ALTMediaCacheWorker;

@interface ALTMediaDownloaderStatus : NSObject

+ (instancetype)shared;

- (void)addURL:(NSURL *)url;
- (void)removeURL:(NSURL *)url;

/**
 return YES if downloading the url source
 */
- (BOOL)containsURL:(NSURL *)url;
- (NSSet *)urls;

@end

@interface ALTMediaDownloader : NSObject

- (instancetype)initWithURL:(NSURL *)url cacheWorker:(ALTMediaCacheWorker *)cacheWorker;
@property (nonatomic ,readonly) long long currentDownloadEndOffset;
@property (nonatomic ,strong, readonly) NSURL *url;
@property (nonatomic ,weak) id<ALTMediaDownloaderDelegate> delegate;
@property (nonatomic ,strong) ALTContentInfo *info;
@property (nonatomic ,assign) BOOL saveToCache;
@property (nonatomic ,readonly) float progress;
@property (nonatomic, strong) ALTMediaCacheWorker *cacheWorker;
- (void)downloadTaskFromOffset:(unsigned long long)fromOffset
                        length:(unsigned long long)length
                         toEnd:(BOOL)toEnd;
- (void)downloadFromStartToEnd;

- (void)cancel;
- (void)asyncDownloadStartOffset:(long long)offset size:(long long)size;
@end

@protocol ALTMediaDownloaderDelegate <NSObject>

@optional
- (void)mediaDownloader:(ALTMediaDownloader *)downloader didReceiveResponse:(NSURLResponse *)response;
- (void)mediaDownloader:(ALTMediaDownloader *)downloader didReceiveData:(NSData *)data;
- (void)mediaDownloader:(ALTMediaDownloader *)downloader didFinishedWithError:(NSError *)error;

@end

//
//  ALTMediaDownloader.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/26.
//  Copyright © 2019年 Alienchang. All rights reserved.
//


#import "ALTMediaDownloader.h"
#import "ALTContentInfo.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ALTCacheSessionManager.h"

#import "ALTMediaCacheWorker.h"
#import "ALTCacheManager.h"
#import "ALTCacheAction.h"

#pragma mark - Class: ALTURLSessionDelegateObject

@protocol  ALTURLSessionDelegateObjectDelegate <NSObject>

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler;
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler;
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data;
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error;

@end

static NSInteger kBufferSize = 10 * 1024;

@interface ALTURLSessionDelegateObject : NSObject <NSURLSessionDelegate>

- (instancetype)initWithDelegate:(id<ALTURLSessionDelegateObjectDelegate>)delegate;

@property (nonatomic, weak) id<ALTURLSessionDelegateObjectDelegate> delegate;
@property (nonatomic, strong) NSMutableData *bufferData;

@end

@implementation ALTURLSessionDelegateObject

- (instancetype)initWithDelegate:(id<ALTURLSessionDelegateObjectDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _bufferData = [NSMutableData data];
    }
    return self;
}



#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    [self.delegate URLSession:session didReceiveChallenge:challenge completionHandler:completionHandler];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    [self.delegate URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    @synchronized (self.bufferData) {
        [self.bufferData appendData:data];
        if (self.bufferData.length > kBufferSize) {
            NSRange chunkRange = NSMakeRange(0, self.bufferData.length);
            NSData *chunkData = [self.bufferData subdataWithRange:chunkRange];
            [self.bufferData replaceBytesInRange:chunkRange withBytes:NULL length:0];
            [self.delegate URLSession:session dataTask:dataTask didReceiveData:chunkData];
        }
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionDataTask *)task
didCompleteWithError:(nullable NSError *)error {
    @synchronized (self.bufferData) {
        if (self.bufferData.length > 0 && !error) {
            NSRange chunkRange = NSMakeRange(0, self.bufferData.length);
            NSData *chunkData = [self.bufferData subdataWithRange:chunkRange];
            [self.bufferData replaceBytesInRange:chunkRange withBytes:NULL length:0];
            [self.delegate URLSession:session dataTask:task didReceiveData:chunkData];
        }
    }
    [self.delegate URLSession:session task:task didCompleteWithError:error];
}

@end

#pragma mark - Class: ALTActionWorker

@class ALTActionWorker;

@protocol ALTActionWorkerDelegate <NSObject>

- (void)actionWorker:(ALTActionWorker *)actionWorker didReceiveResponse:(NSURLResponse *)response;
- (void)actionWorker:(ALTActionWorker *)actionWorker didReceiveData:(NSData *)data isLocal:(BOOL)isLocal;
- (void)actionWorker:(ALTActionWorker *)actionWorker didFinishWithError:(NSError *)error;

@end

@interface ALTActionWorker : NSObject <ALTURLSessionDelegateObjectDelegate>

@property (nonatomic, strong) NSMutableArray<ALTCacheAction *> *actions;
- (instancetype)initWithActions:(NSArray<ALTCacheAction *> *)actions url:(NSURL *)url cacheWorker:(ALTMediaCacheWorker *)cacheWorker;

@property (nonatomic, assign) BOOL canSaveToCache;
@property (nonatomic, weak) id<ALTActionWorkerDelegate> delegate;

- (void)start;
- (void)cancel;


@property (nonatomic, getter=isCancelled) BOOL cancelled;

@property (nonatomic, strong) ALTMediaCacheWorker *cacheWorker;
@property (nonatomic, strong) NSURL *url;

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) ALTURLSessionDelegateObject *sessionDelegateObject;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic) NSInteger startOffset;

@end

@interface ALTActionWorker ()

@property (nonatomic) NSTimeInterval notifyTime;

@end

@implementation ALTActionWorker

- (void)dealloc {
    [self cancel];
}

- (instancetype)initWithActions:(NSArray<ALTCacheAction *> *)actions url:(NSURL *)url cacheWorker:(ALTMediaCacheWorker *)cacheWorker {
    self = [super init];
    if (self) {
        _canSaveToCache = YES;
        _actions = [actions mutableCopy];
        _cacheWorker = cacheWorker;
        _url = url;
    }
    return self;
}

- (void)start {
    [self processActions];
}

- (void)cancel {
    if (_session) {
        [self.session invalidateAndCancel];
    }
    self.cancelled = YES;
}

- (ALTURLSessionDelegateObject *)sessionDelegateObject {
    if (!_sessionDelegateObject) {
        _sessionDelegateObject = [[ALTURLSessionDelegateObject alloc] initWithDelegate:self];
    }
    
    return _sessionDelegateObject;
}

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self.sessionDelegateObject delegateQueue:[ALTCacheSessionManager shared].downloadQueue];
        _session = session;
    }
    return _session;
}

- (void)processActions {
    if (self.isCancelled) {
        return;
    }
    ALTCacheAction *action = [self.actions firstObject];
    if (!action) {
        if ([self.delegate respondsToSelector:@selector(actionWorker:didFinishWithError:)]) {
            [self.delegate actionWorker:self didFinishWithError:nil];
        }
        return;
    }
    [self.actions removeObjectAtIndex:0];
    [self loadDataWithCacheAction:action];
}

- (void)loadDataWithCacheAction:(ALTCacheAction *)action {
    if (action.actionType == ALTCacheAtionTypeLocal) {
        NSError *error;
        NSData *data = [self.cacheWorker cachedDataForRange:action.range error:&error];
        if (error) {
            if ([self.delegate respondsToSelector:@selector(actionWorker:didFinishWithError:)]) {
                [self.delegate actionWorker:self didFinishWithError:error];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(actionWorker:didReceiveData:isLocal:)]) {
                [self.delegate actionWorker:self didReceiveData:data isLocal:YES];
            }
            [self processActions];
        }
    } else {
        long long fromOffset = action.range.location;
        long long endOffset = action.range.location + action.range.length - 1;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
        request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        NSString *range = [NSString stringWithFormat:@"bytes=%lld-%lld", fromOffset, endOffset];
        [request setValue:range forHTTPHeaderField:@"Range"];
        self.startOffset = action.range.location;
        self.task = [self.session dataTaskWithRequest:request];
        [self.task resume];
    }
}

- (void)notifyDownloadProgressWithFlush:(BOOL)flush finished:(BOOL)finished {
    double currentTime = CFAbsoluteTimeGetCurrent();
    double interval = [ALTCacheManager cacheUpdateNotifyInterval];
    if ((self.notifyTime < currentTime - interval) || flush) {
        self.notifyTime = currentTime;
        ALTCacheConfiguration *configuration = [self.cacheWorker.cacheConfiguration copy];
        [[NSNotificationCenter defaultCenter] postNotificationName:ALTCacheManagerDidUpdateCacheNotification
                                                            object:self
                                                          userInfo:@{
                                                                     ALTCacheConfigurationKey: configuration,
                                                                     }];
            
        if (finished && configuration.progress >= 1.0) {
            [self notifyDownloadFinishedWithError:nil];
        }
    }
}

- (void)notifyDownloadFinishedWithError:(NSError *)error {
    ALTCacheConfiguration *configuration = [self.cacheWorker.cacheConfiguration copy];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setValue:configuration forKey:ALTCacheConfigurationKey];
    [userInfo setValue:error forKey:ALTCacheFinishedErrorKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ALTCacheManagerDidFinishCacheNotification
                                                        object:self
                                                      userInfo:userInfo];
}

#pragma mark - URLSessionDelegateObjectDelegate

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    NSURLCredential *card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential,card);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSString *mimeType = response.MIMEType;
    // Only download video/audio data
    if ([mimeType rangeOfString:@"video/"].location == NSNotFound &&
        [mimeType rangeOfString:@"audio/"].location == NSNotFound &&
        [mimeType rangeOfString:@"application"].location == NSNotFound) {
        completionHandler(NSURLSessionResponseCancel);
    } else {
        if ([self.delegate respondsToSelector:@selector(actionWorker:didReceiveResponse:)]) {
            [self.delegate actionWorker:self didReceiveResponse:response];
        }
        if (self.canSaveToCache) {
            [self.cacheWorker startWritting];
        }
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    if (self.isCancelled) {
        return;
    }
    
    if (self.canSaveToCache) {
        NSRange range = NSMakeRange(self.startOffset, data.length);
        NSError *error;
        [self.cacheWorker cacheData:data forRange:range error:&error];
        if (error) {
            if ([self.delegate respondsToSelector:@selector(actionWorker:didFinishWithError:)]) {
                [self.delegate actionWorker:self didFinishWithError:error];
            }
            return;
        }
        [self.cacheWorker save];
    }
    
    self.startOffset += data.length;
    if ([self.delegate respondsToSelector:@selector(actionWorker:didReceiveData:isLocal:)]) {
        [self.delegate actionWorker:self didReceiveData:data isLocal:NO];
    }
//    _progress = self.startOffset / self.tot
    [self notifyDownloadProgressWithFlush:NO finished:NO];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    if (self.canSaveToCache) {
        [self.cacheWorker finishWritting];
        [self.cacheWorker save];
    }
    if (error) {
        if ([self.delegate respondsToSelector:@selector(actionWorker:didFinishWithError:)]) {
            [self.delegate actionWorker:self didFinishWithError:error];
        }
        [self notifyDownloadFinishedWithError:error];
    } else {
        [self notifyDownloadProgressWithFlush:YES finished:YES];
        [self processActions];
    }
}


@end

#pragma mark - Class: ALTMediaDownloaderStatus


@interface ALTMediaDownloaderStatus ()

@property (nonatomic ,strong) NSMutableSet *downloadingURLS;
@end

@implementation ALTMediaDownloaderStatus

+ (instancetype)shared {
    static ALTMediaDownloaderStatus *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.downloadingURLS = [NSMutableSet set];
    });
    
    return instance;
}

- (void)addURL:(NSURL *)url {
    @synchronized (self.downloadingURLS) {
        [self.downloadingURLS addObject:url];
    }
}

- (void)removeURL:(NSURL *)url {
    @synchronized (self.downloadingURLS) {
        [self.downloadingURLS removeObject:url];
    }
}

- (BOOL)containsURL:(NSURL *)url {
    @synchronized (self.downloadingURLS) {
        return [self.downloadingURLS containsObject:url];
    }
}

- (NSSet *)urls {
    return [self.downloadingURLS copy];
}

@end

#pragma mark - Class: ALTMediaDownloader

@interface ALTMediaDownloader () <ALTActionWorkerDelegate> {
    float _progress;
    long long _currentEndOffset;        // 当前请求数据的尾部
}

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) ALTActionWorker *actionWorker;
@property (nonatomic, assign) unsigned long long totalLength;
@property (nonatomic) BOOL downloadToEnd;

@end

@implementation ALTMediaDownloader

- (void)dealloc {
    [[ALTMediaDownloaderStatus shared] removeURL:self.url];
}

- (instancetype)initWithURL:(NSURL *)url cacheWorker:(ALTMediaCacheWorker *)cacheWorker {
    self = [super init];
    if (self) {
        _saveToCache = YES;
        _url = url;
        _cacheWorker = cacheWorker;
        _info = _cacheWorker.cacheConfiguration.contentInfo;
        [[ALTMediaDownloaderStatus shared] addURL:self.url];
    }
    return self;
}
- (void)asyncDownloadStartOffset:(long long)offset size:(long long)size {
    NSMutableArray *rangeActions = [NSMutableArray new];
    for (ALTCacheAction *action in self.actionWorker.actions) {
        if (action.range.location < offset && (action.range.location + action.range.length) > offset) {
            [rangeActions addObject:action];
            [self.actionWorker.actions removeObject:action];
        }
        if (action.range.location > offset && (action.range.location + action.range.length) < (offset + size)) {
            [rangeActions addObject:action];
            [self.actionWorker.actions removeObject:action];
        }
        if (action.range.location < (offset + size) && (action.range.location + action.range.length) > (offset + size)) {
            [rangeActions addObject:action];
            [self.actionWorker.actions removeObject:action];
            break;
        }
    }
}
- (void)downloadTaskFromOffset:(unsigned long long)fromOffset
                        length:(unsigned long long)length
                         toEnd:(BOOL)toEnd {
    // ---
    NSRange range = NSMakeRange((NSUInteger)fromOffset, length);
    [self setTotalLength:fromOffset + length];
    if (toEnd) {
        range.length = (NSUInteger)self.cacheWorker.cacheConfiguration.contentInfo.contentLength - range.location;
    }
    
    NSArray *actions = [self.cacheWorker cachedDataActionsForRange:range];
    self.actionWorker = [[ALTActionWorker alloc] initWithActions:actions url:self.url cacheWorker:self.cacheWorker];
    self.actionWorker.canSaveToCache = self.saveToCache;
    self.actionWorker.delegate = self;
    [self.actionWorker start];
}

- (void)downloadFromStartToEnd {
    // ---
    self.downloadToEnd = YES;
    NSRange range = NSMakeRange(0, 2);
    NSArray *actions = [self.cacheWorker cachedDataActionsForRange:range];

    self.actionWorker = [[ALTActionWorker alloc] initWithActions:actions url:self.url cacheWorker:self.cacheWorker];
    self.actionWorker.canSaveToCache = self.saveToCache;
    self.actionWorker.delegate = self;
    [self.actionWorker start];
}

- (void)cancel {
    self.actionWorker.delegate = nil;
    [[ALTMediaDownloaderStatus shared] removeURL:self.url];
    [self.actionWorker cancel];
    self.actionWorker = nil;
}

#pragma mark - ALTActionWorkerDelegate

- (void)actionWorker:(ALTActionWorker *)actionWorker didReceiveResponse:(NSURLResponse *)response {
    if (!self.info) {
        ALTContentInfo *info = [ALTContentInfo new];
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *HTTPURLResponse = (NSHTTPURLResponse *)response;
            NSString *acceptRange = HTTPURLResponse.allHeaderFields[@"Accept-Ranges"];
            info.byteRangeAccessSupported = [acceptRange isEqualToString:@"bytes"];
            info.contentLength = [[[HTTPURLResponse.allHeaderFields[@"Content-Range"] componentsSeparatedByString:@"/"] lastObject] longLongValue];
        }
        NSString *mimeType = response.MIMEType;
        CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
        info.contentType = CFBridgingRelease(contentType);
        self.info = info;
        
        NSError *error;
        [self.cacheWorker setContentInfo:info error:&error];
        if (error) {
            if ([self.delegate respondsToSelector:@selector(mediaDownloader:didFinishedWithError:)]) {
                [self.delegate mediaDownloader:self didFinishedWithError:error];
            }
            return;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(mediaDownloader:didReceiveResponse:)]) {
        [self.delegate mediaDownloader:self didReceiveResponse:response];
    }
}

- (void)actionWorker:(ALTActionWorker *)actionWorker didReceiveData:(NSData *)data isLocal:(BOOL)isLocal {
    if ([self.delegate respondsToSelector:@selector(mediaDownloader:didReceiveData:)]) {
        _progress = actionWorker.startOffset * 1.0 / self.totalLength;
        [self.delegate mediaDownloader:self didReceiveData:data];
    }
}

- (void)actionWorker:(ALTActionWorker *)actionWorker didFinishWithError:(NSError *)error {
    [[ALTMediaDownloaderStatus shared] removeURL:self.url];
    
    if (!error && self.downloadToEnd) {
        self.downloadToEnd = NO;
        [self downloadTaskFromOffset:2 length:(NSUInteger)(self.cacheWorker.cacheConfiguration.contentInfo.contentLength - 2) toEnd:YES];
    } else {
        if ([self.delegate respondsToSelector:@selector(mediaDownloader:didFinishedWithError:)]) {
            [self.delegate mediaDownloader:self didFinishedWithError:error];
        }
    }
}


#pragma mark -- getter
- (float)progress {
    return _progress;
}
- (long long)currentDownloadEndOffset {
    ALTCacheAction *cacheAction = self.actionWorker.actions.firstObject;
    return cacheAction.range.location - 1;
}
@end

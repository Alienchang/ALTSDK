//
//  ALTMediaCacheWorker.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/26.
//  Copyright © 2019年 Alienchang. All rights reserved.
//

#import "ALTMediaCacheWorker.h"
#import "ALTCacheAction.h"
#import "ALTCacheManager.h"

@import UIKit;

static NSInteger const kPackageLength = 204800; // 200kb per package
static NSString *kMCMediaCacheResponseKey = @"kMCMediaCacheResponseKey";
static NSString *ALTMediaCacheErrorDoamin = @"com.ALTMediaCache";

@interface ALTMediaCacheWorker ()

@property (nonatomic, strong) NSFileHandle *readFileHandle;
@property (nonatomic, strong) NSFileHandle *writeFileHandle;
@property (nonatomic, strong, readwrite) NSError *setupError;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) ALTCacheConfiguration *internalCacheConfiguration;

@property (nonatomic) long long currentOffset;

@property (nonatomic, strong) NSDate *startWriteDate;
@property (nonatomic) float writeBytes;
@property (nonatomic) BOOL writting;

@end

@implementation ALTMediaCacheWorker

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self save];
    [_readFileHandle closeFile];
    [_writeFileHandle closeFile];
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        NSString *path = [ALTCacheManager cachedFilePathForURL:url];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        _filePath = path;
        NSError *error;
        NSString *cacheFolder = [path stringByDeletingLastPathComponent];
        if (![fileManager fileExistsAtPath:cacheFolder]) {
            [fileManager createDirectoryAtPath:cacheFolder
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:&error];
        }
        
        if (!error) {
            if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
            }
            NSURL *fileURL = [NSURL fileURLWithPath:path];
            _readFileHandle = [NSFileHandle fileHandleForReadingFromURL:fileURL error:&error];
            if (!error) {
                _writeFileHandle = [NSFileHandle fileHandleForWritingToURL:fileURL error:&error];
                _internalCacheConfiguration = [ALTCacheConfiguration configurationWithFilePath:path];
                _internalCacheConfiguration.url = url;
            }
        }
        
        _setupError = error;
    }
    return self;
}

- (ALTCacheConfiguration *)cacheConfiguration {
    return self.internalCacheConfiguration;
}

- (void)cacheData:(NSData *)data forRange:(NSRange)range error:(NSError **)error {
    @synchronized(self.writeFileHandle) {
        @try {
            [self.writeFileHandle seekToFileOffset:range.location];
            [self.writeFileHandle writeData:data];
            self.writeBytes += data.length;
            [self.internalCacheConfiguration addCacheFragment:range];
        } @catch (NSException *exception) {
            NSLog(@"write to file error");
            *error = [NSError errorWithDomain:exception.name code:123 userInfo:@{NSLocalizedDescriptionKey: exception.reason, @"exception": exception}];
        }
    }
}

- (NSData *)cachedDataForRange:(NSRange)range error:(NSError **)error {
    @synchronized(self.readFileHandle) {
        @try {
            [self.readFileHandle seekToFileOffset:range.location];
            NSData *data = [self.readFileHandle readDataOfLength:range.length]; // 空数据也会返回，所以如果 range 错误，会导致播放失效
            return data;
        } @catch (NSException *exception) {
            NSLog(@"read cached data error %@",exception);
            *error = [NSError errorWithDomain:exception.name code:123 userInfo:@{NSLocalizedDescriptionKey: exception.reason, @"exception": exception}];
        }
    }
    return nil;
}

- (NSArray<ALTCacheAction *> *)cachedDataActionsForRange:(NSRange)range {
    NSArray *cachedFragments = [self.internalCacheConfiguration cacheFragments];
    NSMutableArray *actions = [NSMutableArray array];
    if (range.location == NSNotFound) {
        return [actions copy];
    }
    NSInteger endOffset = range.location + range.length;
    // Delete header and footer not in range
    [cachedFragments enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange fragmentRange = obj.rangeValue;
        NSRange intersectionRange = NSIntersectionRange(range, fragmentRange);
        if (intersectionRange.length > 0) {
            NSInteger package = intersectionRange.length / kPackageLength;
            for (NSInteger i = 0; i <= package; i++) {
                ALTCacheAction *action = [ALTCacheAction new];
                action.actionType = ALTCacheAtionTypeLocal;
                
                NSInteger offset = i * kPackageLength;
                NSInteger offsetLocation = intersectionRange.location + offset;
                NSInteger maxLocation = intersectionRange.location + intersectionRange.length;
                NSInteger length = (offsetLocation + kPackageLength) > maxLocation ? (maxLocation - offsetLocation) : kPackageLength;
                action.range = NSMakeRange(offsetLocation, length);
                
                [actions addObject:action];
            }
        } else if (fragmentRange.location >= endOffset) {
            *stop = YES;
        }
    }];
    
    if (actions.count == 0) {
        ALTCacheAction *action = [ALTCacheAction new];
        action.actionType = ALTCacheAtionTypeRemote;
        action.range = range;
        [actions addObject:action];
    } else {
        // Add remote fragments
        NSMutableArray *localRemoteActions = [NSMutableArray array];
        [actions enumerateObjectsUsingBlock:^(ALTCacheAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange actionRange = obj.range;
            if (idx == 0) {
                if (range.location < actionRange.location) {
                    ALTCacheAction *action = [ALTCacheAction new];
                    action.actionType = ALTCacheAtionTypeRemote;
                    action.range = NSMakeRange(range.location, actionRange.location - range.location);
                    [localRemoteActions addObject:action];
                }
                [localRemoteActions addObject:obj];
            } else {
                ALTCacheAction *lastAction = [localRemoteActions lastObject];
                NSInteger lastOffset = lastAction.range.location + lastAction.range.length;
                if (actionRange.location > lastOffset) {
                    ALTCacheAction *action = [ALTCacheAction new];
                    action.actionType = ALTCacheAtionTypeRemote;
                    action.range = NSMakeRange(lastOffset, actionRange.location - lastOffset);
                    [localRemoteActions addObject:action];
                }
                [localRemoteActions addObject:obj];
            }
            
            if (idx == actions.count - 1) {
                NSInteger localEndOffset = actionRange.location + actionRange.length;
                if (endOffset > localEndOffset) {
                    ALTCacheAction *action = [ALTCacheAction new];
                    action.actionType = ALTCacheAtionTypeRemote;
                    action.range = NSMakeRange(localEndOffset, endOffset - localEndOffset);
                    [localRemoteActions addObject:action];
                }
            }
        }];
        
        actions = localRemoteActions;
    }
    return [actions copy];
}

- (void)setContentInfo:(ALTContentInfo *)contentInfo error:(NSError **)error {
    self.internalCacheConfiguration.contentInfo = contentInfo;
    @try {
        [self.writeFileHandle truncateFileAtOffset:contentInfo.contentLength];
        [self.writeFileHandle synchronizeFile];
    } @catch (NSException *exception) {
        NSLog(@"read cached data error %@", exception);
        *error = [NSError errorWithDomain:exception.name code:123 userInfo:@{NSLocalizedDescriptionKey: exception.reason, @"exception": exception}];
    }
}

- (void)save {
    @synchronized (self.writeFileHandle) {
        [self.writeFileHandle synchronizeFile];
        [self.internalCacheConfiguration save];
    }
}

- (void)startWritting {
    if (!self.writting) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    self.writting = YES;
    self.startWriteDate = [NSDate date];
    self.writeBytes = 0;
}

- (void)finishWritting {
    if (self.writting) {
        self.writting = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:self.startWriteDate];
        [self.internalCacheConfiguration addDownloadedBytes:self.writeBytes spent:time];
    }
}

#pragma mark - Notification

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self save];
}

@end

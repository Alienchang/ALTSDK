//
//  ALTCacheSessionManager.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/25.
//  Copyright © 2019年 Alienchang. All rights reserved.
//


#import "ALTCacheSessionManager.h"

@interface ALTCacheSessionManager ()

@property (nonatomic, strong) NSOperationQueue *downloadQueue;

@end

@implementation ALTCacheSessionManager

+ (instancetype)shared {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        queue.name = @"com.ALTMediaCache.download";
        _downloadQueue = queue;
    }
    return self;
}

@end

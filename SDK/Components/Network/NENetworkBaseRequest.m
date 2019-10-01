//
//  NENetworkBaseRequest.m
//  MeMe
//
//  Created by Chang Liu on 3/19/18.
//  Copyright © 2018 sip. All rights reserved.
//

#import "NENetworkBaseRequest.h"

@implementation NENetworkBaseRequest
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.requestRetryCount = 0;
        self.retryRequestTimeInterval = 2;
        self.totalRequestCount = 1;
    }
    return self;
}
// 默认最大重试次数，3次，0为不启用。
- (void)setRequestRetryCount:(NSUInteger)requestRetryCount {
    _requestRetryCount = requestRetryCount;
    
    if (_requestRetryCount > 3) {
        _requestRetryCount = 3;
        return;
    }
}

// 默认最大间隔时间6秒，最小间隔时间2秒。
- (void)setRetryRequestTimeInterval:(NSUInteger)retryRequestTimeInterval {
    _retryRequestTimeInterval = retryRequestTimeInterval;
    
    if (_retryRequestTimeInterval < 2) {
        _retryRequestTimeInterval = 2;
        return;
    }
    
    if (_retryRequestTimeInterval > 6) {
        _retryRequestTimeInterval = 6;
        return;
    }
}
@end

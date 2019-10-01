//
//  ALTNetworkService.m
//  ALTSDK
//
//  Created by Alienchang on 2019/4/11.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "ALTNetworkService.h"
#import "ALTNetworkConst.h"

static ALTNetworkService *networkService;
@implementation ALTNetworkService
+ (instancetype)service {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkService = [ALTNetworkService new];
    });
    return networkService;
}

- (void)loadConfigWithProjectId:(NSString *)projectId
                      episodeId:(NSString *)episodeId
                   successBlock:(void(^)(NSData *data))successBlock
                   failureBlock:(void(^)(NSError *error))failureBlock {
    NENetworkManager *networkManager = [NENetworkManager shared];
    NENetworkBaseRequest *request = [NENetworkBaseRequest new];
    [request setHost:host];
    
    NSDictionary *paramater = @{@"projectId":projectId,
                                @"episodeId":episodeId
                                };
    [request setRequestArgument:paramater];
    [request setFormParamater:paramater];
    [request setRequestMethod:NERequestHttpMethod_POST];
    [request setPathUrl:kLoadConfig];
    [networkManager addHTTPRequest:request];
    [request setSuccessCompletionBlock:^(__kindof NENetworkBaseRequest *request) {
        if (successBlock) {
            successBlock(request.responseObject);
        }
    }];
    [request setFailureCompletionBlock:^(__kindof NENetworkBaseRequest *request) {
        if (failureBlock) {
            failureBlock(request.httpError);
        }
    }];
}
@end

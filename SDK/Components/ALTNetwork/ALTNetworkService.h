//
//  ALTNetworkService.h
//  ALTSDK
//
//  Created by Alienchang on 2019/4/11.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NENetworkManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface ALTNetworkService : NSObject
+ (instancetype)service;
- (void)loadConfigWithProjectId:(NSString *)projectId
                      episodeId:(NSString *)episodeId
                   successBlock:(void(^)(NSData *data))successBlock
                   failureBlock:(void(^)(NSError *error))failureBlock;
@end

NS_ASSUME_NONNULL_END

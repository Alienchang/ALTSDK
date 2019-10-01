//
//  ALTCacheSessionManager.h
//  ALTSDK
//
//  Created by Alienchang on 2019/3/25.
//  Copyright © 2019年 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALTCacheSessionManager : NSObject

@property (nonatomic, strong, readonly) NSOperationQueue *downloadQueue;

+ (instancetype)shared;

@end

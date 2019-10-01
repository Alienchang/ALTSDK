//
//  ALTSafeThread.m
//  ALTSDK
//
//  Created by Alienchang on 2019/4/10.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "ALTSafeThread.h"

@implementation ALTSafeThread

+ (void)safe_async_main:(void(^)(void))block {
    if ([NSThread isMainThread]) {
        if (block) {
            block();
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block();
            }
        });
    }
}

@end

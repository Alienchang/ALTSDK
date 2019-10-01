//
//  ALTSafeThread.h
//  ALTSDK
//
//  Created by Alienchang on 2019/4/10.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALTSafeThread : NSObject
+ (void)safe_async_main:(void(^)(void))block;
@end

NS_ASSUME_NONNULL_END

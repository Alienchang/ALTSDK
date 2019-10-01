//
//  ALTVideo.h
//  ALTSDK
//
//  Created by Alienchang on 2019/4/3.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALTVideoEvent.h"
NS_ASSUME_NONNULL_BEGIN

@interface ALTVideo : NSObject
@property (nonatomic ,copy)   NSString *videoId;
@property (nonatomic ,strong) NSMutableArray <ALTVideoEvent *>*videoEvents;
@end

NS_ASSUME_NONNULL_END

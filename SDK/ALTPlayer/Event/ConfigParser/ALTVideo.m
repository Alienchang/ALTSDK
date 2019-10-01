//
//  ALTVideo.m
//  ALTSDK
//
//  Created by Alienchang on 2019/4/3.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "ALTVideo.h"

@implementation ALTVideo
- (NSString *)description {
    return [NSString stringWithFormat:@"videoId = %@ ,videoEvent = %@",self.videoId ,self.videoEvents];
}
@end

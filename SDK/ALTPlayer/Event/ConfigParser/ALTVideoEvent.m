//
//  ALTVideoEvent.m
//  ALTSDK
//
//  Created by Alienchang on 2019/4/1.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "ALTVideoEvent.h"
#import "ALTParserUtil.h"
@implementation ALTVideoEvent

- (NSString *)description {
    return [NSString stringWithFormat:@"triggerStart = %@ ,triggerEnd = %@\n",self.triggerStart ,self.triggerEnd];
}
@end

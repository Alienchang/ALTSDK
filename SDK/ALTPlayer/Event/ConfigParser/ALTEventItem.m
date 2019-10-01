//
//  ALTEvent.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/25.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "ALTEventItem.h"
#import "ALTParserUtil.h"
@implementation ALTEventItem
#pragma mark -- getter

- (NSString *)description {
    return [NSString stringWithFormat:@"id = %@ ,type = %@",self.eventId,self.type];
}
@end

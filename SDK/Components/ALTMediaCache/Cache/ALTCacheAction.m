//
//  ALTCacheAction.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/26.
//  Copyright © 2019年 Alienchang. All rights reserved.
//
#import "ALTCacheAction.h"

@implementation ALTCacheAction

- (instancetype)initWithActionType:(ALTCacheAtionType)actionType range:(NSRange)range {
    self = [super init];
    if (self) {
        _actionType = actionType;
        _range = range;
    }
    return self;
}

- (BOOL)isEqual:(ALTCacheAction *)object {
    if (!NSEqualRanges(object.range, self.range)) {
        return NO;
    }
    
    if (object.actionType != self.actionType) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash {
    return [[NSString stringWithFormat:@"%@%@", NSStringFromRange(self.range), @(self.actionType)] hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"actionType %@, range: %@", @(self.actionType), NSStringFromRange(self.range)];
}

@end

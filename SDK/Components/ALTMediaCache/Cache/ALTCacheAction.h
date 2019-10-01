//
//  ALTCacheAction.h
//  ALTSDK
//
//  Created by Alienchang on 2019/3/26.
//  Copyright © 2019年 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ALTCacheAtionType) {
    ALTCacheAtionTypeLocal = 0,
    ALTCacheAtionTypeRemote
};

@interface ALTCacheAction : NSObject

- (instancetype)initWithActionType:(ALTCacheAtionType)actionType range:(NSRange)range;

@property (nonatomic) ALTCacheAtionType actionType;
@property (nonatomic) NSRange range;

@end

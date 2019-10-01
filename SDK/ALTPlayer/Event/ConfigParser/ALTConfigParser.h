//
//  ALTConfigParser.h
//  ALTSDK
//
//  Created by Alienchang on 2019/3/28.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALTEventItem.h"
#import "ALTProjectDataSource.h"
NS_ASSUME_NONNULL_BEGIN

@interface ALTConfigParser : NSObject
+ (ALTProjectDataSource *)parseConfigWithData:(NSData *)data fps:(int)fps;
+ (ALTProjectDataSource *)parseConfigWithPath:(NSString *)path;
@end

NS_ASSUME_NONNULL_END

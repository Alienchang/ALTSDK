//
//  ALTUtil.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/14.
//  Copyright © 2019年 Alienchang. All rights reserved.
//

#import "ALTUtil.h"

@implementation ALTUtil
+ (NSString *)convertUrl:(NSString *)string {
    return string;
}
+ (NSURL *)urlStringWithUrlString:(NSString *)urlString
                        videoQuality:(ALT_ENUM_VIDEO_QUALITY)videoQuality {
    NSString *tempUrlString = [self convertUrl:urlString];
    /// 根据业务拼接url
    return [NSURL URLWithString:tempUrlString];
}
@end

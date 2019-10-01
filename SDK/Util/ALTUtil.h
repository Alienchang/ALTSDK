//
//  ALTUtil.h
//  ALTSDK
//
//  Created by Alienchang on 2019/3/14.
//  Copyright © 2019年 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALTEnum.h"
NS_ASSUME_NONNULL_BEGIN

@interface ALTUtil : NSObject
/// 处理URL，判断是本地路径还是网络路径等等
+ (NSString *)convertUrl:(NSString *)string;
/// 根据业务和清晰度拼接url
+ (NSURL *)urlStringWithUrlString:(NSString *)urlString
                        videoQuality:(ALT_ENUM_VIDEO_QUALITY)videoQuality;
@end

NS_ASSUME_NONNULL_END

//
//  ALTBaseSetting.h
//  ALTSDK
//
//  Created by Alienchang on 2019/3/13.
//  Copyright © 2019年 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALTBaseSetting : NSObject
/// 鉴权，一定要在使用播放器之前设置
+ (void)setupLicence:(NSString *)licence;
+ (NSString *)getyLicence;

+ (void)enableControlLog:(BOOL)controlLog
                localLog:(BOOL)localLog;
@end

NS_ASSUME_NONNULL_END

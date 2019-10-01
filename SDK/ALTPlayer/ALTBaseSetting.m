//
//  ALTBaseSetting.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/13.
//  Copyright © 2019年 Alienchang. All rights reserved.
//

#import "ALTBaseSetting.h"
#import "ALTLog.h"

@implementation ALTBaseSetting
+ (void)setupLicence:(NSString *)licence {
    
}

+ (NSString *)getyLicence {
    return nil;
}

+ (void)enableControlLog:(BOOL)controlLog
                localLog:(BOOL)localLog {
    [ALTLog setupControlLog:controlLog
                   localLog:localLog];
}
@end

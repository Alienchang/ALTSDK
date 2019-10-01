//
//  UIImage+ALTSource.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/21.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "UIImage+ALTSource.h"

@implementation UIImage (ALTSource)
+ (instancetype)alt_imageNamed:(NSString *)imageNamed {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *resourcePath = [bundle resourcePath];
    NSString *formatedImageName = [NSMutableString stringWithString:imageNamed];
    NSString *filePath = nil;
    if ([UIScreen mainScreen].scale > 2) {
        filePath = [resourcePath stringByAppendingPathComponent:[formatedImageName stringByAppendingString:@"@3x.png"]];
    }
    if (!filePath || [UIScreen mainScreen].scale > 1) {
        filePath = [resourcePath stringByAppendingPathComponent:[formatedImageName stringByAppendingString:@"@2x.png"]];
    }
    
    if (!filePath) {
        filePath = [resourcePath stringByAppendingPathComponent:[formatedImageName stringByAppendingString:@".png"]];
    }
    
    if (filePath) {
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        return image;
    } else {
        return nil;
    }
}

+ (instancetype)alt_imageOfPlayIcon {
    return [UIImage imageNamed:@"icons8-play-96"];
}
+ (instancetype)alt_imageOfPauseIcon {
    return [UIImage imageNamed:@"icons8-pause-96"];
}
@end


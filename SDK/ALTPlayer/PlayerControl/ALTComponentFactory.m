//
//  ALTComponentFactory.m
//  ALTSDK
//
//  Created by Alienchang on 2019/4/8.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "ALTComponentFactory.h"
#import "ALTButton.h"
#import "ALTEventRouter.h"
#import <objc/runtime.h>
#include "alt_mp4_parser.h"
#include "alt_image_helper.h"

const NSString *kDataSource = @"dataSource";
const NSString *kComponentItem = @"componentItem";
const NSString *kCallBackController = @"callBackController";

@implementation ALTComponentFactory

+ (UIControl *)generateControlWithUIID:(NSString *)uiId
                     projectDataSource:(ALTProjectDataSource *)projectDataSource
                    callBackController:(ALTPlayerController *) callBackController {
    ALTButton *button = [ALTButton new];
    CGFloat contentPadding = 5.0;
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(contentPadding, contentPadding, contentPadding, contentPadding);
    [button setImageEdgeInsets:edgeInsets];

    ALTComponentItem *componentItem = projectDataSource.componentsDictionary[uiId];
    [button setProjectDataSource:projectDataSource];
    [button setComponentItem:componentItem];
    [button setDuration:componentItem.duration];
    [button setTitle:componentItem.note forState:UIControlStateNormal];
    [button setAlpha:componentItem.alpha];
    objc_setAssociatedObject(button, &kDataSource, projectDataSource, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(button, &kComponentItem, componentItem, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(button, &kCallBackController, callBackController, OBJC_ASSOCIATION_ASSIGN);
    unsigned result = 0;
    NSScanner *scanner = [NSScanner scannerWithString:componentItem.offset];
    
    [scanner setScanLocation:0]; // bypass '#' character
    [scanner scanHexInt:&result];
    
    NSString *filePath = [ALTPlayer cachePathWithUrlString:projectDataSource.videoUrl];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    [fileHandle seekToFileOffset:result];
    NSData *allData = [fileHandle readDataToEndOfFile];
    
    long imageLength = 0;
    char *imageChar = get_img((char *)[allData bytes] ,&imageLength);

    int width = 0;
    int height = 0;
    extract_pic_info(imageChar, (uint32_t)imageLength, &width, &height);
    NSData *data = [NSData dataWithBytes:imageChar length:imageLength];
    UIImage *image = [UIImage imageWithData:data];
    if (image) {
        [button setImage:image forState:UIControlStateNormal];
        CGRect rect = CGRectZero;
        if (componentItem.width && componentItem.height) {
            rect = CGRectMake(componentItem.x, componentItem.y, componentItem.width, componentItem.height);
        } else {
            rect = CGRectMake(componentItem.x, componentItem.y, image.size.width, image.size.height);
        }
        
        [button setFrame:[self convertComponentFrameWithProject:projectDataSource.project componentFrame:rect contentPadding:contentPadding]];
        [button setTransform:CGAffineTransformMakeRotation(componentItem.rotate / 180.)];
    } else {
//        NSString *imageUrl = [NSString stringWithFormat:@"%@%@",projectDataSource.project.imageBaseUrl ,componentItem.picNormal];
//        [button ne_setImageWithURL:imageUrl forState:UIControlStateNormal placeholderImage:nil didShowImage:^(UIImage *image) {
//            CGRect rect = CGRectMake(componentItem.x - edgeInsets.left, componentItem.y - edgeInsets.top, image.size.width + edgeInsets.right + edgeInsets.left, image.size.height + edgeInsets.bottom + edgeInsets.top);
//            [button setFrame:[self convertComponentFrameWithProject:projectDataSource.project componentFrame:rect contentPadding:contentPadding]];
//            [button setTransform:CGAffineTransformMakeRotation(componentItem.rotate / 180.)];
//        }];
    }
    
    [button addTarget:self action:@selector(componentAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+ (void)setupControlFrame:(UIControl *)control rect:(CGRect)rect {
    
}
#pragma mark -- private func
+ (CGRect)convertComponentFrameWithProject:(ALTProject *)project
                            componentFrame:(CGRect)componentFrame
                            contentPadding:(CGFloat)contentPadding {
    if ([project.videoFit isEqualToString:kContain]) {
        CGFloat scale = 1.;
        if (project.playerWidth > project.playerHeight) {
            // 视频横向全部显示
            scale = project.playerWidth / project.stageWidth.floatValue;
        } else {
            // 视频纵向全部显示
            scale = project.playerHeight / project.stageHeight.floatValue;
        }
        
        CGRect frame = CGRectMake(componentFrame.origin.x * scale - contentPadding , componentFrame.origin.y * scale - contentPadding, componentFrame.size.width * scale + 2 * contentPadding, componentFrame.size.height * scale + 2 * contentPadding);
        return frame;
    } else {
        return CGRectZero;
    }
}

+ (void)componentAction:(UIControl *)control {
    ALTProjectDataSource *dataSource = objc_getAssociatedObject(control ,&kDataSource);
    ALTComponentItem *componentItem  = objc_getAssociatedObject(control ,&kComponentItem);
    ALTPlayerController *callBackController = objc_getAssociatedObject(control ,&kCallBackController);
    for (NSString *eventString in componentItem.eventGroup) {
        [ALTEventRouter executeEventWithEventId:eventString projectDataSource:dataSource eventBlock:^(ALTEventType  _Nonnull eventType, NSDictionary * _Nonnull paramater) {
            [callBackController callEventWithType:eventType paramater:paramater];
        }];
    }
}

@end

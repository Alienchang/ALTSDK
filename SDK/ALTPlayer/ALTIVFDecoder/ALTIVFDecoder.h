//
//  ALTIVFDecoder.h
//  ALTSDK
//
//  Created by Alienchang on 2019/5/13.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ALTProjectDataSource.h"
NS_ASSUME_NONNULL_BEGIN

@interface ALTIVFDecoder : NSObject
- (instancetype)initWithVideoContainWidth:(CGFloat)videoContainWidth
                       videoContainHeight:(CGFloat)videoContainHeight;
- (void)setupVideoContainWidth:(CGFloat)videoContainWidth
            videoContainHeight:(CGFloat)videoContainHeight;
- (BOOL)setupFFmpegWithFilePath:(NSString *)filePath;
- (ALTProjectDataSource *)parseVideoConfigWithIVFPath:(NSString *)ivfPath
                                                 data:(nullable NSData *)sliceData;
@end

NS_ASSUME_NONNULL_END

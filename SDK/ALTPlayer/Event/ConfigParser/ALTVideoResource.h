//
//  ALTResource.h
//  ALTSDK
//
//  Created by Alienchang on 2019/4/1.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALTVideoResource : NSObject
@property (nonatomic ,copy) NSString *videoId;
@property (nonatomic ,copy) NSString *start;
@property (nonatomic ,copy) NSString *end;
@property (nonatomic ,assign) NSTimeInterval endTime;
@property (nonatomic ,assign) NSTimeInterval duration;
// ivf
@property (nonatomic ,copy) NSString *ivfOffset;
@property (nonatomic ,copy) NSString *size;
@property (nonatomic ,assign) NSTimeInterval offsetTime;


/**
 不同码率地址
 */
@property (nonatomic ,copy) NSString *fast;
@property (nonatomic ,copy) NSString *sd;
@property (nonatomic ,copy) NSString *hd;
@property (nonatomic ,copy) NSString *superHd;
@property (nonatomic ,copy) NSString *br;

@end

NS_ASSUME_NONNULL_END

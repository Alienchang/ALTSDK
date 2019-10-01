//
//  ALTVideoEvent.h
//  ALTSDK
//
//  Created by Alienchang on 2019/4/1.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALTEventItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface ALTVideoEvent : NSObject
@property (nonatomic ,copy)   NSString *triggerStart;           // 事件触发事件
@property (nonatomic ,copy)   NSString *triggerEnd;             // 事件最晚触发事件
@property (nonatomic ,strong) NSArray <NSString *>*eventGroup;
/// 自生成
@property (nonatomic ,assign) NSTimeInterval startTime;
@property (nonatomic ,assign) NSTimeInterval endTime;
@end

NS_ASSUME_NONNULL_END

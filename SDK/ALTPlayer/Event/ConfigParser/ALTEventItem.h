//
//  ALTEvent.h
//  ALTSDK
//
//  Created by Alienchang on 2019/3/25.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALTEventConst.h"
NS_ASSUME_NONNULL_BEGIN

@interface ALTEventItem : NSObject

@property (nonatomic ,copy)   NSString *eventId;
@property (nonatomic ,copy)   ALTEventType type;
@property (nonatomic ,strong) NSDictionary *argMap; 


@end

NS_ASSUME_NONNULL_END

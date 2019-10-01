//
//  ALTPlayerController+Event.h
//  ALTSDK
//
//  Created by Alienchang on 2019/4/8.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "ALTPlayerController.h"
#import "Event/ConfigParser/ALTEventConst.h"
NS_ASSUME_NONNULL_BEGIN

@interface ALTPlayerController (Event)
- (void)removeObserver;
- (void)seek:(NSTimeInterval)time;
- (void)callEventWithType:(ALTEventType)eventType
                paramater:(NSDictionary *)parameter;
@end

NS_ASSUME_NONNULL_END

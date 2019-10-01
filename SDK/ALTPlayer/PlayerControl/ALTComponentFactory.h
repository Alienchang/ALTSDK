//
//  ALTComponentFactory.h
//  ALTSDK
//
//  Created by Alienchang on 2019/4/8.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ALTProjectDataSource.h"
#import "ALTComponentItem.h"
#import "ALTPlayerController+Event.h"
NS_ASSUME_NONNULL_BEGIN

@interface ALTComponentFactory : NSObject
+ (UIControl *)generateControlWithUIID:(NSString *)uiId
                     projectDataSource:(ALTProjectDataSource *)projectDataSource
                    callBackController:(ALTPlayerController *)callBackController;
@end

NS_ASSUME_NONNULL_END

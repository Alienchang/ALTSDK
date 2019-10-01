//
//  ALTHUD.h
//  ALTSDK
//
//  Created by Alienchang on 2019/3/22.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
NS_ASSUME_NONNULL_BEGIN

@interface ALTHUD : MBProgressHUD
+ (instancetype _Nonnull )show;
+ (instancetype _Nonnull )alertWithText:(NSString *)text
                           dismissDelay:(NSInteger)delay;
+ (void)dismiss;
@end

NS_ASSUME_NONNULL_END

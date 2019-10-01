//
//  ALTHUD.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/22.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "ALTHUD.h"

@implementation ALTHUD
+ (instancetype _Nonnull )show {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (window) {
        ALTHUD *hud = [ALTHUD showHUDAddedTo:window animated:YES];
        return hud;
    } else {
        return nil;
    }
    
}

+ (instancetype _Nonnull )alertWithText:(NSString *)text
                           dismissDelay:(NSInteger)delay {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (window) {
        ALTHUD *hud = [ALTHUD showHUDAddedTo:window animated:YES];
        [hud setMode:MBProgressHUDModeText];
        [hud.label setText:text];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ALTHUD dismiss];
        });
        return hud;
    } else {
        return nil;
    }
}

+ (void)dismiss {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [ALTHUD hideHUDForView:window animated:YES];
}
@end

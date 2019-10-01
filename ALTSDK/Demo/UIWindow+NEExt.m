//
//  UIWindow+NEExt.m
//  MeMe
//
//  Created by Chang Liu on 11/23/17.
//  Copyright © 2017 sip. All rights reserved.
//

#import "UIWindow+NEExt.h"

@implementation UIWindow (NEExt)

+ (UIEdgeInsets)keyWindowSafeAreaInsets {
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        if (!window && UIApplication.sharedApplication.windows.count) {
            window = UIApplication.sharedApplication.windows[0];
        }
        return window.safeAreaInsets;
    } else {
        return UIEdgeInsetsZero;
    }
}
@end

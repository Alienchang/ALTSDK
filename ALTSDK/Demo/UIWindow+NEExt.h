//
//  UIWindow+NEExt.h
//  MeMe
//
//  Created by Chang Liu on 11/23/17.
//  Copyright © 2017 sip. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (NEExt)
@property (nonatomic, assign, readonly) UIEdgeInsets safeAreaInsets;
+ (UIEdgeInsets)keyWindowSafeAreaInsets;
@end

//
//  NECommonMacro.h
//  NESocialClient
//
//  Created by Mingde on 2017/10/18.
//  Copyright © 2017年 Next Entertainment. All rights reserved.
//

#import "AppDelegate.h"

/// Transform: 由角度获取弧度
#define Transform_DegreesToRadian(x)                            (M_PI * (x) / 180.0)

/// Transform: 有弧度获取角度
#define Transform_RadianToDegrees(radian)                       (radian*180.0)/(M_PI)

/// MainScreenBounds
#define NE_MainScreenBounds                                     [UIScreen mainScreen].bounds

/// MainScreenSize
#define NE_MainScreenSize                                       [UIScreen mainScreen].bounds.size
#define NE_ScreenWith                                           [UIScreen mainScreen].bounds.size.width
#define NE_ScreenHeight                                         [UIScreen mainScreen].bounds.size.height
/// iPhone4 / 5 Width
#define kSmallScreenWidth                                       (320)

/// 是小屏幕
#define IsSmallScreenWidth                                      (MainScreenWidth<=kSmallScreenWidth)

#define kStatusBarHeight                    [UIApplication sharedApplication].statusBarFrame.size.height
#define kNavigationBarNetHight             44.0
#define kNavigationBarHight                 (kStatusBarHeight + kNavigationBarNetHight)

/// 时间
#define kSecond                 (1)
#define kMinute                 (60)
#define kHour                   (60*60UL)
#define kDay                    (24*60*60UL)
#define kMonth                  (30*24*60*60UL)
#define kSeconds(n)             (n)
#define kMinutes(n)             (kMinute*(n))
#define kHours(n)               (kHour*(n))
#define kDays(n)                (kDay*(n))
#define kMonths(n)              (kMonth*(n))

#define PageCount               (20)
/// WeakSelf
#define ALTWeakSelf                                             __weak typeof(self) weakSelf = self

/// 是否是在主线程
#define NSAssertMainThread()                                    NSAssert([NSThread isMainThread], @"thread error")

/// 全局访问AppDelegate
#define AppDelegateShared                                       ((AppDelegate *)[UIApplication sharedApplication].delegate)

/// 全局访问系统版本
#define IOSVersion                                              ([[[UIDevice currentDevice] systemVersion] floatValue])

/// NSObject不为空
#define ObjectIsNotNull(obj)                                    (nil != obj && ![obj isEqual:[NSNull null]])

/// String不为空
#define StringIsNotNull(obj)                                    (ULObjectIsNotNull(obj) && [obj isKindOfClass:NSString.class] && obj.length>0)

#define TDescription(code)   [MGRPCInterceptor description: code]
//
// Macros for debugging
//
#ifndef NEDLog
#ifdef DEBUG
#define NEDLog(...) NSLog(__VA_ARGS__)
#else
#define NEDLog(...) /* */
#endif // DEBUG
#endif // DLog

#define NESetUserDefaults(key, objc)        do { \
[[NSUserDefaults standardUserDefaults] setObject:(objc) forKey:(key)]; \
[[NSUserDefaults standardUserDefaults] synchronize]; \
} while(0)
#define NEUserDefaults(key)                 [[NSUserDefaults standardUserDefaults] objectForKey:(key)]

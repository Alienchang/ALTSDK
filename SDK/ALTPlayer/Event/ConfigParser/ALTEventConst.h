//
//  ALTEventConst.h
//  ALTSDK
//
//  Created by Alienchang on 2019/4/9.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kALTSwitchBranck = @"ALTSDK://event/switch/branch";
static NSString * const kALTVideoSeek    = @"ALTSDK://event/seek";
static NSString * const kALTButtonHide   = @"ALTSDK://button/hide";
static NSString * const kALTButtonShow   = @"ALTSDK://button/show";

typedef NSString * ALTEventType NS_STRING_ENUM;
FOUNDATION_EXPORT ALTEventType const kVideoPlay;
FOUNDATION_EXPORT ALTEventType const kVideoPause;
FOUNDATION_EXPORT ALTEventType const kVideoResume;
FOUNDATION_EXPORT ALTEventType const kVideoVolume;
FOUNDATION_EXPORT ALTEventType const kVideoLoop;
FOUNDATION_EXPORT ALTEventType const kAudioPlay;
FOUNDATION_EXPORT ALTEventType const kAudioPause;
FOUNDATION_EXPORT ALTEventType const kAudioResume;
FOUNDATION_EXPORT ALTEventType const kAudioVolume;
FOUNDATION_EXPORT ALTEventType const kUIShow;
FOUNDATION_EXPORT ALTEventType const kUIHide;
FOUNDATION_EXPORT ALTEventType const kUIStateChange;
FOUNDATION_EXPORT ALTEventType const kWebOpen;
FOUNDATION_EXPORT ALTEventType const kWebClose;
FOUNDATION_EXPORT ALTEventType const kVarUpdate;
FOUNDATION_EXPORT ALTEventType const kCondition;
FOUNDATION_EXPORT ALTEventType const kVideoPreload;

typedef NSString * ALTContenFitType NS_STRING_ENUM;
FOUNDATION_EXPORT ALTContenFitType const kContain;
FOUNDATION_EXPORT ALTContenFitType const kCover;



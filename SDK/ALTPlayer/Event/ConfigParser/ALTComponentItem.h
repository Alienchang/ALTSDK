//
//  ALTComponentItem.h
//  ALTSDK
//
//  Created by Alienchang on 2019/4/1.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, ALT_COMPOMEMT_EFFECT) {
    ALT_COMPOMEMT_ENTER_EFFECT_DEFAULT = 0,
};


@interface ALTComponentItem : NSObject
@property (nonatomic ,copy)   NSString *buttonId;
@property (nonatomic ,copy)   NSString *offset;
@property (nonatomic ,copy)   NSString *note;
@property (nonatomic ,assign) CGFloat  duration;
@property (nonatomic ,copy)   NSString *perloadingType;
@property (nonatomic ,copy)   NSString *interactionType;
@property (nonatomic ,copy)   NSString *condition;
@property (nonatomic ,copy)   NSString *eventFial;
@property (nonatomic ,strong) NSArray  *eventTimeout;
@property (nonatomic ,copy)   NSString *zIndex;
@property (nonatomic ,assign) CGFloat x;
@property (nonatomic ,assign) CGFloat y;
@property (nonatomic ,assign) CGFloat width;
@property (nonatomic ,assign) CGFloat height;
@property (nonatomic ,assign) CGFloat rotate;
@property (nonatomic ,assign) CGFloat alpha;
@property (nonatomic ,copy)   NSString *picNormal;
@property (nonatomic ,copy)   NSString *picPressed;
@property (nonatomic ,copy)   NSString *intoViewEffect;
@property (nonatomic ,copy)   NSString *showEffect;
@property (nonatomic ,copy)   NSString *hideEffect;
@property (nonatomic ,copy)   NSString *successEffect;
@property (nonatomic ,strong) NSArray  *eventGroup;

//@property (nonatomic ,assign) ALT_COMPOMEMT_EFFECT enterEffect;
//@property (nonatomic ,assign) ALT_COMPOMEMT_EFFECT showEffect;
//@property (nonatomic ,assign) ALT_COMPOMEMT_EFFECT hideEffect;
//@property (nonatomic ,assign) ALT_COMPOMEMT_EFFECT successEffect;
@end

NS_ASSUME_NONNULL_END

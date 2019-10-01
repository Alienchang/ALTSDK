//
//  ALTButton.h
//  ALTSDK
//
//  Created by Alienchang on 2019/4/9.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NEImage/NEImage.h>
#import "ALTComponentProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALTButton : UIButton <ALTComponentProtocol>
@property (nonatomic ,assign) CGFloat duration;
@property (nonatomic ,strong) ALTProjectDataSource *projectDataSource;
@property (nonatomic ,strong) ALTComponentItem *componentItem;
@end

NS_ASSUME_NONNULL_END

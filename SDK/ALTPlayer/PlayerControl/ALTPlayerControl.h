//
//  ALTPlayerControl.h
//  ALTSDK
//
//  Created by Alienchang on 2019/6/5.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALTPlayerControl : UIView
@property (nonatomic ,strong) UIButton *playButton;
@property (nonatomic ,strong) UILabel  *timeLabel;
@property (nonatomic ,strong) UIButton *nextButton;
@property (nonatomic ,strong) UIButton *audioButton;
@property (nonatomic ,strong) UIButton *fullScreenButton;

@end

NS_ASSUME_NONNULL_END

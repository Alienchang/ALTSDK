//
//  EventMessageCell.h
//  ALTSDK
//
//  Created by Alienchang on 2019/6/4.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EventMessageCell : UITableViewCell
@property (nonatomic ,strong) UILabel *timeLabel;
@property (nonatomic ,strong) UILabel *eventLabel;
@end

NS_ASSUME_NONNULL_END

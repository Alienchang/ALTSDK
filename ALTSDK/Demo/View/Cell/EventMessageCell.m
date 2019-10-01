//
//  EventMessageCell.m
//  ALTSDK
//
//  Created by Alienchang on 2019/6/4.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "EventMessageCell.h"

@implementation EventMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.eventLabel];
        [self.timeLabel setFrame:CGRectMake(10, 3, 100, 15)];
        [self.eventLabel setFrame:CGRectMake(110, 3, 200, 15)];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setBackgroundColor:[UIColor colorWithRed:31 /255. green:30 /255. blue:29 /255. alpha:1]];
    }
    return self;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        [_timeLabel setFont:[UIFont systemFontOfSize:14]];
        [_timeLabel setTextColor:[UIColor redColor]];
    }
    return _timeLabel;
}

- (UILabel *)eventLabel {
    if (!_eventLabel) {
        _eventLabel = [UILabel new];
        [_eventLabel setFont:[UIFont systemFontOfSize:14]];
        [_eventLabel setTextColor:[UIColor greenColor]];
    }
    return _eventLabel;
}
@end

//
//  PreloadCell.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/27.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "PreloadCell.h"

@implementation PreloadCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.progressLabel];
        [self.contentView addSubview:self.urlLabel];
        [self.urlLabel setFrame:CGRectMake(0, 0, 200, 44)];
        [self.progressLabel setFrame:CGRectMake(200, 0, 80, 44)];
    }
    return self;
}
#pragma mark -- getter
- (UILabel *)urlLabel {
    if (!_urlLabel) {
        _urlLabel = [UILabel new];
        [_urlLabel setTextAlignment:NSTextAlignmentCenter];
        [_urlLabel setNumberOfLines:0];
        [_urlLabel setLineBreakMode:NSLineBreakByWordWrapping];
    }
    return _urlLabel;
}

- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [UILabel new];
        [_progressLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _progressLabel;
}
@end

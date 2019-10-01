//
//  VideoCell.m
//  ALTSDK
//
//  Created by Alienchang on 2019/6/3.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "VideoCell.h"

@implementation VideoCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.coverImageView];
//        [self.contentView addSubview:self.coverView];
        [self.contentView addSubview:self.operationButton];
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        [self setBackgroundColor:[UIColor colorWithRed:36. /255 green:37. /255 blue:38. /255 alpha:1]];
        [self.coverImageView addSubview:self.fileNameLabel];
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = width * 2 / 3;
        [self.coverImageView setFrame:CGRectMake(0, 0, width, height)];
        [self.fileNameLabel setFrame:CGRectMake(5, height - 50 - 30, width - 10, 40)];
        [self.coverView setFrame:CGRectMake(0, 0, width, height)];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [self.operationButton setFrame:CGRectMake(width - 40, 20, 50, 50)];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}
#pragma mark -- public
- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        [self.coverView setHidden:YES];
    } else {
        [self.coverView setHidden:NO];
    }
}
#pragma mark -- getter
- (UILabel *)fileNameLabel {
    if (!_fileNameLabel) {
        _fileNameLabel = [UILabel new];
        [_fileNameLabel setFont:[UIFont systemFontOfSize:15 weight:UIFontWeightBold]];
        [_fileNameLabel setTextColor:[UIColor colorWithWhite:0.8 alpha:0.7]];
        [_fileNameLabel setNumberOfLines:0];
        [_fileNameLabel setLineBreakMode:NSLineBreakByWordWrapping];
    }
    return _fileNameLabel;
}
- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [UIView new];
        [_coverView setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:0.5]];
    }
    return _coverView;
}

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [UIImageView new];
        [_coverImageView setBackgroundColor:[UIColor colorWithRed:41. /255 green:42. /255 blue:47. /255 alpha:1]];
        [_coverImageView setContentMode:UIViewContentModeScaleAspectFill];
    }
    return _coverImageView;
}

- (UIButton *)operationButton {
    if (!_operationButton) {
        _operationButton = [UIButton new];
        [_operationButton setTitle:@"..." forState:UIControlStateNormal];
        [_operationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_operationButton addTarget:self action:@selector(moreOperationAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _operationButton;
}

+ (CGFloat)cellHeight {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = screenWidth * 2 / 3;
    return height + 10;
}

#pragma mark -- private func
- (void)moreOperationAction {
    if (self.moreButtonBlock) {
        self.moreButtonBlock();
    }
}
@end

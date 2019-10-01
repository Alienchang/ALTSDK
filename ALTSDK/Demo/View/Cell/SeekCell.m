//
//  SeekCell.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/22.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "SeekCell.h"
@interface SeekCell()
@property (nonatomic ,strong) UITextField *textField;
@property (nonatomic ,strong) UIButton    *confirmButton;
@end

@implementation SeekCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.textField];
        [self.contentView addSubview:self.confirmButton];
        [self.textField setFrame:CGRectMake(10, 0, 200, 44)];
        [self.confirmButton setFrame:CGRectMake(CGRectGetMaxX(self.textField.frame), 0, 50, 44)];
        
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -- getter
- (UITextField *)textField {
    if (!_textField) {
        _textField = [UITextField new];
        [_textField setPlaceholder:@"seek at a time"];
        [_textField setKeyboardType:UIKeyboardTypeNumberPad];
    }
    return _textField;
}
- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton new];
        [_confirmButton setBackgroundColor:[UIColor redColor]];
        [_confirmButton setTitle:@"seek" forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(seekAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (void)seekAction {
    if (self.seekBlock) {
        self.seekBlock(_textField.text.integerValue);
    }
}
@end

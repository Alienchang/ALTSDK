//
//  TextFieldCell.m
//  ALTSDK
//
//  Created by Alienchang on 2019/5/20.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "TextFieldCell.h"
#import "ALTCommonMacro.h"
@implementation TextFieldCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.textField];
        [self.textField setFrame:CGRectMake(0, 0, NE_ScreenWith - 80, 44)];
        [self.contentView addSubview:self.confirmButton];
        [self.confirmButton setFrame:CGRectMake(NE_ScreenWith - 70, 0, 70, 44)];
    }
    return self;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [UITextField new];
        [_textField setPlaceholder:@"input video source url"];
        NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:@"url"];
        if (url.length) {
            [_textField setText:url];
        }
    }
    return _textField;
}
- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton new];
        [_confirmButton setBackgroundColor:[UIColor redColor]];
        [_confirmButton addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
        [_confirmButton setTitle:@"播放" forState:UIControlStateNormal];
    }
    return _confirmButton;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)buttonAction {
    if (self.confirmBlock) {
        self.confirmBlock(self.textField.text);
        [[NSUserDefaults standardUserDefaults] setObject:self.textField.text forKey:@"url"];
    }
}
@end

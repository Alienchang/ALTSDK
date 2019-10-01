//
//  UIAlertController+NEExt.m
//  NESocialClient
//
//  Created by Chang Liu on 5/14/18.
//  Copyright © 2018 Next Entertainment. All rights reserved.
//

#import "UIAlertController+NEExt.h"

@implementation UIAlertController (NEExt)
- (void)addCancelActionWithText:(NSString *)text
                      textColor:(UIColor *)textColor
                           font:(UIFont *)font
                      alignment:(NSTextAlignment)alignment
                          click:(void(^)(UIAlertAction *alertAction))click {
    UIAlertAction *action = [UIAlertAction actionWithTitle:text style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (click) {
            click(action);
        }
    }];
    if (textColor) {
        [action setValue:textColor forKey:@"titleTextColor"];
    }
    [action setValue:[NSNumber numberWithInteger:alignment] forKey:@"titleTextAlignment"];
    [self addAction:action];
}

- (void)addConfirmActionWithText:(NSString *)text
                       textColor:(UIColor *)textColor
                            font:(UIFont *)font
                       alignment:(NSTextAlignment)alignment
                           click:(void(^)(UIAlertAction *alertAction))click {
    UIAlertAction *action = [UIAlertAction actionWithTitle:text style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (click) {
            click(action);
        }
    }];
    if (textColor) {
        [action setValue:textColor forKey:@"titleTextColor"];
    }
    [action setValue:[NSNumber numberWithInteger:alignment] forKey:@"titleTextAlignment"];
    [self addAction:action];
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle {
    [self setValue:attributedTitle forKey:@"attributedTitle"];
}
- (void)setAttributedMessage:(NSAttributedString *)attributedMessage {
    [self setValue:attributedMessage forKey:@"attributedMessage"];
}
@end

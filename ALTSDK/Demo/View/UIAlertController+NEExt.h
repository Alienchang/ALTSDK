//
//  UIAlertController+NEExt.h
//  NESocialClient
//
//  Created by Chang Liu on 5/14/18.
//  Copyright © 2018 Next Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (NEExt)
- (void)addCancelActionWithText:(NSString *)text
                      textColor:(UIColor *)textColor
                           font:(UIFont *)font
                      alignment:(NSTextAlignment)alignment
                          click:(void(^)(UIAlertAction *alertAction))click;

- (void)addConfirmActionWithText:(NSString *)text
                       textColor:(UIColor *)textColor
                            font:(UIFont *)font
                       alignment:(NSTextAlignment)alignment
                           click:(void(^)(UIAlertAction *alertAction))click;

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle;
- (void)setAttributedMessage:(NSAttributedString *)attributedMessage;

@end

//
//  TextFieldCell.h
//  ALTSDK
//
//  Created by Alienchang on 2019/5/20.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TextFieldCell : UITableViewCell
@property (nonatomic ,strong) UITextField *textField;
@property (nonatomic ,copy)  void(^confirmBlock)(NSString *text);
@property (nonatomic ,strong) UIButton *confirmButton;
@end

NS_ASSUME_NONNULL_END

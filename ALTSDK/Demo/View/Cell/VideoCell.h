//
//  VideoCell.h
//  ALTSDK
//
//  Created by Alienchang on 2019/6/3.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NEImage/NEImage.h>
NS_ASSUME_NONNULL_BEGIN

@interface VideoCell : UITableViewCell
@property (nonatomic ,strong) UIView      *coverView;
@property (nonatomic ,strong) UIImageView *coverImageView;
@property (nonatomic ,strong) UIButton    *operationButton;
@property (nonatomic ,strong) UILabel     *fileNameLabel;
@property (nonatomic ,copy)   void(^moreButtonBlock)(void);
+ (CGFloat)cellHeight;
@end

NS_ASSUME_NONNULL_END

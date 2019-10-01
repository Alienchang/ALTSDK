//
//  SeekCell.h
//  ALTSDK
//
//  Created by Alienchang on 2019/3/22.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SeekCell : UITableViewCell
@property (nonatomic ,strong) void(^seekBlock)(NSTimeInterval time);
@end

NS_ASSUME_NONNULL_END

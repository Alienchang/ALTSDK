//
//  PlayByIdCell.h
//  ALTSDK
//
//  Created by Alienchang on 2019/4/23.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayByIdCell : UITableViewCell
@property (nonatomic ,strong) UITextField *projectTextField;
@property (nonatomic ,strong) UITextField *episodeTextField;
@property (nonatomic ,strong) UIButton    *playButton;
@end

NS_ASSUME_NONNULL_END

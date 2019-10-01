//
//  VideoPreviewController.h
//  ALTSDK
//
//  Created by Alienchang on 2019/6/3.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoPreviewController : UIViewController
@property (nonatomic ,copy) NSString *videoUrl;
@property (nonatomic ,strong) UIImageView *imageView;
@end

NS_ASSUME_NONNULL_END

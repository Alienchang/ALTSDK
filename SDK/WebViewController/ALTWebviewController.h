//
//  ALTWebviewController.h
//  ALTSDK
//
//  Created by Alienchang on 2019/3/20.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALTWebviewController : UIViewController
@property (nonatomic ,readonly) NSString *url;
@property (nonatomic ,strong) void(^webPageCallback)(NSString *funcName ,id paramater);
- (void)requestWithUrl:(NSString *)url;
- (void)showIn:(UIView *)view;
- (void)dismiss;
@end

NS_ASSUME_NONNULL_END

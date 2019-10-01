//
//  ALTWebViewJSBridge.h
//  ALTSDK
//
//  Created by Alienchang on 2019/3/20.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALTWebViewJSBridge : NSObject
@property (nonatomic ,strong) void(^webPageCallback)(NSString *funcName ,id paramater);
- (void)loadJavascriptBridge:(WKWebView *)webView;
@end

NS_ASSUME_NONNULL_END

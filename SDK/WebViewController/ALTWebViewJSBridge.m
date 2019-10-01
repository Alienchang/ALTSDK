//
//  ALTWebViewJSBridge.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/20.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "ALTWebViewJSBridge.h"
#import <WebViewJavascriptBridge/WKWebViewJavascriptBridge.h>
#import "ALTWebBridgeFuncDefinition.h"

@interface ALTWebViewJSBridge()<WKNavigationDelegate, WKUIDelegate>
@property (nonatomic ,strong) WKWebViewJavascriptBridge *bridge;
@property (nonatomic ,strong) NSArray <NSString *>*jsFunctions;
@end
@implementation ALTWebViewJSBridge
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setJsFunctions:@[kEvent]];
    }
    return self;
}

- (void)loadJavascriptBridge:(WKWebView *)webView {
    if (!webView) {
        return;
    }
    self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:webView];
    [self.bridge setWebViewDelegate:self];
    [self registerHandle];
//    [self.bridge registerHandler:kReplayVideo handler:^(id data, WVJBResponseCallback responseCallback) {
//        /// do something with data
//        responseCallback(@"hello");
//    }];
}

#pragma mark -- WKWebViewDelegate
/// 页面加载finish调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
}

/// 页面加载失败调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
}

/// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}

/// alert
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
}

/// confirt
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    
}

/// input text
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    
}

/// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

/// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *urlString = navigationAction.request.URL.absoluteString;
    NSString *scheme = navigationAction.request.URL.scheme;
    
    if ([urlString hasPrefix:@"itms-apps://itunes.apple.com"]   ||
        [urlString hasPrefix:@"https://itunes.apple.com"]       ||
        [urlString hasPrefix:@"itms-services:"]                 ||
        
        [scheme isEqualToString:@"tel"]                         ||
        [scheme isEqualToString:@"mailto"]                      ||
        [scheme isEqualToString:@"sms"]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)registerHandle {
    for (NSString *functionName in self.jsFunctions) {
        [self.bridge registerHandler:functionName handler:^(id data, WVJBResponseCallback responseCallback) {
            if (self.webPageCallback) {
                self.webPageCallback(functionName, data);
            }
        }];
    }
}
@end

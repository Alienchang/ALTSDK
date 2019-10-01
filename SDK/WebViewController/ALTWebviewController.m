//
//  ALTWebviewController.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/20.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "ALTWebviewController.h"
#import <WebKit/WebKit.h>
#import <WebViewJavascriptBridge/WKWebViewJavascriptBridge.h>
#import "ALTWebViewJSBridge.h"
#import "ALTEventRouter.h"
#import "ALTWebBridgeFuncDefinition.h"


NSString *kEstimatedProgress = @"estimatedProgress";
NSString *kTitle = @"title";

@interface ALTWebviewController ()
@property (nonatomic ,strong) WKWebView          *webView;
@property (nonatomic ,strong) UIProgressView     *progressView;
@property (nonatomic, strong) ALTWebViewJSBridge *jsBridge;
@end

@implementation ALTWebviewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self.jsBridge loadJavascriptBridge:self.webView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
    [self.webView setFrame:self.view.bounds];
    [self.progressView setFrame:CGRectMake(0, 0, width, 3)];
}
#pragma mark -- public
- (void)showIn:(UIView *)view {
    [view addSubview:self.view];
    [self.view setFrame:self.view.bounds];
}
- (void)dismiss {
    [self.view removeFromSuperview];
}
- (void)requestWithUrl:(NSString *)url {
    _url = [url copy];
    NSURL *tempUrl = [NSURL URLWithString:self.url];
    NSURLRequest *webRequestUrl = [NSURLRequest requestWithURL:tempUrl];
    [self.webView loadRequest:webRequestUrl];
}
#pragma mark -- private
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:[NSString stringWithString:kEstimatedProgress]]) {
        [self.progressView setAlpha:1.0];
        CGFloat estimatedProgress = [[change valueForKey:@"new"] floatValue];
        [self.progressView setProgress:estimatedProgress animated:YES];
        if (estimatedProgress >= 1.f) {
            [self.progressView setAlpha:0.f];
            [self.progressView setProgress:0.f animated:NO];
        }
    }
}

/**
 执行jsBridge 事件
 */
- (void)setupBridgeCallBack {
    __weak typeof(self) weakSelf = self;
    [self.jsBridge setWebPageCallback:^(NSString * _Nonnull funcName, id  _Nonnull paramater) {
       if ([funcName isEqualToString:kEvent]) {
           NSString *eventType = paramater[@"eventType"];
           if (weakSelf.webPageCallback) {
               weakSelf.webPageCallback(funcName, paramater);
           }
           [ALTEventRouter executeEventWithEventTypeString:eventType object:paramater];
       }
    }];
}
#pragma mark -- getter
- (ALTWebViewJSBridge *)jsBridge {
    if (!_jsBridge) {
        _jsBridge = [[ALTWebViewJSBridge alloc] init];
        [self setupBridgeCallBack];
    }
    
    return _jsBridge;
}
- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        [_progressView setProgress:0.0f animated:NO];
        [_progressView setProgressTintColor:[UIColor redColor]];
        [_progressView setTrackTintColor:[UIColor clearColor]];
    }
    return _progressView;
}
- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *configure = [WKWebViewConfiguration new];
        [configure setAllowsInlineMediaPlayback:YES];
        
        if (@available(iOS 10.0, *)) {
            configure.mediaTypesRequiringUserActionForPlayback = false;
        } else {
            // Fallback on earlier versions
        }
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configure];
        [_webView setAllowsBackForwardNavigationGestures:YES];
        [_webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [_webView addObserver:self forKeyPath:kEstimatedProgress options:NSKeyValueObservingOptionNew context:NULL];
        [_webView addObserver:self forKeyPath:kTitle options:NSKeyValueObservingOptionNew context:NULL];
    }
    return _webView;
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:kEstimatedProgress];
    [self.webView removeObserver:self forKeyPath:kTitle];
}
@end

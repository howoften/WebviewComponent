//
//  OAuthManager.m
//  Pods-WebviewComponent_Example
//
//  Created by 刘江 on 2019/8/8.
//

#import "LLOAuthManager.h"
#import "LLWebViewHelper.h"
#import "LLOAuthTranslater.h"

#define kOAuthURL_test @"https://open.test.brightcns.cn/api/oauth/authorize"
#define kOAuthURL_product @"https://open.brightcns.com/api/oauth/authorize"

@interface LLOAuthManager ()
@property (nonatomic, strong)UIAlertController *alertVC;

@property (nonatomic, weak)UIViewController *currentViewController;
@property (nonatomic, strong)NSMutableArray *filterArray;

@property (nonatomic, weak)id delegate;
@property (nonatomic, strong)NSString *requestURLString;
@end

@implementation LLOAuthManager
//08c1b2fa62d3670d91e66572300190d2
+ (LLOAuthManager *)share {
    static LLOAuthManager *mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[LLOAuthManager alloc] init];
        mgr.filterArray = [NSMutableArray arrayWithCapacity:0];
    });
    return mgr;
}

+ (BOOL)canResponseForWebviewNavigationAction:(WKNavigationAction *)navigationAction {
     NSString *urlString = [navigationAction.request.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return (([urlString hasPrefix:kOAuthURL_test] || [urlString hasPrefix:kOAuthURL_product]) && [[self share].delegate respondsToSelector:@selector(webViewAuthTokenForRequestParameter:didFinished:)]);
}

+ (void)decidePolicyForViewController:(__kindof UIViewController *)viewController webView:(WKWebView *)webView navigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([self share].alertVC.presentingViewController || [self isWebViewLimited:webView]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    NSString *urlString = [navigationAction.request.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Defence web oauth request: \n%@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    [self share].currentViewController = viewController;
    
    if (([urlString hasPrefix:kOAuthURL_test] || [urlString hasPrefix:kOAuthURL_product]) && [[self share].delegate respondsToSelector:@selector(webViewAuthTokenForRequestParameter:didFinished:)]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        UIViewController<LLWebViewOAuthCoordinateProtocol> *currentVC = viewController.childViewControllers.lastObject;
        currentVC.isAuthPage = YES;
        NSDictionary *param = [LLWebViewHelper requestParameterForURL:url];
        NSMutableDictionary *escapeParam = [param mutableCopy];
        [escapeParam setObject:[param[@"redirectUri"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]] forKey:@"redirectUri"];
        [[self share].filterArray addObject:@{
                                              @"webview":webView,
                                              @"url":urlString,
                                              @"param":[escapeParam copy],
                                              }];
//        [self share].currentView = webView;
        if ([[NSString stringWithFormat:@"%@", param[@"scope"]] isEqualToString:@"auth_userinfo"]) {
           if (viewController.navigationController) {
                [viewController.navigationController presentViewController:[self share].alertVC animated:YES completion:nil];
           }else {
               [viewController presentViewController:[self share].alertVC animated:YES completion:nil];
           }
            
        }else {
            [[self share] ensureOauthAction:@{
                                              @"webview":webView,
                                              @"url":urlString,
                                              @"param":[escapeParam copy],
                                              }];
        }

    }else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    
}

- (void)ensureOauthAction:(NSDictionary *)info {
    if ([self.delegate respondsToSelector:@selector(webViewAuthTokenForRequestParameter:didFinished:)]) {
        [self.delegate webViewAuthTokenForRequestParameter:info[@"param"] didFinished:^(NSString *token) {
            [LLOAuthTranslater translateAccessTokenWithRequestURL:self.requestURLString accessToken:token param:info[@"param"] didFinished:^(id resp) {
                if ([resp isKindOfClass:[NSDictionary class]] && resp[@"bizResp"][@"redirectUri"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([self.currentViewController respondsToSelector:@selector(webviewOAuthDidFinishedWithRedirectURL:)]) {
                            [(UIViewController <LLWebViewOAuthCoordinateProtocol> *)self.currentViewController webviewOAuthDidFinishedWithRedirectURL:resp[@"bizResp"][@"redirectUri"]];
                        }else {
                            NSURLRequest *authRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:resp[@"bizResp"][@"redirectUri"]]];
                            [(WKWebView *)info[@"webview"] loadRequest:authRequest];
                        }
                        
                    });
                    
                }else {
                    if ([self.delegate respondsToSelector:@selector(webViewOAuthDidFailWithInfo:)]) {
                        [self.delegate webViewOAuthDidFailWithInfo:resp];
                    }
                }
            }];
        }];
    }else {
            if ([self.delegate respondsToSelector:@selector(webViewOAuthDidFailWithInfo:)]) {
                [self.delegate webViewOAuthDidFailWithInfo:@{@"code":@"NO_OAUTH_DELEGATE", @"msg":@"there is no an available delegate for web oauth"}];
            }
        }
    [self.filterArray removeObject:info];
}

+ (BOOL)isWebViewLimited:(WKWebView *)webView {
    __block BOOL flag = NO;
    [[[self share].filterArray copy] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj[@"webview"] == webView) {
            flag = YES;
        }
    }];
    return flag;
}

+ (void)setWebViewOAuthRequestURL:(NSString *)URL delegate:(id<LLWebViewOAuthDelegate>)delegate {
    [self share].delegate = delegate;
    [self share].requestURLString = URL;
}

- (UIAlertController *)alertVC {
    if (!_alertVC) {
        _alertVC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"此网页想获取您的用户信息" preferredStyle:UIAlertControllerStyleAlert];
     
        [_alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            
        }]];
        
        [_alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self ensureOauthAction:self.filterArray.lastObject];
            
        }]];
    }
    return _alertVC;
}
@end

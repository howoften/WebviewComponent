//
//  OAuthManager.h
//  Pods-WebviewComponent_Example
//
//  Created by 刘江 on 2019/8/8.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@protocol LLWebViewOAuthDelegate <NSObject>

@required
- (void)webViewAuthTokenForRequestParameter:(NSDictionary *)parameter didFinished:(void(^)(NSString *accessToken))finished;
- (void)webViewOAuthDidFailWithInfo:(NSDictionary *)info;

@end

@interface LLOAuthManager : NSObject
+ (BOOL)canResponseForWebviewNavigationAction:(WKNavigationAction *)navigationAction;
+ (void)decidePolicyForViewController:(__kindof UIViewController *)viewController webView:(WKWebView *)webView navigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;

+ (void)setWebViewOAuthRequestURL:(NSString *)URL delegate:(id<LLWebViewOAuthDelegate>)delegate;

@end


//
//  LLWebViewController.h
//  WebviewComponent
//
//  Created by 刘江 on 2019/7/29.
//

#import <UIKit/UIKit.h>
#import "PAWebView.h"
#import "LLJSMessageNavigationBarHandler.h"
#import "LLOAuthTranslater.h"

@protocol LLWebViewControllerDelegate <NSObject>
- (void)webViewDidReceiveSocialShareForWebView:(WKWebView *)webview webManager:(PAWebView *)webManager;
- (UIViewController *)viewControllerForForwardSkip:(NSURL *)URL title:(NSString *)title shouldShare:(BOOL)shouldShare;
- (void)webViewDidReceiveNavigationAction:(WKNavigationAction *)navigationAction;
@end

extern NSString *const LLWebViewDidCloseNotification;

@interface LLWebViewController : UIViewController<LLJSMessageNavigationActionDelegate, LLWebViewOAuthCoordinateProtocol>
@property (nonatomic, strong)PAWebView *webManager;
@property (nonatomic, weak)id<LLWebViewControllerDelegate> delegate;
@property (nonatomic, strong)UIColor *progressBarTintColor;
@property (nonatomic, strong)UIColor *progressBarTrackTintColor;
@property (nonatomic)BOOL isAuthPage;
@property (nonatomic)BOOL shouldShare;
@property (nonatomic, strong)NSString *constantTitle;
@property (nonatomic)NSUInteger leftBarMode;
@property (nonatomic)NSUInteger rightBarMode;

@property (nonatomic, strong)NSNumber *statusBarStyle;


- (LLWebViewController *)initWithWebView:(WKWebView *)webView webViewManager:(PAWebView *)webMgr title:(NSString *)title URL:(NSURL *)URL;

- (LLWebViewController *)initWithWebView:(WKWebView *)webView webViewManager:(PAWebView *)webMgr title:(NSString *)title fileURL:(NSURL *)fileURL;

- (void)goBack;
- (void)close;
- (void)autoBack;
- (void)goToForwardBackItemAtIndex:(NSUInteger)index;
- (void)gotoRootWebView;
@end


//
//  LLWebViewController.m
//  WebviewComponent
//
//  Created by 刘江 on 2019/7/29.
//

#import "LLWebViewController.h"
#import "LLOAuthManager.h"
#import "UINavigationItem+AttributeTitle.h"
#import "LLWebViewHelper.h"
#import "NSURL+PATool.h"
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define kSafeAreaBottomMargin (([[UIApplication sharedApplication] statusBarFrame].size.height == 44 ? 34 : 0))
#define kNavBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height + 44)

@interface LLWebViewController ()<WKNavigationDelegate, WKUIDelegate>
@property (nonatomic, strong)WKWebView *webview;
@property (nonatomic, strong)NSURL *URL;
@property (nonatomic, strong)NSURL *fileURL;

@property (nonatomic, strong)UILabel *webProvider;
@property (nonatomic, strong)UIView *contentView;

@property (nonatomic)BOOL loaded;
@property (nonatomic)BOOL manualBackFlag;

@property (nonatomic, assign)BOOL webFinished;
@end


NSString *const LLWebViewDidCloseNotification = @"LLWebViewDidCloseNotification";
@implementation LLWebViewController
@synthesize statusBarStyle = _statusBarStyle;

- (LLWebViewController *)initWithWebView:(WKWebView *)webView webViewManager:(PAWebView *)webMgr title:(NSString *)title fileURL:(NSURL *)fileURL; {
    if (self = [super init]) {
        self.webManager = webMgr;
        self.webview = webView;
        self.fileURL = fileURL;
        self.URL = nil;
        self.webview.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        if (title.length > 0) {
            self.navigationItem.attributeTitle = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18*[UIScreen mainScreen].bounds.size.width/375 weight:UIFontWeightMedium], NSForegroundColorAttributeName:[UIColor blackColor]}];
            self.constantTitle = title;
        }
        if (@available(iOS 11.0, *)) {
//            self.webview.scrollView.contentInset = UIEdgeInsetsMake(kNavBarHeight-self.webview.scrollView.contentInset.top, 0, kSafeAreaBottomMargin-self.webview.scrollView.contentInset.bottom, 0);
        }else {
            self.webview.scrollView.contentInset = UIEdgeInsetsMake(kNavBarHeight, 0, kSafeAreaBottomMargin, 0);
        }
        if (_progressBarTintColor) {
            [self.webManager setPaprogressTintColor:_progressBarTintColor];
        }
        if (_progressBarTrackTintColor) {
            [self.webManager setPaprogressTrackTintColor:_progressBarTrackTintColor];
        }
        __weak typeof(self)weakSELF = self;
        self.webManager.shareBlock = ^{
            if ([weakSELF.delegate respondsToSelector:@selector(webViewDidReceiveSocialShareForWebView:webManager:)]) {
                [weakSELF.delegate webViewDidReceiveSocialShareForWebView:weakSELF.webview webManager:weakSELF.webManager];
            }
        };
    }
    return self;
}

- (LLWebViewController *)initWithWebView:(WKWebView *)webView webViewManager:(PAWebView *)webMgr title:(NSString *)title URL:(NSURL *)URL {
    if (self = [super init]) {
        self.webManager = webMgr;
        self.webview = webView;
        self.URL = URL;
        self.fileURL = nil;
        self.webview.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        if (title.length > 0) {
            self.navigationItem.attributeTitle = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18*[UIScreen mainScreen].bounds.size.width/375 weight:UIFontWeightMedium], NSForegroundColorAttributeName:[UIColor blackColor]}];
            self.constantTitle = title;
        }
        if (@available(iOS 11.0, *)) {
            //            self.webview.scrollView.contentInset = UIEdgeInsetsMake(kNavBarHeight-self.webview.scrollView.contentInset.top, 0, kSafeAreaBottomMargin-self.webview.scrollView.contentInset.bottom, 0);
        }else {
            self.webview.scrollView.contentInset = UIEdgeInsetsMake(kNavBarHeight, 0, kSafeAreaBottomMargin, 0);
        }
        if (_progressBarTintColor) {
            [self.webManager setPaprogressTintColor:_progressBarTintColor];
        }
        if (_progressBarTrackTintColor) {
            [self.webManager setPaprogressTrackTintColor:_progressBarTrackTintColor];
        }
        __weak typeof(self)weakSELF = self;
        self.webManager.shareBlock = ^{
            if ([weakSELF.delegate respondsToSelector:@selector(webViewDidReceiveSocialShareForWebView:webManager:)]) {
                [weakSELF.delegate webViewDidReceiveSocialShareForWebView:weakSELF.webview webManager:weakSELF.webManager];
            }
        };
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.contentView];
    [self.webview.scrollView.superview addSubview:self.webProvider];
    [self.webview.scrollView.superview sendSubviewToBack:self.webProvider];
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
    if (self.URL) {
        self.webProvider.text = [NSString stringWithFormat:@"此网页由 %@ 提供", self.URL.host];
    }else if (self.fileURL) {
        self.webProvider.text = self.fileURL.absoluteString;
        self.webProvider.textAlignment = NSTextAlignmentLeft;
    }
    [self.webview addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:nil];
    [self.webview addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [LLJSMessageNavigationBarHandler moreActionsForWebView:^{
        [self.webManager callMenuPageByControl:[LLWebViewHelper topViewController].navigationController];
    }];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000 && TARGET_OS_IOS
    if (@available(iOS 13.0, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
#endif

}

- (void)viewWillAppear:(BOOL)animated {
    if (self.webview.superview != self.contentView) {
        [self.webview removeFromSuperview];
        self.view.backgroundColor = [UIColor colorWithRed:243/255.f green:243/255.f blue:243/255.f alpha:1];
        [self.contentView addSubview:self.webview];
        if (self.URL) {
            [self.webManager loadRequestURL:self.URL];
        }else if (self.fileURL) {
            [self.webManager loadLocalHTMLWithFilePath:self.fileURL.path];
        }
    }
    
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    //     NSLog(@"LLWebViewController %s", _cmd);
}

//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//     NSLog(@"LLWebViewController %s", _cmd);
//}
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//     NSLog(@"LLWebViewController %s", _cmd);
//
//}
//- (void)viewDidDisappear:(BOOL)animated {
//    [super viewDidDisappear:animated];
//    NSLog(@"LLWebViewController %s", _cmd);
//
//}


#pragma mark - WKNavigationDelegate >>>>>>>>>>>>>>>>
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (self.navigationController.topViewController != self) {
        decisionHandler(WKNavigationActionPolicyCancel);
    }else{
        if ([LLOAuthManager canResponseForWebviewNavigationAction:navigationAction]) {
            [LLOAuthManager decidePolicyForViewController:self webView:webView navigationAction:navigationAction decisionHandler:decisionHandler];
        }else if ((![navigationAction.request.URL.absoluteString hasPrefix:@"http"] && ![navigationAction.request.URL.absoluteString hasPrefix:@"file"]) || (([navigationAction.request.URL.absoluteString.lowercaseString containsString:@"itunes.apple"] || [navigationAction.request.URL.absoluteString.lowercaseString containsString:@"itms-appss"]||                [navigationAction.request.URL.absoluteString.lowercaseString containsString:@"itunesconnect.apple.com"]))) {
            [NSURL openURL:navigationAction.request.URL];
            
            decisionHandler(WKNavigationActionPolicyCancel);
        }else if (!self.webFinished && webView.backForwardList.backList.count > 0) {
            decisionHandler(WKNavigationActionPolicyCancel);
        }else if (self.webFinished && ((navigationAction.navigationType == WKNavigationTypeOther && navigationAction.targetFrame.mainFrame) || navigationAction.navigationType == WKNavigationTypeLinkActivated)) {
            UIViewController *next = [self.delegate viewControllerForForwardSkip:navigationAction.request.URL title:self.constantTitle shouldShare:self.shouldShare];
            [self.navigationController pushViewController:next animated:YES];
            decisionHandler(WKNavigationActionPolicyCancel);
        }else {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
    }
    if ([self.delegate respondsToSelector:@selector(webViewDidReceiveNavigationAction:)]) {
        [self.delegate webViewDidReceiveNavigationAction:navigationAction];
    }
//    decisionHandler(WKNavigationActionPolicyAllow);
//    NSLog(@"%@||||%@", NSStringFromSelector(_cmd), navigationAction.request.URL);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
//    NSLog(@"%@", NSStringFromSelector(_cmd));
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
//    NSLog(@"%@", NSStringFromSelector(_cmd));
   
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {

//    NSLog(@"%@", NSStringFromSelector(_cmd));
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    self.manualBackFlag = NO;
    [LLJSMessageNavigationBarHandler layoutWebViewInitialStyle:webView];
    decisionHandler(WKNavigationResponsePolicyAllow);
    
    [LLJSMessageNavigationBarHandler autoNavigationBackButtonForViewController:self webView:webView mode:self.leftBarMode];
    
//    NSLog(@"%@", NSStringFromSelector(_cmd));
}

#pragma mark <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

- (void)webviewOAuthDidFinishedWithRedirectURL:(NSString *)redirectURL {
    if (self.navigationController && [self.delegate respondsToSelector:@selector(viewControllerForForwardSkip:title:shouldShare:)]) {
        UIViewController *next = [self.delegate viewControllerForForwardSkip:[NSURL URLWithString:redirectURL] title:self.constantTitle shouldShare:self.shouldShare];
        [next.navigationItem setHidesBackButton:YES];
        [self.navigationController pushViewController:next animated:YES];
    }else {
        NSURLRequest *authRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:redirectURL]];
        [self.webview loadRequest:authRequest];
    }
}

- (void)goBack {
    self.manualBackFlag = YES;
    if ([self.webview canGoBack]) {
        [self.webview goBack];
    }
}

- (void)close {
    self.manualBackFlag = YES;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:LLWebViewDidCloseNotification object:self.webview];

}

- (void)autoBack {
    self.manualBackFlag = YES;
    if ([self.webview canGoBack]) {
        [self goBack];
    }else if(self.navigationController.childViewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else if (self.navigationController.presentingViewController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void)gotoForwardBackItemAtIndex:(NSUInteger)index {
    if ([self.webview canGoBack] && self.webview.backForwardList.backList.count > index && index > -1) {
        [self.webview goToBackForwardListItem:self.webview.backForwardList.backList[index]];
    }
}

- (void)gotoRootWebView {
    if ([self.webview canGoBack]) {
        [self.webview goToBackForwardListItem:self.webview.backForwardList.backList.firstObject];
    }else {
        [self.webManager reloadFromOrigin];
    }
}

- (void)setProgressBarTintColor:(UIColor *)progressBarTintColor {
    _progressBarTintColor = progressBarTintColor;
    if (_webManager && progressBarTintColor) {
        _webManager.paprogressTintColor = progressBarTintColor;
    }
}

- (void)setProgressBarTrackTintColor:(UIColor *)progressBarTrackTintColor {
    _progressBarTrackTintColor = progressBarTrackTintColor;
    if (_webManager && progressBarTrackTintColor) {
        _webManager.paprogressTrackTintColor = progressBarTrackTintColor;
    }
}

- (UILabel *)webProvider {
    if (!_webProvider) {
        _webProvider = [[UILabel alloc] init];
        _webProvider.textAlignment = NSTextAlignmentCenter;
        _webProvider.font = [UIFont systemFontOfSize:12];
        _webProvider.textColor = [UIColor colorWithRed:150/255.f green:150/255.f blue:150/255.f alpha:1];
        _webProvider.frame = CGRectMake(20, CGRectGetHeight([UIApplication sharedApplication].statusBarFrame)+44, ScreenWidth-20*2, 35);
        
    }
    return _webProvider;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-kSafeAreaBottomMargin)];
        _contentView.backgroundColor = [UIColor clearColor];
        
    }
    return _contentView;
}

- (void)removeObserver:(id)observer {
    [self.webview removeObserver:observer forKeyPath:@"URL"];
    [self.webview removeObserver:observer forKeyPath:@"estimatedProgress"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"URL"]) {
        if (self.manualBackFlag) {
            [LLJSMessageNavigationBarHandler manualDecreaseWeviviewBackItemListForViewController:self webView:self.webview];
        }else {
            [LLJSMessageNavigationBarHandler autoNavigationBackButtonForViewController:self webView:self.webview mode:self.leftBarMode];
        }
    }else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if ([change[NSKeyValueChangeNewKey] floatValue] >= 1) {
            self.webFinished = YES;
            [LLJSMessageNavigationBarHandler autoNavigationBackButtonForViewController:self webView:self.webview mode:self.leftBarMode];
            self.manualBackFlag = NO;
        }else {
            self.webFinished = NO;
        }
    }
    
}

- (void)setStatusBarStyle:(NSNumber *)statusBarStyle {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000 && TARGET_OS_IOS
    if (@available(iOS 13.0, *)) {
        if (statusBarStyle.intValue == UIStatusBarStyleDefault) {
            statusBarStyle = @(UIStatusBarStyleDarkContent);
        }
    }
#endif
    _statusBarStyle = statusBarStyle;
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (![[[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIViewControllerBasedStatusBarAppearance"] boolValue]) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000 && TARGET_OS_IOS
        if (@available(iOS 13.0, *)) {
            if (statusBarStyle.intValue == UIStatusBarStyleDefault) {
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDarkContent animated:NO];
            }
        }else {
            [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle.intValue animated:NO];
        }
#else
        [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle.intValue animated:NO];
#endif
    }
    
}
- (NSNumber *)statusBarStyle {
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000 && TARGET_OS_IOS
    if (@available(iOS 13.0, *)) {
        if (_statusBarStyle.intValue == UIStatusBarStyleDefault) {
            return @(UIStatusBarStyleDarkContent);
        }
    }
#endif
    return _statusBarStyle;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return self.statusBarStyle.intValue;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    
    return UIStatusBarAnimationNone;
}

@end

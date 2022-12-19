//
//  WebviewLoader.m
//  WebviewComponent
//
//  Created by 刘江 on 2019/7/29.
//

#import "LLWebviewLoader.h"
#import "LLModalTransition.h"
#import "LLWebNavigationBar.h"
#import "LLWebViewController.h"
#import "LLWebNavigationController.h"
#import "LLWebJSBridgeManage.h"
#import "LLWebViewHelper.h"
#import "LLJSMessageNavigationBarHandler.h"
#import "DeviceVirtualUUID.h"

@interface LLWebviewLoader ()<WKNavigationDelegate, LLWebJSBridgeMessageDelegate, LLJSMessageNavigationActionDelegate, LLWebViewControllerDelegate, LLJSMessageNavigationActionDelegate>
@property (nonatomic, strong)LLWebNavigationController *currentWebNavigationController;
@property (nonatomic, weak)id<LLWebviewLoaderDelegate> delegate;
@property (nonatomic, strong)NSMutableArray *webNavigationControllerArray;
@property (nonatomic, strong)NSMutableDictionary *modalTransitions;
@property (nonatomic, assign)WebViewNavigationBarStyle navigationBarStyle;

@property (nonatomic, strong)NSMutableArray *originalStatusBarStyles;
@property (nonatomic, strong)UIColor *progressTintColor;
@property (nonatomic, strong)UIColor *progressTrackTintColor;

@property (nonatomic, strong)NSMutableDictionary *URLMeetDictionary;
@end

@implementation LLWebviewLoader

+ (LLWebviewLoader *)shareInstance {
    static LLWebviewLoader *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[LLWebviewLoader alloc] init];
        [LLJSMessageNavigationBarHandler setNavigationBarMessageDelegate:shareInstance];
        [LLJSMessageNavigationBarHandler setWebViewSocialShareMessageDelegate:shareInstance];
//        shareInstance.loadedURLArray = [NSMutableArray arrayWithCapacity:0];
        shareInstance.modalTransitions = [NSMutableDictionary dictionaryWithCapacity:0];
        shareInstance.webNavigationControllerArray = [NSMutableArray arrayWithCapacity:0];
        shareInstance.navigationBarStyle = WebViewNavigationBarStyleDark;
        shareInstance.originalStatusBarStyles = [NSMutableArray arrayWithCapacity:0];
        shareInstance.URLMeetDictionary = [NSMutableDictionary dictionaryWithCapacity:0];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewDidCloseNotification) name:@"LLWebViewDidCloseNotification" object:nil];
        [LLWebJSBridgeManage registerJSBridgeHandlerWithHandlerFile:[LLWebViewHelper filePathForName:@"additionalJSHandler" sourceType:@"plist"]];

    });
    return shareInstance;
}

+ (void)loadWebViewByURL:(NSURL *)URL fromSourceViewController:(UIViewController *)sourceViewController title:(NSString *)title shouleShare:(BOOL)shouldShare transitionStyle:(NSString *)transitionStyle {
    NSAssert([URL isKindOfClass:[NSURL class]], @"[LLWebviewLoader loadWebViewByURL:fromSourceViewController:] fail, because 'URL' is invalid");
    NSAssert(![[LLWebViewHelper topViewController] isKindOfClass:[LLWebNavigationController class]], @"[LLWebviewLoader loadWebViewByURL:fromSourceViewController:] fail, because there is a WebViewVontroller in the screen");
    
    [self shareInstance].currentWebNavigationController = [[self shareInstance] destinationViewControllerForWebURL:URL title:title shouldShare:shouldShare];
    [[self shareInstance].webNavigationControllerArray addObject:[self shareInstance].currentWebNavigationController];
    
    LLModalTransition *transition =[LLModalTransition transitionFromModalStyle:transitionStyle presentedViewController:[self shareInstance].currentWebNavigationController presentingViewController:sourceViewController];
    if (transition) {
        [[self shareInstance].originalStatusBarStyles addObject:@([UIApplication sharedApplication].statusBarStyle)];
        [[self shareInstance].modalTransitions setObject:transition forKey:[NSString stringWithFormat:@"%p", [self shareInstance].currentWebNavigationController]];
        [self shareInstance].currentWebNavigationController.transitioningDelegate = transition;
        NSMutableArray *subArray = [NSMutableArray array];
        [self shareInstance].currentWebNavigationController.modalPresentationCapturesStatusBarAppearance = YES;
        [sourceViewController presentViewController:[self shareInstance].currentWebNavigationController animated:YES completion:nil];
    }

//    [[self shareInstance].loadedURLArray addObject:subArray];
    
    
}

+ (void)loadWebViewByLocalFile:(NSString *)filePath fromSourceViewController:(UIViewController *)sourceViewController title:(NSString *)title shouleShare:(BOOL)shouldShare transitionStyle:(NSString *)transitionStyle {
    NSAssert([filePath isKindOfClass:[NSString class]], @"[LLWebviewLoader loadWebViewByLocalFile:fromSourceViewController:] fail, because 'fileName' is invalid");
    NSAssert(![[LLWebViewHelper topViewController] isKindOfClass:[LLWebNavigationController class]], @"[LLWebviewLoader loadWebViewByURL:fromSourceViewController:] fail, because there is a WebViewVontroller in the screen");
    
    [self shareInstance].currentWebNavigationController = [[self shareInstance] destinationViewControllerForWebFile:filePath title:title shouldShare:shouldShare];
    [[self shareInstance].webNavigationControllerArray addObject:[self shareInstance].currentWebNavigationController];
    
    LLModalTransition *transition =[LLModalTransition transitionFromModalStyle:transitionStyle presentedViewController:[self shareInstance].currentWebNavigationController presentingViewController:sourceViewController];
    if (transition) {
        [[self shareInstance].originalStatusBarStyles addObject:@([UIApplication sharedApplication].statusBarStyle)];
        [[self shareInstance].modalTransitions setObject:transition forKey:[NSString stringWithFormat:@"%p", [self shareInstance].currentWebNavigationController]];
        [self shareInstance].currentWebNavigationController.transitioningDelegate = transition;
        [self shareInstance].currentWebNavigationController.modalPresentationCapturesStatusBarAppearance = YES;
        NSMutableArray *subArray = [NSMutableArray array];
        
        [sourceViewController presentViewController:[self shareInstance].currentWebNavigationController animated:YES completion:nil];
    }
    
}

+ (void)closeWebview {
    [(LLWebViewController *)[self shareInstance].currentWebNavigationController.viewControllers.lastObject close];
    
    [[self shareInstance].modalTransitions removeObjectForKey:[NSString stringWithFormat:@"%p", [self shareInstance].currentWebNavigationController]];
    [[self shareInstance].webNavigationControllerArray removeLastObject];
    [self shareInstance].currentWebNavigationController = [[self shareInstance].webNavigationControllerArray lastObject];
//    [[UIApplication sharedApplication] setStatusBarStyle:[[self shareInstance].originalStatusBarStyles.lastObject integerValue] animated:YES];
    [self shareInstance].navigationBarStyle = [[self shareInstance].originalStatusBarStyles.lastObject integerValue];
    [[self shareInstance].originalStatusBarStyles removeLastObject];
    
}

+ (void)webViewDidCloseNotification {
    [[self shareInstance].modalTransitions removeObjectForKey:[NSString stringWithFormat:@"%p", [self shareInstance].currentWebNavigationController]];
    [[self shareInstance].webNavigationControllerArray removeLastObject];
    [self shareInstance].currentWebNavigationController = [[self shareInstance].webNavigationControllerArray lastObject];
    [[UIApplication sharedApplication] setStatusBarStyle:[[self shareInstance].originalStatusBarStyles.lastObject integerValue] animated:YES];
    [self shareInstance].navigationBarStyle = [[self shareInstance].originalStatusBarStyles.lastObject integerValue];
    [[self shareInstance].originalStatusBarStyles removeLastObject];
}

+ (void)goBack {
    [(LLWebViewController *)[self shareInstance].currentWebNavigationController.viewControllers.lastObject autoBack];
}

- (__kindof UIViewController *)destinationViewControllerForWebURL:(NSURL *)URL title:(NSString *)title shouldShare:(BOOL)shouldShare {
    PAWebView *webManager = [PAWebView webviewProvider];
    [webManager setPaprogressTintColor:self.progressTintColor];
    [webManager setPaprogressTrackTintColor:self.progressTrackTintColor];
    webManager.webView.allowsLinkPreview = NO;
    LLWebViewController *webVC = [[LLWebViewController alloc] initWithWebView:webManager.webView webViewManager:webManager title:title URL:URL];
    webVC.shouldShare = shouldShare;
    webVC.delegate = self;
    [LLWebJSBridgeManage initialzeJSBridgeWithWebView:webManager.webView delegate:webVC];
    
    [LLWebviewLoader configNavigationBarStyleForViewController:webVC webManager:webManager];
    
    return [[LLWebNavigationController alloc] initWithRootViewController:webVC];
    
}

- (__kindof UIViewController *)destinationViewControllerForWebFile:(NSString *)filePath title:(NSString *)title shouldShare:(BOOL)shouldShare {
    PAWebView *webManager = [PAWebView webviewProvider];
    [webManager setPaprogressTintColor:self.progressTintColor];
    [webManager setPaprogressTrackTintColor:self.progressTrackTintColor];
    webManager.webView.allowsLinkPreview = NO;
    LLWebViewController *webVC = [[LLWebViewController alloc] initWithWebView:webManager.webView webViewManager:webManager title:title fileURL:[NSURL fileURLWithPath:filePath]];
    webVC.shouldShare = shouldShare;
    webVC.delegate = self;

    [LLWebJSBridgeManage initialzeJSBridgeWithWebView:webManager.webView delegate:webVC];
    [LLWebviewLoader configNavigationBarStyleForViewController:webVC webManager:webManager];
    return [[LLWebNavigationController alloc] initWithRootViewController:webVC];
    
}

- (__kindof UIViewController *)viewControllerForForwardSkip:(NSURL *)URL title:(NSString *)title shouldShare:(BOOL)shouldShare {
    PAWebView *webManager = [PAWebView webviewProvider];
    [webManager setPaprogressTintColor:self.progressTintColor];
    [webManager setPaprogressTrackTintColor:self.progressTrackTintColor];
    webManager.webView.allowsLinkPreview = NO;
    LLWebViewController *webVC = nil;
    if ([URL.absoluteString hasPrefix:@"http"]) {
        webVC = [[LLWebViewController alloc] initWithWebView:webManager.webView webViewManager:webManager title:title URL:URL];
    }else {
        webVC = [[LLWebViewController alloc] initWithWebView:webManager.webView webViewManager:webManager title:title fileURL:URL];
    }
    ;
    webManager.webView.navigationDelegate = (id<WKNavigationDelegate>)webVC;
    webVC.shouldShare = shouldShare;
    webVC.delegate = self;
    
    [LLWebJSBridgeManage initialzeJSBridgeWithWebView:webManager.webView delegate:webVC];
    [LLWebviewLoader configNavigationBarStyleForViewController:webVC webManager:webManager];
    return webVC;
}

+ (void)configNavigationBarStyleForViewController:(UIViewController *)viewController webManager:(PAWebView *)webManager {
    void(^titleBlock)(NSString *title) = NULL;
    [LLJSMessageNavigationBarHandler autoNavigationBarTitleForViewController:viewController titleChange:&titleBlock];
    webManager.titleBlock = titleBlock;
    
    [LLJSMessageNavigationBarHandler configNavigationBarRightItemForViewController:viewController mode:[self shareInstance].navigationBarStyle];

}

+ (void)observeLocalizedWebViewNavigationActionForURL:(NSString *)URL didMeet:(void(^)(NSString *meetURL))meet {
    if ([URL isKindOfClass:[NSString class]] && meet) {
        [[self shareInstance].URLMeetDictionary setObject:meet forKey:URL];
    }
}

+ (void)cancelObserveLocalizedWebViewNavigationActionForURL:(NSString *)URL {
    if ([URL isKindOfClass:[NSString class]]) {
        [[self shareInstance].URLMeetDictionary removeObjectForKey:URL];
    }
}

- (void)setNavigationBarStyle:(WebViewNavigationBarStyle)navigationBarStyle {
    
    LLWebViewController *top = (LLWebViewController *)[LLWebViewHelper topViewController];
    if ([top isKindOfClass:[LLWebViewController class]]) {
        [LLJSMessageNavigationBarHandler configNavigationBarRightItemForViewController:top mode:navigationBarStyle];
        [LLJSMessageNavigationBarHandler autoNavigationBackButtonForViewController:top webView:[top valueForKey:@"webview"] mode:navigationBarStyle];
    }
}


+ (void)reload {
    LLWebViewController *top = (LLWebViewController *)[LLWebViewHelper topViewController];
    if ([top isKindOfClass:[LLWebViewController class]]) {
        [top.webManager reload];
    }
}

+ (void)reloadFromOrigin {
    LLWebViewController *top = (LLWebViewController *)[LLWebViewHelper topViewController];
    if ([top isKindOfClass:[LLWebViewController class]]) {
        [top.webManager reloadFromOrigin];
    }
}

+ (void)gotoRootWebview {
    if ([[self shareInstance].currentWebNavigationController.childViewControllers count] > 1) {
        [[self shareInstance].currentWebNavigationController popToRootViewControllerAnimated:NO];
    }
    LLWebViewController *top = [self shareInstance].currentWebNavigationController.childViewControllers.firstObject;
       if ([top isKindOfClass:[LLWebViewController class]]) {
           [top gotoRootWebView];
       }
}

+ (void)setWebviewSocialShareDelegate:(id<LLWebviewLoaderDelegate>)delegate {
    [self shareInstance].delegate = delegate;
}

+ (void)setProgressBarTintColor:(UIColor *)tintColor {
    [self shareInstance].progressTintColor = tintColor;
    LLWebViewController *webVC = [[self shareInstance].currentWebNavigationController childViewControllers].lastObject;
    if ([webVC isKindOfClass:[LLWebViewController class]]) {
        [webVC setProgressBarTintColor:tintColor];
    }
}
+ (void)setProgressBarTrackTintColor:(UIColor *)trackTintColor {
    [self shareInstance].progressTrackTintColor = trackTintColor;
    LLWebViewController *webVC = [[self shareInstance].currentWebNavigationController childViewControllers].lastObject;
    if ([webVC isKindOfClass:[LLWebViewController class]]) {
        [webVC setProgressBarTrackTintColor:trackTintColor];
    }
}

#pragma mark - LLWebJSBridgeMessageDelegate

+ (BOOL)handleJSBridgeCallBackByMyself {
    return YES;
}

+ (void)webviewJSBridgeMessageForHandler:(NSString *)handler message:(NSDictionary *)message callback:(void(^)(id))callback {
    if ([handler isEqualToString:@"getSystemInfo"]) {
        if (callback) {
            callback(@{
                       @"code":@0,
                       @"responseData":@{
                               @"containerVersion":[[LLWebViewHelper rootBundle] infoDictionary][@"CFBundleShortVersionString"],
                               @"appVersion":[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
                               @"systemId":[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"],
                               @"appPlatform":[UIDevice currentDevice].systemName,
                               @"imei":[[DeviceVirtualUUID virtualDeviceUUID] stringByReplacingOccurrencesOfString:@"-" withString:@""]
                               },
                       @"msg":@"success",
                       });
        }
    }
}

+ (void)cleanWebViewAllDataSourceFinished:(void (^)(void))finished {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"Cookies"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NULL]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }

    [[PAWebView shareInstance] deleteAllWKCookies];
    NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince: [NSDate dateWithTimeIntervalSince1970:0] completionHandler:finished];
    
}
#pragma mark - LLJSMessageNavigationActionDelegate
- (void)webViewDidReceiveCloseMessage {
    [self.class closeWebview];
}
- (void)webViewDidReceiveBackMessage {
     [self.class goBack];
}
- (void)webViewDidReceiveChangeNavigaitonBarModeMessage:(NSInteger)mode {
    self.navigationBarStyle = mode;
}


- (void)webviewDidReceiveShareMessageForWebViewTitle:(NSString *)webViewTilte contentText:(NSString *)contentText imageURL:(NSString *)imageURL linkURL:(NSString *)linkURL {
     if ([self.delegate respondsToSelector:@selector(webviewJSHandlerSocialShareForWebViewTitle:contentText:imageURL:linkURL:)]) {
         [self.delegate webviewJSHandlerSocialShareForWebViewTitle:webViewTilte contentText:contentText imageURL:imageURL linkURL:linkURL];
     }
}

- (void)webViewDidReceiveNavigationAction:(WKNavigationAction *)navigationAction {
     NSString *urlString = [navigationAction.request.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[self.URLMeetDictionary copy] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, void(^meet)(NSString *url), BOOL * _Nonnull stop) {
        if ([key isEqualToString:urlString]) {
            meet(urlString);
            *stop = YES;
        }
    }];
}
- (void)webViewDidReceiveChangeProgressViewTintColor:(NSString *)color {
     NSInteger color_int = [[LLWebViewHelper convertHex2Dec:color] integerValue];
    [LLWebviewLoader setProgressBarTintColor:[UIColor colorWithRed:(((color_int & 0xFF0000) >> 16))/255.0 green:(((color_int & 0xFF00) >>8))/255.0 blue:((color_int & 0xFF))/255.0 alpha:1.0]];
}
#pragma mark - LLWebViewControllerDelegate

- (void)webViewDidReceiveSocialShareForWebView:(WKWebView *)webview webManager:(PAWebView *)webManager {
    if ([self.delegate respondsToSelector:@selector(webviewSocialShareForWebViewTitle:contentText:imageURL:linkURL:)]) {
        __block NSString *title, *content, *imageURL, *linkURL = nil;
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);
        [webManager callJS:@"document.title;" handler:^(id response, NSError *error) {
            title = response;
            dispatch_group_leave(group);
        }];
         dispatch_group_enter(group);
        [webManager callJS:@"document.body.innerText;" handler:^(id response, NSError *error) {
            content = [response stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            dispatch_group_leave(group);
        }];
         dispatch_group_enter(group);
        [webManager callJS:@"document.getElementsByTagName(\"img\")[0].getAttribute(\"src\")" handler:^(id response, NSError *error) {
            imageURL = response;
            dispatch_group_leave(group);
        }];
         dispatch_group_enter(group);
        [webManager callJS:@"document.URL" handler:^(id response, NSError *error) {
            linkURL = response;
            dispatch_group_leave(group);
        }];
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            [self.delegate webviewSocialShareForWebViewTitle:title contentText:content imageURL:imageURL linkURL:linkURL];
        });

    }
}

@end

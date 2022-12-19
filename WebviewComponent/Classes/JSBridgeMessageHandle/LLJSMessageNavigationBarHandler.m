//
//  LLJSMessageNavigationBarHandler.m
//  WebviewComponent
//
//  Created by 刘江 on 2019/7/31.
//

#import "LLJSMessageNavigationBarHandler.h"
#import "LLWebViewHelper.h"
#import "UINavigationItem+AttributeTitle.h"
#import "LLWebNavigationBar.h"
//#import "LLNavigationBar.h"
//#import "LLWebviewLoader.h"
//#import "LLWebViewController.h"

#import "LLWebJSBridgeManage.h"


#define hScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define kNavBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height + 44)
#define ScaleByWidth(w) (w)*hScreenWidth/375

@interface LLJSMessageNavigationBarHandler ()<LLWebJSBridgeMessageDelegate>
@property (nonatomic, weak)id delegate;
@property (nonatomic, weak)id shareDelegate;
@end

@implementation LLJSMessageNavigationBarHandler
void(^moreAction)(void) = NULL;
+ (LLJSMessageNavigationBarHandler *)share {
    static LLJSMessageNavigationBarHandler * handler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handler = [[LLJSMessageNavigationBarHandler alloc] init];
    });
    return handler;
}
+ (void)setNavigationBarMessageDelegate:(id<LLJSMessageNavigationActionDelegate>)delegate {
    [self share].delegate = delegate;
}

+ (void)setWebViewSocialShareMessageDelegate:(id<LLJSMessageNavigationActionDelegate>)delegate {
    [self share].shareDelegate = delegate;
}

+ (void)autoNavigationBarTitleForViewController:(UIViewController<LLJSMessageNavigationActionDelegate> *)viewController titleChange:(Change *)change {
    *change = ^(NSString *title) {
        if (viewController.navigationBar.title.length < 1 && viewController.constantTitle.length < 1) {
            [viewController.navigationBar setAttributeTitle:[[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:ScaleByWidth(18) weight:UIFontWeightMedium], NSForegroundColorAttributeName:[UIColor blackColor]}]];
        }
    };
}

+ (void)configNavigationBarRightItemForViewController:(UIViewController<LLJSMessageNavigationActionDelegate> *)viewController mode:(NSUInteger)mode {
    if (!viewController.navigationBar.rightItems.count || viewController.rightBarMode != mode) {
        viewController.rightBarMode = mode;
        NSMutableArray *rightItems = [NSMutableArray arrayWithCapacity:2];
        if (viewController.shouldShare) {
            UIButton *more = [UIButton buttonWithType:UIButtonTypeCustom];
            [more setImage:[UIImage imageWithContentsOfFile:[LLWebViewHelper pngImagefilePathForName:mode == 0 ? @"web_nav_more_dark":@"web_nav_more_light"]] forState:UIControlStateNormal];
            more.frame = CGRectMake(0, 0, 36, 44);
            [more addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
            [rightItems addObject:more];
        }
        
        UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
        [close setImage:[UIImage imageWithContentsOfFile:[LLWebViewHelper pngImagefilePathForName:mode == 0 ? @"web_nav_close_dark":@"web_nav_close_light"]] forState:UIControlStateNormal];
        close.frame = CGRectMake(0, 0, 36, 44);
        [rightItems addObject:close];
        [close addTarget:self action:@selector(closeWebPage) forControlEvents:UIControlEventTouchUpInside];
        //
    
        viewController.navigationBar.rightItems = rightItems;
        
    }
        [self setStatusBarStyle:mode targetViewController:viewController];
//    [viewController setNeedsStatusBarAppearanceUpdate];
    
}

+ (void)closeWebPage {
    if ([[self share].delegate respondsToSelector:@selector(webViewDidReceiveCloseMessage)]) {
        [[self share].delegate webViewDidReceiveCloseMessage];
    }
}

+ (void)moreAction {
    if (moreAction) {
        moreAction();
    }
}

+ (void)backAction {
    if ([[self share].delegate respondsToSelector:@selector(webViewDidReceiveBackMessage)]) {
        [[self share].delegate webViewDidReceiveBackMessage];
    }
}

+ (void)autoNavigationBackButtonForViewController:(UIViewController<LLJSMessageNavigationActionDelegate> *)viewController webView:(WKWebView *)webView mode:(NSUInteger)mode {
    int visiblePage = 0;
    NSArray *allVC = viewController.navigationController.viewControllers;
    for (id<LLJSMessageNavigationActionDelegate> subVC in allVC) {
        if (![subVC respondsToSelector:@selector(canBeVisible)] || subVC.canBeVisible) {
            visiblePage++;
        }
    }
    if ((webView.backForwardList.backList.count > 0 || visiblePage > 1) ) {
        if (!viewController.navigationBar.leftItems.count || viewController.leftBarMode != mode) {
            viewController.leftBarMode = mode;
            UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [backButton setImage:[UIImage imageWithContentsOfFile:[LLWebViewHelper pngImagefilePathForName:mode == 0 ? @"web_nav_back_dark":@"web_nav_back_light"]] forState:UIControlStateNormal];
            backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [backButton addTarget:self.class action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
            backButton.frame = CGRectMake(0, 0, 44, 40);
            viewController.navigationBar.backButton = backButton;
        }
        
    }else{
        viewController.navigationBar.leftItems = nil;
    }
    
    
}

+ (void)manualDecreaseWeviviewBackItemListForViewController:(UIViewController<LLJSMessageNavigationActionDelegate> *)viewController webView:(WKWebView *)webView {
    if (webView.backForwardList.backList.count-1 > 0) {
        if (!viewController.navigationBar.rightItems.count) {
            UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [backButton setImage:[UIImage imageWithContentsOfFile:[LLWebViewHelper pngImagefilePathForName:viewController.leftBarMode == 0 ? @"web_nav_back_dark":@"web_nav_back_light"]] forState:UIControlStateNormal];
            backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [backButton addTarget:self.class action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
            [backButton sizeToFit];
            viewController.navigationBar.leftItems = @[backButton];
        }
        
    }else{
        viewController.navigationBar.leftItems = nil;
    }
}

+ (void)setStatusBarStyle:(NSUInteger)style targetViewController:(UIViewController *)target {
    if ([target respondsToSelector:NSSelectorFromString(@"setStatusBarStyle:")]) {
        if (style == 0) {
            [target performSelector:NSSelectorFromString(@"setStatusBarStyle:") withObject:@(UIStatusBarStyleDefault)];
        }else {
            [target performSelector:NSSelectorFromString(@"setStatusBarStyle:") withObject:@(UIStatusBarStyleLightContent)];
        }
    }
   
}

+ (void)layoutWebViewInitialStyle:(WKWebView *)webView {
    [webView.scrollView setContentOffset:CGPointMake(0, -kNavBarHeight)];
    UIView *view = webView;
    while (view) {
        view.backgroundColor = [UIColor colorWithRed:242/255.f green:242/255.f blue:242/255.f alpha:1];
        view = view.subviews.firstObject;
        
    }
}

+ (void)moreActionsForWebView:(void(^)(void))more {
    moreAction = more;
}

#pragma mark - LLWebJSBridgeMessageDelegate
+ (void)webviewJSBridgeMessageForHandler:(NSString *)handler message:(NSDictionary *)message callback:(void(^)(id))callback {
    UIViewController *topVC = [LLWebViewHelper topViewController];
    if ([handler isEqualToString:@"backNative"]) {
        if ([[self share].delegate respondsToSelector:@selector(webViewDidReceiveCloseMessage)]) {
            [[self share].delegate webViewDidReceiveCloseMessage];
        }
    }else if ([handler isEqualToString:@"setNavigationIconMode"]) {
        UIViewController<LLJSMessageNavigationActionDelegate> *top = [LLWebViewHelper topViewController];
        if ([top conformsToProtocol:@protocol(LLJSMessageNavigationActionDelegate)] && ([message[@"mode"] intValue] ==1 || [message[@"mode"] intValue] == 0)) {
            [self configNavigationBarRightItemForViewController:top mode:[message[@"mode"] intValue]];
            [self autoNavigationBackButtonForViewController:top webView:[top valueForKey:@"webview"] mode:[message[@"mode"] intValue]];
            if ([[self share].delegate respondsToSelector:@selector(webViewDidReceiveChangeNavigaitonBarModeMessage:)]) {
                [[self share].delegate webViewDidReceiveChangeNavigaitonBarModeMessage:[message[@"mode"] intValue]];
            }
        }
    }else if ([handler isEqualToString:@"onShare"]) {
        if ([[self share].shareDelegate respondsToSelector:@selector(webviewDidReceiveShareMessageForWebViewTitle:contentText:imageURL:linkURL:)]) {
            [[self share].shareDelegate webviewDidReceiveShareMessageForWebViewTitle:message[@"shareableTitle"] contentText:message[@"shareableDesc"] imageURL:message[@"shareableThumbnail"] linkURL:message[@"shareableUrl"]];
        }
    }else if ([handler isEqualToString:@"setProgressViewTintColor"]) {
        if ([LLWebViewHelper validHexColorCodeString:message[@"color"]]) {
            if ([[self share].shareDelegate respondsToSelector:@selector(webViewDidReceiveChangeProgressViewTintColor:)]) {
                [[self share].shareDelegate webViewDidReceiveChangeProgressViewTintColor:message[@"color"]];
            }
        }
    }
}


@end

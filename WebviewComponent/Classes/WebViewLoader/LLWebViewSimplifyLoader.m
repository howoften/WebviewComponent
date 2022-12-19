//
//  LLWebViewSimplifyLoader.m
//  Pods-WebviewComponent_Example
//
//  Created by 刘江 on 2019/8/8.
//

#import "PAWebView.h"
#import "LLWebViewSimplifyLoader.h"
#import "LLWebviewLoader.h"
#import "LLModalTransition.h"
#import "UINavigationItem+AttributeTitle.h"

@interface LLWebViewSimplifyLoader ()
@property (nonatomic, strong)UIColor *progressTintColor;
@property (nonatomic, strong)UIColor *progressTrackTintColor;

@end

@implementation LLWebViewSimplifyLoader
+ (LLWebViewSimplifyLoader *)share{
    static LLWebViewSimplifyLoader *simplify = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        simplify = [[LLWebViewSimplifyLoader alloc] init];
    });
    return simplify;
}

+ (void)loadWebViewByURL:(NSURL *)URL webViewTitle:(NSString *)title fromSourceViewController:(UIViewController *)sourceViewController {
    UIViewController *nav = sourceViewController;
    if ([sourceViewController isKindOfClass:[UINavigationController class]]) {

    }else if ([sourceViewController isKindOfClass:[UITabBarController class]]) {
        UIViewController *childVC = [(UITabBarController *)sourceViewController selectedViewController];
        nav = childVC;
    }
    
    if ([nav isKindOfClass:[UINavigationController class]]) {
        PAWebView *webView = [PAWebView new];
        [webView setPaprogressTintColor:[self share].progressTintColor];
        [webView setPaprogressTrackTintColor:[self share].progressTrackTintColor];
        webView.edgesForExtendedLayout = UIRectEdgeNone;
        webView.openCache = YES;  //打开缓存z
        [webView loadRequestURL:URL];
        if (title.length > 0) {
            webView.navigationItem.attributeTitle = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18*[UIScreen mainScreen].bounds.size.width/375.0 weight:UIFontWeightMedium], NSForegroundColorAttributeName:[UIColor blackColor]}];
        }
        [(UINavigationController *)nav pushViewController:webView animated:YES];
    }else {
        [LLWebviewLoader loadWebViewByURL:URL fromSourceViewController:sourceViewController title:title shouleShare:NO transitionStyle:ViewControllerModalStyleLikeNavigation];
    }
}

+ (void)loadWebViewByFile:(NSString *)filePath webViewTitle:(NSString *)title fromSourceViewController:(UIViewController *)sourceViewController {
    UIViewController *nav = sourceViewController;
    if ([sourceViewController isKindOfClass:[UINavigationController class]]) {
        
    }else if ([sourceViewController isKindOfClass:[UITabBarController class]]) {
        UIViewController *childVC = [(UITabBarController *)sourceViewController selectedViewController];
        nav = childVC;
    }
    
    if ([nav isKindOfClass:[UINavigationController class]]) {
        PAWebView *webView = [PAWebView new];
        [webView setPaprogressTintColor:[self share].progressTintColor];
        [webView setPaprogressTrackTintColor:[self share].progressTrackTintColor];
        webView.edgesForExtendedLayout = UIRectEdgeNone;
        webView.openCache = YES;  //打开缓存
        if (title.length > 0) {
            webView.navigationItem.attributeTitle = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18*[UIScreen mainScreen].bounds.size.width/375.0 weight:UIFontWeightMedium], NSForegroundColorAttributeName:[UIColor blackColor]}];
        }
        [webView loadLocalHTMLWithFilePath: filePath];
        [(UINavigationController *)nav pushViewController:webView animated:YES];
    }else {
        [LLWebviewLoader loadWebViewByLocalFile:filePath fromSourceViewController:sourceViewController title:title shouleShare:NO transitionStyle:ViewControllerModalStyleLikeNavigation];
    }
}

+ (void)setProgressBarTintColor:(UIColor *)tintColor {
    [self share].progressTintColor = tintColor;
}

+ (void)setProgressBarTrackTintColor:(UIColor *)trackTintColor {
    [self share].progressTrackTintColor = trackTintColor;
}

@end

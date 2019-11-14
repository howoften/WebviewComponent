//
//  WebviewLoader.h
//  WebviewComponent
//
//  Created by 刘江 on 2019/7/29.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WebViewNavigationBarStyle) {
    WebViewNavigationBarStyleDark = 0,
    WebViewNavigationBarStyleLight
};

@protocol LLWebviewLoaderDelegate <NSObject>
@required
- (void)webviewSocialShareForWebViewTitle:(NSString *)webViewTilte contentText:(NSString *)contentText imageURL:(NSString *)imageURL linkURL:(NSString *)linkURL;
- (void)webviewJSHandlerSocialShareForWebViewTitle:(NSString *)webViewTilte contentText:(NSString *)contentText imageURL:(NSString *)imageURL linkURL:(NSString *)linkURL;
@end

@interface LLWebviewLoader : NSObject

+ (void)loadWebViewByURL:(NSURL *)URL fromSourceViewController:(UIViewController *)sourceViewController title:(NSString *)title shouleShare:(BOOL)shouldShare;

+ (void)loadWebViewByLocalFile:(NSString *)filePath fromSourceViewController:(UIViewController *)sourceViewController title:(NSString *)title shouleShare:(BOOL)shouldShare;

+ (void)setWebviewSocialShareDelegate:(id<LLWebviewLoaderDelegate>)delegate;

+ (void)observeLocalizedWebViewNavigationActionForURL:(NSString *)URL didMeet:(void(^)(NSString *meetURL))meet;
+ (void)cancelObserveLocalizedWebViewNavigationActionForURL:(NSString *)URL;

+ (void)setProgressBarTintColor:(UIColor *)tintColor;
+ (void)setProgressBarTrackTintColor:(UIColor *)trackTintColor;

+ (void)reload;
+ (void)reloadFromOrigin;

+ (void)cleanWebViewAllDataSourceFinished:(void (^)(void))finished;
+ (void)closeWebview;

+ (void)goBack;

+ (void)gotoRootWebview;

@end

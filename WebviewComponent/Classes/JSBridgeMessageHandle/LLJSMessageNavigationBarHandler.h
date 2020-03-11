//
//  LLJSMessageNavigationBarHandler.h
//  WebviewComponent
//
//  Created by 刘江 on 2019/7/31.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>


typedef void(^Change)(NSString *);

@protocol LLJSMessageNavigationActionDelegate <NSObject>
@optional

@property (nonatomic)BOOL canBeVisible;
@property (nonatomic)BOOL shouldShare;
@property (nonatomic, strong)NSString *constantTitle;
@property (nonatomic)NSUInteger leftBarMode;
@property (nonatomic)NSUInteger rightBarMode;
- (void)webViewDidReceiveCloseMessage;
- (void)webViewDidReceiveBackMessage;
- (void)webViewDidReceiveChangeNavigaitonBarModeMessage:(NSInteger)mode;

- (void)webviewDidReceiveShareMessageForWebViewTitle:(NSString *)webViewTilte contentText:(NSString *)contentText imageURL:(NSString *)imageURL linkURL:(NSString *)linkURL;
- (void)webViewDidReceiveChangeProgressViewTintColor:(NSString *)color;
@end

@interface LLJSMessageNavigationBarHandler : NSObject
+ (void)setNavigationBarMessageDelegate:(id<LLJSMessageNavigationActionDelegate>)delegate;
+ (void)setWebViewSocialShareMessageDelegate:(id<LLJSMessageNavigationActionDelegate>)delegate;

+ (void)autoNavigationBarTitleForViewController:(UIViewController *)viewController titleChange:(Change *)change;

+ (void)configNavigationBarRightItemForViewController:(UIViewController *)viewController mode:(NSUInteger)mode;

+ (void)autoNavigationBackButtonForViewController:(UIViewController *)viewController webView:(WKWebView *)webView mode:(NSUInteger)mode;
+ (void)manualDecreaseWeviviewBackItemListForViewController:(UIViewController *)viewController webView:(WKWebView *)webView;

+ (void)moreActionsForWebView:(void(^)(void))more;

+ (void)layoutWebViewInitialStyle:(WKWebView *)webView;

@end


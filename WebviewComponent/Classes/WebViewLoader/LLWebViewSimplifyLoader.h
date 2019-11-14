//
//  LLWebViewSimplifyLoader.h
//  Pods-WebviewComponent_Example
//
//  Created by 刘江 on 2019/8/8.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LLWebViewSimplifyLoader : NSObject

+ (void)loadWebViewByURL:(NSURL *)URL webViewTitle:(NSString *)title fromSourceViewController:(UIViewController *)sourceViewController;

+ (void)loadWebViewByFile:(NSString *)filePath webViewTitle:(NSString *)title fromSourceViewController:(UIViewController *)sourceViewController;

+ (void)setProgressBarTintColor:(UIColor *)tintColor;
+ (void)setProgressBarTrackTintColor:(UIColor *)trackTintColor;
@end


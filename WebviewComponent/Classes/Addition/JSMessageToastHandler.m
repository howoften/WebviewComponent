//
//  JSMessageToastHandler.m
//  WebviewComponent_Example
//
//  Created by 刘江 on 2019/8/5.
//  Copyright © 2019 howoften. All rights reserved.
//

#import "JSMessageToastHandler.h"
#import "UIViewController+Refresh.h"

@implementation JSMessageToastHandler

+ (void)webviewJSBridgeMessageForHandler:(NSString *)handler message:(NSDictionary *)message callback:(void(^)(id))callback {

    if ([handler isEqualToString:@"showToast"]) {
        [[UIApplication sharedApplication].delegate.window.rootViewController.presentedViewController toastWithText:message[@"content"]];
    }else if ([handler isEqualToString:@"showLoading"]) {
        [[UIApplication sharedApplication].delegate.window.rootViewController.presentedViewController refreshViewWithTitle:nil content:message[@"content"]];
        if ([message[@"duration"] floatValue]/1000.f > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([message[@"duration"] floatValue]/1000.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication].delegate.window.rootViewController.presentedViewController hideRefreshView];
            });
        }
    }else if ([handler isEqualToString:@"hideLoading"]) {
        [[UIApplication sharedApplication].delegate.window.rootViewController.presentedViewController hideRefreshView];
    }
}

@end

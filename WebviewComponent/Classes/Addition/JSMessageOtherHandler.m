//
//  JSMessageOtherHandler.m
//  WebviewComponent_Example
//
//  Created by 刘江 on 2019/8/6.
//  Copyright © 2019 howoften. All rights reserved.
//

#import "JSMessageOtherHandler.h"

@implementation JSMessageOtherHandler

+ (BOOL)handleJSBridgeCallBackByMyself {
    return YES;
}

+ (void)webviewJSBridgeMessageForHandler:(NSString *)handler message:(NSDictionary *)message callback:(void(^)(id))callback {
    if ([handler isEqualToString:@"makePhoneCall"]) {
         NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"\\d*"];
        BOOL flag = [pre evaluateWithObject:message[@"number"]];
        if (flag) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",message[@"number"]]]];
            if (callback) {
                callback(@{@"code":@(0), @"msg":@"success"});
            }
        }else {
            if (callback) {
                callback(@{@"code":@(-1), @"msg":@"Illegal phone number"});
            }
        }
    }
}


@end

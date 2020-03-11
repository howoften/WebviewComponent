//
//  JSMessageLocationHandler.m
//  WebviewComponent_Example
//
//  Created by 刘江 on 2019/8/6.
//  Copyright © 2019 howoften. All rights reserved.
//

#import "JSMessageLocationHandler.h"
#import "LLWebLocationManager.h"

@implementation JSMessageLocationHandler

+ (BOOL)handleJSBridgeCallBackByMyself {
    return YES;
}

+ (void)webviewJSBridgeMessageForHandler:(NSString *)handler message:(NSDictionary *)message callback:(void(^)(id))callback {
    if ([handler isEqualToString:@"getLocation"]) {
        [[LLWebLocationManager defaultManager] requestLocationInfo:^(NSDictionary *dic, NSError *error) {
            if (error || !dic[@"longitude"] || !dic[@"latitude"]) {
                if (callback) {
                    callback(@{@"code":@(-1), @"msg":error.localizedDescription!=nil ? error.localizedDescription:@"Locate Fail"});
                }
            }else {
                if (callback) {
                    callback(@{@"code":@(0), @"responseData":@{
                                       @"longitude":dic[@"longitude"],
                                           @"latitude":dic[@"latitude"],
                                       }, @"msg":@"success"});
                }
            }
        } maxToleranceTime:10];
    }
}

@end

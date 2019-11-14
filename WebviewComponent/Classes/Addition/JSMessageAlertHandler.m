//
//  JSMessageAlertHandler.m
//  WebviewComponent_Example
//
//  Created by 刘江 on 2019/8/5.
//  Copyright © 2019 howoften. All rights reserved.
//

#import "JSMessageAlertHandler.h"
#import "SJAlertViewPresenter.h"

@implementation JSMessageAlertHandler

+ (BOOL)handleJSBridgeCallBackByMyself {
    return YES;
}

+ (void)webviewJSBridgeMessageForHandler:(NSString *)handler message:(NSDictionary *)message callback:(void(^)(id))callback {
    if ([handler isEqualToString:@"alert"]) {
        NSString *buttonTitle = [NSString stringWithFormat:@"%@", [message[@"buttonText"] length] > 0 ? message[@"buttonText"] : @"确定"];
        if ([buttonTitle length] > 10) {
            buttonTitle = [buttonTitle substringToIndex:10];
        }
        [[SJAlertViewPresenter shareInstance] presentNormalAlertViewWithTitle:message[@"title"] contentList:@[message[@"content"]] bottomClickItem:@[buttonTitle] dismissFreedom:NO];
        [[SJAlertViewPresenter shareInstance] setExecResult:^(id result) {
            if (callback) {
                callback([LLWebJSBridgeManage standardSuccessfulJSBridgeResponse]);
            }
        }];
    }else if ([handler isEqualToString:@"showActionSheet"]) {
        NSString *buttonTitle = [NSString stringWithFormat:@"%@", [message[@"cancelButtonText"] length] > 0 ? message[@"cancelButtonText"] : @"取消"];
        if (![message[@"items"] isKindOfClass:[NSArray class]] || [message[@"items"] count] < 1) {
            if (callback) {
                callback(@{@"code":@-1,
                           @"msg":@"argu 'items' not correct"
                           });
            }
        }else {
            NSSet *items = [NSSet setWithArray:message[@"items"]];
            if (items.count != [message[@"items"] count]) {
                if (callback) {
                    callback(@{@"code":@-1,
                               @"msg":@"have same item in items array",
                               });
                }
            }else {
                [[SJAlertViewPresenter shareInstance] presentSheetAlertViewWithTitle:message[@"title"] cancelButtonTitle:buttonTitle destructiveButtonTitle:nil otherButtonTitles:message[@"items"] dismissFreedom:NO];
                [[SJAlertViewPresenter shareInstance] setExecResult:^(id result) {
                    if (callback) {
                        callback(@{@"code":@0,
                                   @"msg":@"success",
                                   @"responseData":@{
                                           @"index":[result intValue] == -1 ? result : @([result intValue]-1)
                                           }
                                   });
                    }
                }];
            }
        }
    }else if ([handler isEqualToString:@"confirmAlert"]) {
        NSString *buttonTitleLeft = [NSString stringWithFormat:@"%@", [message[@"leftButtonText"] length] > 0 ? message[@"leftButtonText"] : @"取消"];
        NSString *buttonTitleRight = [NSString stringWithFormat:@"%@", [message[@"rightButtonText"] length] > 0 ? message[@"rightButtonText"] : @"取消"];
        if ([buttonTitleLeft length] > 10) {
            buttonTitleLeft = [buttonTitleLeft substringToIndex:10];
        }
        if ([buttonTitleRight length] > 10) {
            buttonTitleRight = [buttonTitleRight substringToIndex:10];
        }
        if ([buttonTitleLeft isEqualToString:buttonTitleRight]) {
            if (callback) {
                callback(@{@"code":@-1,
                           @"msg":@"buttonLeft has same title with button right, this may cause confusion.",
                           });
            }
        }else {
            [[SJAlertViewPresenter shareInstance] presentNormalAlertViewWithTitle:message[@"title"] contentList:@[message[@"content"]] bottomClickItem:@[buttonTitleLeft, buttonTitleRight] dismissFreedom:NO];
            [[SJAlertViewPresenter shareInstance] setExecResult:^(id result) {
                if (callback) {
                    callback(@{@"code":@0,
                               @"msg":@"success",
                               @"responseData":@{
                                       @"leftButtonClick":@([result isEqualToString:buttonTitleLeft]),
                                       @"rightButtonClick":@([result isEqualToString:buttonTitleRight])
                                       }
                               });
                }
            }];
        }
    }
}

@end

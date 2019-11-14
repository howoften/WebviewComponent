//
//  LLJSMessageNavigationBarTitleHandler.m
//  Pods-WebviewComponent_Example
//
//  Created by 刘江 on 2019/8/29.
//

#import "LLJSMessageNavigationBarTitleHandler.h"
#import "LLWebViewHelper.h"
#import "LLWebNavigationBar.h"
#import "UINavigationItem+AttributeTitle.h"

#define UICOLOR_FROM_HEX(hex) [UIColor colorWithRed:(((hex & 0xFF0000) >> 16))/255.0 green:(((hex & 0xFF00) >>8))/255.0 blue:((hex & 0xFF))/255.0 alpha:1.0]
@implementation LLJSMessageNavigationBarTitleHandler

+ (BOOL)handleJSBridgeCallBackByMyself {
    return YES;
}

+ (void)webviewJSBridgeMessageForHandler:(NSString *)handler message:(NSDictionary *)message callback:(void(^)(id))callback {
    if ([handler isEqualToString:@"setTitleBarText"]) {
//        NSString *titleColor = message[@"titleColor"];
//        NSString *bgColor = message[@"backgroundColor"];
        UIViewController *topVC = [LLWebViewHelper topViewController];
        if ([NSStringFromClass([topVC class]) isEqualToString:@"LLWebViewController"]) {
            NSString *msg = nil;
            NSInteger code = 0;
            if ([LLWebViewHelper validHexColorCodeString:message[@"titleColor"]]) {
                [topVC.navigationItem setAttributeTitle:[[NSAttributedString alloc] initWithString:message[@"title"] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18*[UIScreen mainScreen].bounds.size.width/375.0 weight:UIFontWeightMedium], NSForegroundColorAttributeName:UICOLOR_FROM_HEX([[LLWebViewHelper convertHex2Dec:message[@"titleColor"]] integerValue])}]];
            }
            if ([LLWebViewHelper validHexColorCodeString:message[@"backgroundColor"]]) {
                topVC.navigationBar.backgroundColor = UICOLOR_FROM_HEX([[LLWebViewHelper convertHex2Dec:message[@"backgroundColor"]] integerValue]);
            }
            
            if (![LLWebViewHelper validHexColorCodeString:message[@"titleColor"]] && ![LLWebViewHelper validHexColorCodeString:message[@"backgroundColor"]]) {
                msg = @"Call handler 'setTitleBarText' fail, because required param 'titleColor' not present or illegal type.";
                code = -1;
            }else {
                msg = @"success";
            }
            if (callback) {
                callback(@{@"code":@(code),@"msg":msg});
            }
        }else {
            if (callback) {
                callback(@{@"code":@(-1),@"msg":@"Call handler 'setTitleBarText' fail, because webview is not visible.",});
            }
        }
    }
        
}

@end

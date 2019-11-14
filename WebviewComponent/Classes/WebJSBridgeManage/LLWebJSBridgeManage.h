//
//  WebJSBridgeImpl.h
//  WebviewComponent
//
//  Created by 刘江 on 2019/7/30.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>

@protocol LLWebJSBridgeMessageDelegate <NSObject>

+ (BOOL)handleJSBridgeCallBackByMyself;
+ (void)webviewJSBridgeMessageForHandler:(NSString *)handler message:(NSDictionary *)message callback:(void(^)(id))callback;

@end
@interface LLWebJSBridgeManage : NSObject

+ (void)initialzeJSBridgeWithWebView:(WKWebView *)webView delegate:(id<WKNavigationDelegate, WKUIDelegate>)delegate;

+ (void)registerJSBridgeHandlerWithHandlerFile:(NSString *)filePath;

+ (void)registerJSBridgeHandler:(NSString *)handler callback:(void(^)(id data, void(^responseCallback)(id response)))callback;

+ (void)responseForJSBridgeHandler:(NSString *)handler callback:(void(^)(id data, void(^responseCallback)(id response)))callback;
+ (WebViewJavascriptBridge *)currentWebviewBridge;

+ (NSDictionary *)standardSuccessfulJSBridgeResponse;
+ (NSDictionary *)standardFailureJSBridgeResponse;

//+ (NSDictionary *)parameterDefinitionForHandler:(NSString *)handler;
@end


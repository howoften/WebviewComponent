//
//  WebJSBridgeImpl.m
//  WebviewComponent
//
//  Created by 刘江 on 2019/7/30.
//

//#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>
#import "LLWebJSBridgeManage.h"
#import "LLWebViewHelper.h"

#define JSHandler @"ObjCHandler"
#define HandlersKey [NSString stringWithFormat:@"%p", [self share].currentBridge]

@interface LLWebJSBridgeManage ()
//@property (nonatomic, strong)WKWebView *currentWebView;
@property (nonatomic, strong)WebViewJavascriptBridge *currentBridge;
@property (nonatomic, strong)NSMutableDictionary *jsBridgeWebViewMapping;
@property (nonatomic, strong)NSMutableDictionary *jsBridgeHandlersMapping;

@property (nonatomic, strong)NSMutableSet *externalhandlerRegisterFileSet;
//@property (nonatomic, strong)NSMutableDictionary *externalFileJSHandlersMapping;

@property (nonatomic, strong)NSMutableDictionary *externalhandlersRegister;
//@property (nonatomic, strong)NSMutableDictionary *externalRegistrJSHandlersMapping;

@end

static dispatch_semaphore_t mutex = nil;
@implementation LLWebJSBridgeManage

+ (LLWebJSBridgeManage *)share {
    static LLWebJSBridgeManage * mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[LLWebJSBridgeManage alloc] init];
        mgr.jsBridgeWebViewMapping = [NSMutableDictionary dictionaryWithCapacity:0];
        mgr.jsBridgeHandlersMapping = [NSMutableDictionary dictionaryWithCapacity:0];
        mgr.externalhandlersRegister = [NSMutableDictionary dictionaryWithCapacity:0];
        mgr.externalhandlerRegisterFileSet = [NSMutableSet set];
        mutex = dispatch_semaphore_create(1);
        [[NSNotificationCenter defaultCenter] addObserver:mgr selector:@selector(webViewDidClose:) name:@"LLWebViewDidCloseNotification" object:nil];
    });
    return mgr;
}

+ (void)initialzeJSBridgeWithWebView:(WKWebView *)webView delegate:(id<WKNavigationDelegate, WKUIDelegate>)delegate {
    NSString *web_p = [NSString stringWithFormat:@"%p", webView];
    NSAssert(![[self share].jsBridgeWebViewMapping.allKeys containsObject:web_p], @"LLWebJSBridgeManage initialize fail, this webview is already in webview stack!");
    if ([webView isKindOfClass:[WKWebView class]]) {
//        [self share].currentWebView = webView;
        [self share].currentBridge = [WebViewJavascriptBridge bridgeForWebView:webView];
        [[self share].currentBridge setWebViewDelegate:delegate];
        webView.UIDelegate = delegate;
        [[self share].jsBridgeWebViewMapping setObject:[self share].currentBridge forKey:[NSString stringWithFormat:@"%p", webView]];
        [[self share].jsBridgeHandlersMapping setObject:[NSMutableArray arrayWithCapacity:0] forKey:HandlersKey];

        [self registerObjCJavaScriptHandlerWithFilePath:[LLWebViewHelper filePathForName:@"ObjCHandler" sourceType:@"plist"]];
        
        [self registerExternalJSHandler];
    }
}

+ (void)registerObjCJavaScriptHandlerWithFilePath:(NSString *)filePath {
    NSAssert([self share].currentBridge != nil, @"LLWebJSBridgeManage initialize fail, there is not JSBridge available!");
    
    NSArray *handlers = [NSArray arrayWithContentsOfFile:filePath];
     NSAssert([handlers isKindOfClass:[NSArray class]], @"LLWebJSBridgeManage initialize fail,  jsbridge handlers file is not support!");
    [handlers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self verifyHandlerDataFormate:obj]) {
            [[self share].jsBridgeHandlersMapping[HandlersKey] addObject:obj[@"handler"]];
            [[self share].currentBridge registerHandler:obj[@"handler"] handler:^(id data, WVJBResponseCallback responseCallback) {
                if (![data isKindOfClass:[NSDictionary class]] && data != nil) {
                    if (responseCallback) {
                        responseCallback(@{
                                           @"code":@-1,
                                           @"msg":@"JSON text did not start with array or object and option to allow fragments not set.",
                                           });
                    }
                }else {
                    BOOL legal = YES;
                    __block BOOL requiredLegal = YES;
                    __block NSString *illegalKey = @"";
                    [obj[@"param"] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key_, id  _Nonnull objItem, BOOL * _Nonnull stop) {
                        //                        paramLegal = paramLegal && ([objItem[@"required"] boolValue])
                        if ([objItem[@"required"] boolValue] && !data[key_]) {
                            requiredLegal = NO;
                            illegalKey = key_;
                            *stop = YES;
                        }
                    }];
                    
                    legal = legal && requiredLegal;
                    __block BOOL typeLegal = YES;
                    if (legal) {
                        [data enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key_, id  _Nonnull objItem, BOOL * _Nonnull stop) {
                            if (obj[@"param"][key_][@"default"]) {
                                if (![LLWebViewHelper typeCompareForUnspecialObject:obj[@"param"][key_][@"default"] another:objItem]) {
                                    typeLegal = NO;
                                    illegalKey = key_;
                                    *stop = YES;
                                }
                                
                            }
                        }];
                    }
                    
                    legal = legal && typeLegal;
                    if (!legal) {
                        if (responseCallback) {
                            responseCallback(@{
                                               @"code":@-1,
                                               @"msg":[@"Call handler" stringByAppendingFormat:@" '%@' fail, because required param '%@' not present or illegal type.", obj[@"handler"], illegalKey],
                                               });
                        }
                    }else {
                        Class cls = NSClassFromString(obj[@"executableObject"]);
                        if ([cls respondsToSelector:@selector(webviewJSBridgeMessageForHandler:message:callback:)]) {
                            __block NSMutableDictionary *data_copy = [data mutableCopy];
                            [obj[@"param"] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                                if ([data objectForKey:key] == nil && obj[@"default"] != nil && ![obj[@"default"] isKindOfClass:[NSNull class]]) {
                                    [data_copy setObject:obj[@"default"] forKey:key];
                                }
                            }];
                            
                            BOOL handleCallback = NO;
                            if ([cls respondsToSelector:@selector(handleJSBridgeCallBackByMyself)]) {
                                handleCallback = [cls handleJSBridgeCallBackByMyself];
                            }
                            [cls webviewJSBridgeMessageForHandler:obj[@"handler"] message:[data_copy copy] callback:handleCallback?responseCallback : NULL];
                            
                            if (!handleCallback && responseCallback) {
                                responseCallback(@{
                                                   @"code":@0,
                                                   @"msg":@"success",
                                                   });
                            }
                        }else {
                            if (responseCallback) {
                                responseCallback(@{
                                                   @"code":@-1,
                                                   @"msg":[@"Handler" stringByAppendingFormat:@" '%@' have not implement yet.", obj[@"handler"]],
                                                   });
                            }
                        }
                    }
                    
                }
                
            }];
            
        }
        
    }];
}

+ (void)registerExternalJSHandler {
    
    [[[self share].externalhandlerRegisterFileSet copy] enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self registerObjCJavaScriptHandlerWithFilePath:obj];
    }];
    
    [[[self share].externalhandlersRegister copy] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![[self share].jsBridgeHandlersMapping[HandlersKey] containsObject:key]) {
            [[self share].jsBridgeHandlersMapping[HandlersKey] addObject:key];
            [[self share].currentBridge registerHandler:key handler:obj];
        }
    }];
}

+ (BOOL)verifyHandlerDataFormate:(NSDictionary *)data {
//    dispatch_semaphore_wait(mutex, DISPATCH_TIME_FOREVER);
    NSAssert([data isKindOfClass:[NSDictionary class]], @"LLWebJSBridgeManage register handler fail, handlerInfo must be a dictionary.");
    NSAssert(([data allKeys].count == 3)||([data allKeys].count == 2), @"LLWebJSBridgeManage register handler fail, handler's param key not legal.");
    NSAssert(([data[@"param"] isKindOfClass:[NSDictionary class]]||data[@"param"]==nil) && [data[@"handler"] isKindOfClass:[NSString class]], @"LLWebJSBridgeManage register handler fail, handler is not correct type.");
    NSAssert(NSClassFromString(data[@"executableObject"]) != NULL, @"LLWebJSBridgeManage register handler fail, executableObject '%@' not exist.", data[@"executableObject"] != nil ? data[@"executableObject"] : @"");
    NSAssert1(![[self share].jsBridgeHandlersMapping[HandlersKey] containsObject:data[@"handler"]], @"LLWebJSBridgeManage register handler fail, '%@' handler is already register.", data[@"handler"]);
    [data[@"param"] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSAssert1([obj[@"required"] isKindOfClass:[NSNumber class]], @"LLWebJSBridgeManage register handler fail, param (%@)'s required not presenet or invalid.", key);
//        NSAssert1(([obj[@"required"] boolValue]), @"WebJSBridgeImpl register handler fail, param (%@)'s required not presenet or invalid.", key);
//
//        if ([obj[@"required"] boolValue]) {
//
//        }
    }];

    
    
//    dispatch_semaphore_signal(mutex);
    return YES;
}

+ (void)registerJSBridgeHandlerWithHandlerFile:(NSString *)filePath {
    [[self share].externalhandlerRegisterFileSet addObject:filePath];
    if ([self share].currentBridge) {
        [self registerExternalJSHandler];
    }
}

+ (void)registerJSBridgeHandler:(NSString *)handler callback:(void(^)(id data, void(^)(id responseCallback)))callback {
    NSAssert([handler isKindOfClass:[NSString class]], @"WebJSBridgeImpl register handler fail, handler name must be a string.");
    NSAssert1(![[self share].jsBridgeHandlersMapping[HandlersKey] containsObject:handler], @"WebJSBridgeImpl register handler fail, '%@' handler is already register.", handler);
    [[self share].externalhandlersRegister setObject:callback forKey:handler];
    if ([self share].currentBridge) {
        [[self share].currentBridge registerHandler:handler handler:callback];
        [[self share].jsBridgeHandlersMapping[HandlersKey] addObject:handler];
    }
    
}

+ (void)responseForJSBridgeHandler:(NSString *)handler callback:(void(^)(id data, void(^responseCallback)(id response)))callback {
    NSAssert1([handler isKindOfClass:[NSString class]], @"WebJSBridgeImpl register handler fail, '%@' handler is invalid.", handler);
     NSAssert1([[self share].jsBridgeHandlersMapping[HandlersKey] containsObject:handler], @"WebJSBridgeImpl response handler fail, '%@' handler is not register.", handler);
    NSAssert(callback != NULL, @"WebJSBridgeImpl response handler fail, callback may not be null.");
    if ([self share].currentBridge) {
        [[self share].currentBridge registerHandler:handler handler:callback];
    }
 

}

- (void)webViewDidClose:(NSNotification *)notification {
    self.currentBridge = nil;
    WKWebView *web = notification.object;
    if (web) {
        WebViewJavascriptBridge *bridge = self.jsBridgeWebViewMapping[[NSString stringWithFormat:@"%p", web]];
        [self.jsBridgeWebViewMapping removeObjectForKey:[NSString stringWithFormat:@"%p", web]];
        if (bridge) {
            [self.jsBridgeHandlersMapping removeObjectForKey:[NSString stringWithFormat:@"%p", bridge]];
        }
    }
    
}

+ (NSDictionary *)standardSuccessfulJSBridgeResponse {
    return @{
             @"code":@0,
             @"msg":@"success",
             };
}

+ (NSDictionary *)standardFailureJSBridgeResponse {
    return @{
             @"code":@-1,
             @"msg":@"fail",
             };
}
+ (WebViewJavascriptBridge *)currentWebviewBridge {
    return [self share].currentBridge;
}


//+ (NSDictionary *)parameterDefinitionForHandler:(NSString *)handler {
//
//}


@end

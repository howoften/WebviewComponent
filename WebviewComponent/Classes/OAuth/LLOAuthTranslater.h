//
//  LLOAuthTranslater.h
//  WebviewComponent
//
//  Created by 刘江 on 2019/8/22.
//

#import <Foundation/Foundation.h>

@protocol LLWebViewOAuthCoordinateProtocol <NSObject>

@required
@property (nonatomic)BOOL isAuthPage;
- (void)webviewOAuthDidFinishedWithRedirectURL:(NSString *)redirectURL;

@end

@interface LLOAuthTranslater : NSObject

+ (void)translateAccessTokenWithRequestURL:(NSString *)URL accessToken:(NSString *)accessToken param:(NSDictionary *)param didFinished:(void(^)(id responseObject))finished;

@end

//
//  NetManager.h
//  Empty
//
//  Created by 刘江 on 2018/11/14.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLNetReachability.h"

@interface LLNetManager : NSObject

@property (nonatomic, assign)NSUInteger timeoutInterval;


+ (NSURLSessionDataTask *)getWithUrlString:(NSString *)url parameters:(NSDictionary *)parameters success:(void(^)(id response))successBlock failure:(void(^)(NSError *error))failureBlock;

+ (NSURLSessionDataTask *)postWithUrlString:(NSString *)url parameters:(NSDictionary *)parameters success:(void(^)(id response))successBlock failure:(void(^)(NSError *error))failureBlock;

+ (NSURLSessionDataTask *)postFormWithUrlString:(NSString *)url parameters:(NSDictionary *)parameters success:(void(^)(id response))successBlock failure:(void(^)(NSError *error))failureBlock;

+ (NSURLSessionDataTask *)postApplicationJsonWithUrlString:(NSString *)url parameters:(NSDictionary *)parameters success:(void(^)(id response))successBlock failure:(void(^)(NSError *error))failureBlock;

+ (void)setHttpHeader:(NSString *)value path:(NSString *)path;

+ (void)startNetReachilityMonitorWithHostName:(NSString *)hostName;
+ (NetworkStatus)currentReachabilityStatus;

@end

//
//  NetManager.m
//  Empty
//
//  Created by 刘江 on 2018/11/14.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import "LLNetManager.h"
#import "LLRequestSignatureGenerator.h"
#define kBoundary @"--Boundary"
#define BoundaryBeginData [[NSString stringWithFormat:@"%@\r\n", kBoundary] dataUsingEncoding:NSUTF8StringEncoding]
#define BoundaryEndData [[NSString stringWithFormat:@"%@--\r\n", kBoundary] dataUsingEncoding:NSUTF8StringEncoding]
#define FormEncoding(a) [a dataUsingEncoding:NSUTF8StringEncoding]
#define NewLineData [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]

#define SignToken @"FHK3U751y1gQYo2rYSdXvU5RrBJY4OFA"
@interface LLNetManager ()

@property (nonatomic, strong)NSURLSessionConfiguration *sessionConfig;

@property (nonatomic, strong)NSURLSession *session;

@property (nonatomic, strong)NSMutableDictionary *httpHeader;

@property (nonatomic, strong)LLNetReachability *reachability;
@end

@implementation LLNetManager

static LLNetManager *manager = nil;

+ (LLNetManager *)shareInstance {
    if (!manager) {
        manager = [[LLNetManager alloc] init];
        [manager initOptions];
        //我们的服务器受不了😂
        [LLNetManager startNetReachilityMonitorWithHostName:@"www.taobao.com"];
    }
    return manager;
}

- (void)initOptions {
    if (!_sessionConfig) {
        _sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        _sessionConfig.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:_sessionConfig delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    }
    self.timeoutInterval = 7;
//    self.httpHeader = [NSMutableDictionary dictionaryWithObjectsAndKeys:[LLNetManager getRequestHeaderUA], @"User-Agent", nil];
    self.httpHeader = [NSMutableDictionary dictionaryWithCapacity:0];
    _sessionConfig.HTTPAdditionalHeaders = [self.httpHeader copy];

    
}

- (void)setTimeoutInterval:(NSUInteger)timeoutInterval {
    if (timeoutInterval < 3) {
        timeoutInterval = 3;
    }
    _timeoutInterval = timeoutInterval;
}

+ (void)setHttpHeader:(NSString *)value path:(NSString *)path {
    if (![path isKindOfClass:[NSString class]]) {
        return;
    }

    if ([value isKindOfClass:[NSString class]]) {
        [[self shareInstance].httpHeader setObject:value forKey:path];
    }else {
        [[self shareInstance].httpHeader removeObjectForKey:path];
    }
}

+ (NSURLSessionDataTask *)getWithUrlString:(NSString *)url parameters:(NSDictionary *)parameters success:(void(^)(id response))successBlock failure:(void(^)(NSError *error))failureBlock {
    [self setHttpHeader:@"application/x-www-form-urlencoded" path:@"Content-Type"];
    
    NSString *signedValue = [LLRequestSignatureGenerator signParameter:parameters signToken:SignToken];
    if (signedValue && ![parameters objectForKey:@"sign"]) {
        NSMutableDictionary *newParam = [parameters mutableCopy];
        [newParam setObject:signedValue forKey:@"sign"];
        parameters = [newParam copy];
    }
    
//    [self shareInstance].sessionConfig.HTTPAdditionalHeaders = [[self shareInstance].httpHeader copy];
    __block NSMutableString *urlQuery = [NSMutableString string];
    if ([parameters respondsToSelector:@selector(enumerateKeysAndObjectsUsingBlock:)]) {
        url = [url stringByAppendingString:@"?"];
        [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [urlQuery appendFormat:@"%@=%@&", key, obj];
        }];
        if (urlQuery.length > 0) {
            urlQuery = [[urlQuery substringToIndex:urlQuery.length-1] mutableCopy];//123
        }
    }
    if (urlQuery.length > 0) {
        url = [url stringByAppendingString:urlQuery];
    }
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:[self shareInstance].timeoutInterval];
    NSDictionary *headerInfo = [[self shareInstance].httpHeader copy];
    [headerInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [request addValue:obj forHTTPHeaderField:key];
    }];
    NSURLSessionDataTask *dataTask = [[self shareInstance].session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (failureBlock) {
                failureBlock(error);
            }
        } else if(successBlock){
            NSError *error = nil;
            id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (error) {
                jsonObj = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            successBlock(jsonObj);
        }
    }];
    [dataTask resume];
    
    return dataTask;
}

+ (NSURLSessionDataTask *)postWithUrlString:(NSString *)url parameters:(NSDictionary *)parameters success:(void(^)(id response))successBlock failure:(void(^)(NSError *error))failureBlock {
    [self setHttpHeader:@"application/x-www-form-urlencoded" path:@"Content-Type"];
    
    NSString *signedValue = [LLRequestSignatureGenerator signParameter:parameters signToken:SignToken];
    if (signedValue && ![parameters objectForKey:@"sign"]) {
        NSMutableDictionary *newParam = [parameters mutableCopy];
        [newParam setObject:signedValue forKey:@"sign"];
        parameters = [newParam copy];
    }
    
    NSURL *nsurl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsurl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:[self shareInstance].timeoutInterval];
    //设置请求方式
    request.HTTPMethod = @"POST";
    NSDictionary *headerInfo = [[self shareInstance].httpHeader copy];
    [headerInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [request addValue:obj forHTTPHeaderField:key];
    }];
    __block NSMutableString *urlQuery = [NSMutableString string];
    if ([parameters respondsToSelector:@selector(enumerateKeysAndObjectsUsingBlock:)]) {
        [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [urlQuery appendFormat:@"%@=%@&", key, obj];
        }];
        if (urlQuery.length > 0) {
            urlQuery = [[urlQuery substringToIndex:urlQuery.length-1] mutableCopy];//123
        }
    }
    if (urlQuery.length > 0) {
        request.HTTPBody = [urlQuery dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSURLSessionDataTask *dataTask = [[self shareInstance].session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (failureBlock) {
                failureBlock(error);
            }
        } else if(successBlock) {
            NSError *error = nil;
            id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (error) {
                jsonObj = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            successBlock(jsonObj);
        }
    }];
    [dataTask resume];

    return dataTask;
}

+ (NSURLSessionDataTask *)postApplicationJsonWithUrlString:(NSString *)url parameters:(NSDictionary *)parameters success:(void(^)(id response))successBlock failure:(void(^)(NSError *error))failureBlock {
    [self setHttpHeader:@"application/json" path:@"Content-Type"];
    
    NSString *signedValue = [LLRequestSignatureGenerator signParameter:parameters signToken:SignToken];
    if (signedValue && ![parameters objectForKey:@"sign"]) {
        NSMutableDictionary *newParam = [parameters mutableCopy];
        [newParam setObject:signedValue forKey:@"sign"];
        parameters = [newParam copy];
    }
    
    NSURL *nsurl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsurl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:[self shareInstance].timeoutInterval];
    //设置请求方式
    request.HTTPMethod = @"POST";
    NSDictionary *headerInfo = [[self shareInstance].httpHeader copy];
    [headerInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [request addValue:obj forHTTPHeaderField:key];
    }];
    if ([parameters isKindOfClass:[NSDictionary class]] && parameters.allKeys.count > 0) {
        NSString *strDic = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
        request.HTTPBody = [strDic dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSURLSessionDataTask *dataTask = [[self shareInstance].session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (failureBlock) {
                failureBlock(error);
            }
        } else if(successBlock) {
            NSError *error = nil;
            id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (error) {
                jsonObj = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            successBlock(jsonObj);
        }
    }];
    [dataTask resume];
    
    return dataTask;
}

+ (NSURLSessionDataTask *)postFormWithUrlString:(NSString *)url parameters:(NSDictionary *)parameters success:(void(^)(id response))successBlock failure:(void(^)(NSError *error))failureBlock {
    [self setHttpHeader:@"multipart/form-data; boundary=Boundary" path:@"Content-Type"];
    
    NSString *signedValue = [LLRequestSignatureGenerator signParameter:parameters signToken:SignToken];
    if (signedValue && ![parameters objectForKey:@"sign"]) {
        NSMutableDictionary *newParam = [parameters mutableCopy];
        [newParam setObject:signedValue forKey:@"sign"];
        parameters = [newParam copy];
    }
    
    NSMutableData *body = [NSMutableData data];
    if ([parameters respondsToSelector:@selector(enumerateKeysAndObjectsUsingBlock:)]) {
        [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [body appendData:BoundaryBeginData];
            NSString *keyStr = [NSString stringWithFormat:@"%@", key];
            if ([obj isKindOfClass:[NSString class]]) {
                [body appendData:FormEncoding([@"Content-Disposition: form-data; name=" stringByAppendingString:keyStr])];
                [body appendData:NewLineData];
                [body appendData:NewLineData];
                [body appendData:FormEncoding(obj)];
                [body appendData:NewLineData];
            }else if ([obj isKindOfClass:[NSData class]]) {
                [body appendData:FormEncoding([[[@"Content-Disposition: form-data; name=" stringByAppendingString:keyStr] stringByAppendingString:@" fileName="] stringByAppendingString:keyStr])];
                [body appendData:NewLineData];
                [body appendData:NewLineData];
                [body appendData:FormEncoding(obj)];
                [body appendData:NewLineData];
            }else if ([obj conformsToProtocol:@protocol(NSCoding)]) {
                [body appendData:FormEncoding([@"Content-Disposition: form-data; name=" stringByAppendingString:keyStr])];
                [body appendData:NewLineData];
                [body appendData:NewLineData];
                [body appendData:[NSKeyedArchiver archivedDataWithRootObject:obj]];
                [body appendData:NewLineData];
            }else {
                NSError *error = nil;
                NSData *serialdata = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:&error];
                if (!error) {
                    [body appendData:FormEncoding([@"Content-Disposition: form-data; name=" stringByAppendingString:keyStr])];
                    [body appendData:NewLineData];
                    [body appendData:NewLineData];
                    [body appendData:serialdata];
                    [body appendData:NewLineData];
                }
            }
            
        }];
        [body appendData:BoundaryEndData];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:[self shareInstance].timeoutInterval];
    //设置请求方式
    request.HTTPMethod = @"POST";
    request.HTTPBody = body;
    NSDictionary *headerInfo = [[self shareInstance].httpHeader copy];
    [headerInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [request addValue:obj forHTTPHeaderField:key];
    }];
     [request addValue: [NSString stringWithFormat:@"%zd",request.HTTPBody.length] forHTTPHeaderField:@"Content-Length"];
    NSURLSessionDataTask *dataTask = [[self shareInstance].session dataTaskWithRequest:[request copy] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (failureBlock) {
                failureBlock(error);
            }
        } else if(successBlock) {
            NSError *error = nil;
            id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (error) {
                jsonObj = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            successBlock(jsonObj);
        }
    }];
    [dataTask resume];
    
    return dataTask;
}

+ (void)startNetReachilityMonitorWithHostName:(NSString *)hostName {
    if (![self shareInstance].reachability) {
        [self shareInstance].reachability = [LLNetReachability reachabilityWithHostName:hostName];
    }
}

+ (NetworkStatus)currentReachabilityStatus {
    return [[self shareInstance].reachability currentReachabilityStatus];
}

@end

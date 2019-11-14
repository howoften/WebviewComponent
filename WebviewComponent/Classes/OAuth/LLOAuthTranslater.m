//
//  LLOAuthTranslater.m
//  WebviewComponent
//
//  Created by 刘江 on 2019/8/22.
//

#import <CommonCrypto/CommonDigest.h>
#import "LLOAuthTranslater.h"
#import "LLNetManager.h"
#define SignToken @"1234567890"
//#define BaseURL @"https://lzgj.test.brightcns.cn/gateway"
@interface LLOAuthTranslater ()
@property (nonatomic, strong)NSDateFormatter *formatter;
@end

@implementation LLOAuthTranslater

+ (LLOAuthTranslater *)share {
    static LLOAuthTranslater * trans = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self configHTTPHeader];
        trans = [[LLOAuthTranslater alloc] init];
    });
    return trans;

}

+ (void)configHTTPHeader {
    //LZTransport/3.0.1 (iPhone; iOS 10.3.3; Scale/2.00)
    NSString *ua = [[[[[[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"] stringByAppendingString:@"/"] stringByAppendingString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]] stringByAppendingString:@" (iPhone; iOS "] stringByAppendingString:[UIDevice currentDevice].systemVersion] stringByAppendingString:@"; Scale/"] stringByAppendingFormat:@"%.2f)", [UIScreen mainScreen].scale];
    [LLNetManager setHttpHeader:ua path:@"User-Agent"];
}

+ (NSDictionary *)commonRequestParameter {
    ///@"com.brightcns.dxlc"
    //[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]
    return @{
        @"appId":@"com.brightcns.dxlc",
        @"timestamp":[[self share].formatter stringFromDate:[NSDate date]],
        @"version":@"1.0",
        @"signType":@"MD5"
    };
}

+ (void)translateAccessTokenWithRequestURL:(NSString *)URL accessToken:(NSString *)accessToken param:(NSDictionary *)param didFinished:(void(^)(id responseObject))finished {
    if (![accessToken isKindOfClass:[NSString class]]) {
        if (finished) {
            finished(nil);
        }
    }else {
    NSMutableDictionary *requestParam = [@{
        @"method":@"open.oauth.authorize",
        @"bizReq":[self flattenJsonStringFromDictionary:param],
        @"sessionId":accessToken
    } mutableCopy];
        [requestParam addEntriesFromDictionary:[self commonRequestParameter]];
        [requestParam setObject:[self signParameter:[requestParam copy] signToken:SignToken] forKey:@"sign"];
        [LLNetManager postApplicationJsonWithUrlString:URL parameters:requestParam success:^(id response) {
            if (finished) {
                if ([response isKindOfClass:[NSDictionary class]] && [response[@"bizResp"] isKindOfClass:[NSString class]]) {
                    NSMutableDictionary *jsonObject = [response mutableCopy];
                    id resp_release = [self jsonObjectFromString:response[@"bizResp"]];
//                    if (resp_release) {
//                        [jsonObject setObject:resp_release forKey:@"bizResp"];
//                    }
                    if ([resp_release isKindOfClass:[NSDictionary class]] && [resp_release[@"redirectUri"] isKindOfClass:[NSString class]]) {
                        NSMutableDictionary *mm = [NSMutableDictionary dictionaryWithDictionary:resp_release];
                        [mm setObject:[resp_release[@"redirectUri"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"redirectUri"];
                        [jsonObject setObject:[mm copy] forKey:@"bizResp"];
                    }
                    finished([jsonObject copy]);
                }else {
                    finished(response);
                }
            }
        } failure:^(NSError *error) {
            if (finished) {
                finished(@{@"code":[NSString stringWithFormat:@"%ld", error.code], @"msg":error.localizedDescription});
            }
        }];


    }


}


- (NSDateFormatter *)formatter {
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyyMMddHHmmss"];
        [_formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    }
    return _formatter;
}

+ (NSString *)signParameter:(NSDictionary *)param signToken:(NSString *)signToken {
    if (!param || param.allKeys.count < 1 || signToken.length < 1) {
        return nil;
    }
    NSArray *keys = param.allKeys;

    NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch|NSNumericSearch|

    NSWidthInsensitiveSearch|NSForcedOrderingSearch;

    NSComparator sort = ^(NSString *obj1,NSString *obj2){

        NSRange range = NSMakeRange(0,obj1.length);

        return [obj1 compare:obj2 options:comparisonOptions range:range];

    };
    NSMutableString *signString = [NSMutableString stringWithCapacity:0];
    NSArray *sortedKeys = [keys sortedArrayUsingComparator:sort];
    for (int i = 0; i < sortedKeys.count; i++) {
        [signString appendFormat:@"%@=%@", sortedKeys[i], param[sortedKeys[i]]];
        if (i != sortedKeys.count-1) {
            [signString appendString:@"&"];
        }
    }
    [signString appendString:signToken];
    return [self md5:signString];


}

+ (NSString *)md5:(NSString *)input {
    const char *cStr = [[input dataUsingEncoding:NSUTF8StringEncoding] bytes];

    unsigned char digest[16];
    CC_MD5(cStr, (uint32_t)[[input dataUsingEncoding:NSUTF8StringEncoding] length], digest);

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];

    return output;
}

+ (NSString *)flattenJsonStringFromDictionary:(NSDictionary *)dict
{
    NSMutableString *flatten_str = nil;
    if ([dict isKindOfClass:[NSArray class]]) {
        flatten_str = [NSMutableString stringWithString:@"["];
        NSArray *arr_copy = (NSArray *)[dict copy];
        for (int i = 0; i <arr_copy.count; i++) {
            id obj = arr_copy[i];
            BOOL isLast = ([arr_copy indexOfObject:obj]+1 == [arr_copy count]);
            if ([obj isKindOfClass:[NSString class]]) {
                if (isLast) {
                    [flatten_str appendFormat:@"\"%@\"", obj];
                }else {
                    [flatten_str appendFormat:@"\"%@\",", obj];
                }
            }else if ([obj isKindOfClass:[NSDictionary class]]) {
                NSString *str = [self flattenJsonStringFromDictionary:obj];
                if (str) {
                    if (isLast) {
                        [flatten_str appendFormat:@"%@", str];
                    }else {
                        [flatten_str appendFormat:@"%@,", str];
                    }
                }
            }else if ([obj isKindOfClass:[NSArray class]]) {
                NSString *str = [self flattenJsonStringFromDictionary:obj];
                if (str) {
                    if (isLast) {
                        [flatten_str appendFormat:@"%@", str];
                    }else {
                        [flatten_str appendFormat:@"%@,", str];
                    }
                }
            }else {
                NSString *str = [self flattenJsonStringFromDictionary:obj];
                if (str) {
                    if (isLast) {
                        [flatten_str appendFormat:@"%@", str];
                    }else {
                        [flatten_str appendFormat:@"%@,", str];
                    }
                }
            }
        }
        [flatten_str appendString:@"]"];
    }else if ([dict isKindOfClass:[NSDictionary class]]) {
        NSArray *keys = dict.allKeys;

        NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch|NSNumericSearch|

        NSWidthInsensitiveSearch|NSForcedOrderingSearch;

        NSComparator sort = ^(NSString *obj1,NSString *obj2){

            NSRange range = NSMakeRange(0,obj1.length);

            return [obj1 compare:obj2 options:comparisonOptions range:range];

        };
        flatten_str = [NSMutableString stringWithFormat:@"{"];
        NSArray *sortedKeys = [keys sortedArrayUsingComparator:sort];
        for (int i = 0; i < sortedKeys.count; i++) {
            BOOL isLast = (i == sortedKeys.count -1);

            [flatten_str appendFormat:@"\"%@\":", sortedKeys[i]];
            if ([dict[sortedKeys[i]] isKindOfClass:[NSString class]]) {
                if (isLast) {
                    [flatten_str appendFormat:@"\"%@\"", dict[sortedKeys[i]]];
                }else {
                    [flatten_str appendFormat:@"\"%@\",", dict[sortedKeys[i]]];
                }
            }else if ([dict[sortedKeys[i]] isKindOfClass:[NSDictionary class]]){
                NSString *str = [self flattenJsonStringFromDictionary:dict[sortedKeys[i]]];
                if (str) {
                    if (isLast) {
                        [flatten_str appendFormat:@"%@", str];
                    }else {
                        [flatten_str appendFormat:@"%@,", str];
                    }
                }
            }else if ([dict[sortedKeys[i]] isKindOfClass:[NSArray class]]){
                NSString *str = [self flattenJsonStringFromDictionary:dict[sortedKeys[i]]];
                if (str) {
                    if (isLast) {
                        [flatten_str appendFormat:@"%@", str];
                    }else {
                        [flatten_str appendFormat:@"%@,", str];
                    }
                }
            }else {
                NSString *str = [self flattenJsonStringFromDictionary:dict[sortedKeys[i]]];
                if (str) {
                    if (isLast) {
                        [flatten_str appendFormat:@"%@", str];
                    }else {
                        [flatten_str appendFormat:@"%@,", str];
                    }
                }
            }
        }
        [flatten_str appendString:@"}"];
    }else if(dict != nil) {
        return [NSString stringWithFormat:@"%@", dict];
    }else {
        return nil;
    }
    return flatten_str;

}

+ (id)jsonObjectFromString:(NSString *)string {
    id jsonObj = nil;
    NSError *err;
        if ([string isKindOfClass:[NSString class]] || [string length] > 0) {
            NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
            jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
            if(err) {
                NSLog(@"jsonObjectFromString error: %@",err);
            }
        }

        return jsonObj;
}

@end

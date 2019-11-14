//
//  LLSignatureGenerator.m
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/10.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import "LLRequestSignatureGenerator.h"
#import <CommonCrypto/CommonDigest.h>

@implementation LLRequestSignatureGenerator

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

@end

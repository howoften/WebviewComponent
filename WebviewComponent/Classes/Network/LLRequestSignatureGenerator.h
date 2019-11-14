//
//  LLSignatureGenerator.h
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/10.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLRequestSignatureGenerator : NSObject

+ (NSString *)signParameter:(NSDictionary *)param signToken:(NSString *)signToken;

@end

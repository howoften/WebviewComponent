//
//  UIImage+Compress.h
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/24.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Compress)

//压缩图片
+ (NSData *)compressImage:(UIImage *)image toByte:(NSUInteger)maxLength;
/**
 @abstract 压缩图片并实时回调图片压缩状态
 @param image 带压缩图片
 @param maxLength 压缩至目标size(不精确)
 @param callback 回调
 
 */
//压缩图片 带回调
+ (NSData *)compressImage:(UIImage *)image toByte:(NSUInteger)maxLength callback:(void(^)( NSData *imgData, CGFloat progress, bool *stop))callback;

@end

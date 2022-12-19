//
//  UIImage+Compress.m
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/24.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import "UIImage+Compress.h"

#define kLoopCount 5

@implementation UIImage (Compress)

+ (NSData *)compressImage:(UIImage *)image toByte:(NSUInteger)maxLength {
    // Compress by quality
    CGFloat compression = 1.0f;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return data;
    
    NSLog(@"begin compress--%lu==%@", (unsigned long)data.length, NSStringFromCGSize(image.size));
    float i = 1.01f;
    NSUInteger lastCompressSize = data.length + 1;
    while (data.length > maxLength*1.2 && lastCompressSize > data.length) {
        lastCompressSize = data.length;
        compression = 1/i; //函数模型 1/x
        data = UIImageJPEGRepresentation(image, compression);
        i++;
        NSLog(@"compressed--%lu====%@", (unsigned long)data.length, NSStringFromCGSize(image.size));
        
    }
    return [self compressImageData:data toByte:maxLength];
}
+ (NSData *)compressImageData:(NSData *)imageData toByte:(NSUInteger)maxLength {
    // Compress by quality
    CGFloat compression = 1.0f;
    NSData *data = imageData;
    
    UIImage *resultImage = [UIImage imageWithData:data];
    if (data.length < maxLength) return data;
    
    // Compress by size
    NSUInteger lastDataLength = data.length+1;
    int count = 0;
    CGFloat step = 1.01, stepSize = 0.1;
    while (data.length > maxLength && count < kLoopCount) {
        lastDataLength = data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * 1/step),
                                 (NSUInteger)(resultImage.size.height * 1/step)); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *tempImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *tem = UIImageJPEGRepresentation(tempImg, compression);
        if (size.width < 70 || size.height < 70) { //minsize 70*70
            break;
        }
        if (tem.length > 0) {
            resultImage = tempImg;
            data = tem;
            count = 0;
        }
        if (data.length >= lastDataLength){
            count++;
        }
        step += stepSize;
        NSLog(@"resizing--%lu====%@", (unsigned long)data.length, NSStringFromCGSize(size));
    }
    return data;
}

+ (NSData *)compressImage:(UIImage *)image toByte:(NSUInteger)maxLength callback:(void(^)(NSData *imgData, CGFloat progress, bool *stop))callback {
    // Compress by quality
    CGFloat compression = 1;
    bool *isStop = (bool *)malloc(sizeof(bool)*1);
    *isStop = false;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    CGFloat originDataLength = (CGFloat)data.length;
    
    if (originDataLength < maxLength) {
        if (callback) {
            *isStop = true;
            callback(data, 1.f, isStop);
            return data;
        }
    }
    
    //每压缩一遍 回调一次 并判断isStop标志
    if (callback) {
        CGFloat progress = (originDataLength-data.length)/(originDataLength-maxLength);
        *isStop = progress > 1;
        callback([data copy], progress > 1 ? 1.f : progress, isStop);
        //        NSLog(@"hhhhh%f", (originDataLength-data.length)/(originDataLength-maxLength));
    }
    if (data.length < maxLength || *isStop){
        *isStop = true;
        callback(data, 1.0f, isStop);
        return data;
    }
    
    //    NSLog(@"begin compress--%lu==%@", (unsigned long)data.length, NSStringFromCGSize(image.size));
    float i = 1.01f;
    NSUInteger lastCompressSize = data.length + 1;
    while (data.length > maxLength*1.2 && lastCompressSize > data.length && !(*isStop)) {
        lastCompressSize = data.length;
        compression = 1/i; //函数模型 1/x
        data = UIImageJPEGRepresentation(image, compression);
        image = [[UIImage alloc] initWithData:data];
        i++;
        //        NSLog(@"compressed--%lu====%@", (unsigned long)data.length, NSStringFromCGSize(image.size));
        CGFloat progress = (originDataLength-data.length)/(originDataLength-maxLength);
        if (callback) {
            *isStop = progress > 1;
            callback([data copy], progress > 1 ? 1.f : progress, isStop);
            if (progress >= 1.f) {
                return data;
            }
        }
    }
    
//    UIImage *resultImage = [UIImage imageWithData:data];
    if (data.length < maxLength || (*isStop)) {
        *isStop = true;
        callback(data, 1.0f, isStop);
        return data;
    }
    
    // Compress by size
    NSUInteger lastDataLength = data.length+1;
    int count = 0;
    CGFloat step = 1.01, stepSize = 0.1;
    while (data.length > maxLength && count < kLoopCount && !(*isStop)) {
        lastDataLength = data.length;
        CGSize size = CGSizeMake((NSUInteger)(image.size.width * 1/step),
                                 (NSUInteger)(image.size.height * 1/step)); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *tempImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *tem = UIImageJPEGRepresentation(tempImg, compression);
        if (size.width < 70 || size.height < 70) { //minsize 70*70
            break;
        }
        if (tem.length > 0) {
            image = tempImg;
            data = tem;
            count = 0;
        }
        if (data.length >= lastDataLength){
            count++;
        }
        step += stepSize;
        CGFloat progress = (originDataLength-data.length)/(originDataLength-maxLength);
        if (callback) {
            *isStop = progress > 1;
            callback([data copy], progress > 1 ? 1.f : progress, isStop);
            if (progress >= 1.f) {
                return data;
            }
        }
    }
    //最终返回
    *isStop = true;
    if (callback) {
        callback([data copy], 1.f, isStop);
    }
    return data;
}

@end

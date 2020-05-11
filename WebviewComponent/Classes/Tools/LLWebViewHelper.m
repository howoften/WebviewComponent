//
//  LLWebViewHelper.m
//  WebviewComponent
//
//  Created by 刘江 on 2019/7/31.
//

#import "LLWebViewHelper.h"

NSString * const LLWebScanQRCodeResultNotificationName = @"LLWebScanQRCodeResultNotificationName";
@implementation LLWebViewHelper
+ (UIViewController *)topViewController {
    
    UIViewController *resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

+ (NSString *)convertHex2Dec:(NSString *)hexString {
    
    NSString *regex = @"[0-9a-fA-F]+$";
    NSRange range = [hexString rangeOfString:regex options:NSRegularExpressionSearch];
    if (range.location == NSNotFound) {
        return nil;
    }
    hexString = [hexString substringWithRange:range];
    hexString = [hexString uppercaseString];
    if (!hexString || hexString.length < 1) {
        return @"";
    }
    NSUInteger boundary = hexString.length-1;
    for (int i = 0; i < hexString.length; i++) {
        char c = [hexString characterAtIndex:i];
        if (c < 48 || c > 70 || (c > 57 && c < 65)) {
            break;
        }
        boundary = i;
    }
    unsigned long long sum = 0;
    for (int i = 0; i <= boundary; i++) {
        char c = [hexString characterAtIndex:i];
        //        NSString *cString
        if (c > 47 && c < 58) {
            sum += ((c-48)*powl(16, boundary-i));
        } else if (c > 64 && c < 71){
            sum += ((c-55)*powl(16, boundary-i));
        } else {
            break;
        }
    }
    return [NSString stringWithFormat:@"%llu", sum];
}

+ (NSString *)convertDec2Hex:(NSString *)decString {
    
    decString = [decString uppercaseString];
    if (!decString || decString.length < 1) {
        return @"";
    }
    NSUInteger boundary = decString.length-1;
    for (int i = 0; i < decString.length; i++) {
        char c = [decString characterAtIndex:i];
        if (c < 48 || c > 57) {
            break;
        }
        boundary = i;
    }
    unsigned long long decNum = [[decString substringToIndex:boundary+1] longLongValue];
    unsigned int yushu = 0;
    NSArray *cArray = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"A", @"B", @"C", @"D", @"E", @"F"];
    NSMutableString *hexString = [NSMutableString string];
    //    int index = 0;
    while (decNum > 0) {
        yushu = decNum % 16;
        decNum = decNum / 16;
        [hexString insertString:[NSString stringWithFormat:@"%@", cArray[yushu]] atIndex:0];
        //        hexNum += (yushu * powl(16, index++));
    }
    return hexString;
}

+ (NSBundle *)rootBundle {
    return [NSBundle bundleForClass:[self class]];
}

+ (NSBundle *)resourceBunlde {
    NSBundle *rootBundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [rootBundle URLForResource:@"WebviewComponent" withExtension:@"bundle"];
    
    return [NSBundle bundleWithURL:url];
}

+ (NSString *)filePathForName:(NSString *)fileName sourceType:(NSString *)type {
    
    return [[self resourceBunlde] pathForResource:fileName ofType:type];
}


+ (NSString *)imagefilePathForName:(NSString *)fileName sourceType:(NSString *)type {
    NSInteger scale = [[UIScreen mainScreen] scale];
    NSString *path = [self filePathForName:[fileName stringByAppendingFormat:@"@%zdx", scale] sourceType:type];
    if (!path) {
        path = [self filePathForName:[fileName stringByAppendingFormat:@"@%zdx", 6/scale] sourceType:type];
    }
    if (!path) {
        path = [self filePathForName:fileName sourceType:type];
    }
    
    return path;
}

+ (NSString *)pngImagefilePathForName:(NSString *)fileName {
    return [self imagefilePathForName:fileName sourceType:@"png"];
}

+ (NSString *)jpegImagefilePathForName:(NSString *)fileName {
    return [self imagefilePathForName:fileName sourceType:@"jpg"];
}

+ (UIImage *)shotWithView:(UIView *)view{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)shotWithView:(UIView *)view scope:(CGRect)scope {
    CGImageRef imageRef = CGImageCreateWithImageInRect([self shotWithView:view].CGImage, scope);
    UIGraphicsBeginImageContextWithOptions(scope.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, scope.size.width, scope.size.height);
    CGContextTranslateCTM(context, 0, rect.size.height);//下移
    CGContextScaleCTM(context, 1.0f, -1.0f);//上翻
    CGContextDrawImage(context, rect, imageRef);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(imageRef);
    return image;
}

+ (NSString *)longestSubStringBetweenFirstString:(NSString *)first andSecondString:(NSString *)second {
    if (![first isKindOfClass:[NSString class]] || ![second isKindOfClass:[NSString class]]) {
        return nil;
    }
    first = [first stringByReplacingOccurrencesOfString:@"_" withString:@""];
    second = [second stringByReplacingOccurrencesOfString:@"_" withString:@""];
    int start = 0, max = 0;
    for(int i = 0; i < first.length; i++)
    {
//        unichar c1 = [first characterAtIndex:i];
        for(int j = 0; j < second.length; j++)
        {
            int num = 0;
            int start1=i;
            int start2=j;
//           unichar c2 = [second characterAtIndex:j];
            while((start1 < first.length) && (start2 < second.length) && ([first characterAtIndex:start1++] == [second characterAtIndex:start2++]))
                num++;
            if(num >= max)//如果num是当前最大匹配的个数，则赋给max，并且在start记下str1最长匹配开始的位置
            {
                max = num;
                start = i;
            }
        }
    }
    return [first substringWithRange:NSMakeRange(start, max)];
}

+ (BOOL)typeCompareForUnspecialObject:(id)object1 another:(id)object2 {
    if ([NSStringFromClass([object1 class]) isEqualToString:NSStringFromClass([object2 class])]) {
        return YES;
    }
    NSArray *commonTypes = @[
                             @"array",
                             @"nsarray",
                             @"dictionary",
                             @"nsdictionary",
                             @"bool",
                             @"data",
                             @"nsdata",
                             @"date",
                             @"nsdate",
                             @"number",
                             @"nsnumber",
                             @"string",
                             @"nsstring"
                             ];
    NSString *type = [self longestSubStringBetweenFirstString:NSStringFromClass([object1 class]) andSecondString:NSStringFromClass([object2 class])];
    if ([type isKindOfClass:[NSString class]]) {
        return [commonTypes containsObject:[type lowercaseString]];
    }
    return NO;
}

+ (BOOL)typeCompareForUnspecialObject:(id)object1 class:(Class)classType {
    return [self typeCompareForUnspecialObject:object1 another:[classType new]];
}

+ (NSDictionary *)requestParameterForURL:(NSURL *)url {
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString *urlQuery = nil;
    if ([url.absoluteString rangeOfString:@"?"].length != 0) {
        urlQuery = [url.absoluteString substringFromIndex:[url.absoluteString rangeOfString:@"?"].location+1];
    }
   
    NSArray *argusPair = [urlQuery componentsSeparatedByString:@"&"];
    [argusPair enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *key_value = [obj componentsSeparatedByString:@"="];
        if (key_value.count == 2) {
            [result setObject:key_value.lastObject forKey:key_value.firstObject];
        }
    }];
    return [result copy];
}

+ (BOOL)validHexColorCodeString:(NSString *)colorString {
    if (![colorString isKindOfClass:[NSString class]] || (colorString.length != 6 && colorString.length != 7)) {
        return NO;
    }else {
        NSString *regex = @"^#?[0-9a-fA-F]{6}$";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        return [predicate evaluateWithObject:colorString];
    }
}


+ (NSString *)imgElementForHTMLText:(NSString *)text {
    if (![text isKindOfClass:[NSString class]]) {
           return nil;
       }

       
       NSError *error;
       NSString *regulaStr = @"<img[^>]+src\\s*=\\s*['\"]([^'\"]+)['\"][^>]*>";
       NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                              options:NSRegularExpressionCaseInsensitive
                                                                                error:&error];
       NSArray *arrayOfAllMatches = [regex matchesInString:text options:0 range:NSMakeRange(0, [text length])];

    
    NSData * data = [arrayOfAllMatches.firstObject dataUsingEncoding:NSUTF8StringEncoding];
     
    
    return @"";
}

@end

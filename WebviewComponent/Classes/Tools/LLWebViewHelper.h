//
//  LLWebViewHelper.h
//  WebviewComponent
//
//  Created by 刘江 on 2019/7/31.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LLWebViewHelper : NSObject

+ (UIViewController *)topViewController;

+ (NSBundle *)rootBundle;

+ (NSBundle *)resourceBunlde;

+ (NSString *)filePathForName:(NSString *)fileName sourceType:(NSString *)type;

+ (NSString *)imagefilePathForName:(NSString *)fileName sourceType:(NSString *)type;

+ (NSString *)pngImagefilePathForName:(NSString *)fileName;

+ (NSString *)jpegImagefilePathForName:(NSString *)fileName;

+ (UIImage *)shotWithView:(UIView *)view;

+ (UIImage *)shotWithView:(UIView *)view scope:(CGRect)scope;

+ (NSString *)longestSubStringBetweenFirstString:(NSString *)first andSecondString:(NSString *)second;

+ (NSString *)convertHex2Dec:(NSString *)hexString;

+ (NSString *)convertDec2Hex:(NSString *)decString;

+ (NSDictionary *)requestParameterForURL:(NSURL *)url;

+ (NSString *)imgElementForHTMLText:(NSString *)text;

+ (BOOL)validHexColorCodeString:(NSString *)colorString;

+ (BOOL)typeCompareForUnspecialObject:(id)object1 another:(id)object2;
+ (BOOL)typeCompareForUnspecialObject:(id)object1 class:(Class)classType;

@end

NS_ASSUME_NONNULL_END

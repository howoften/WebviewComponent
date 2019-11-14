//
//  UINavigationItem+AttributeTitle.m
//  WXCitizenCard
//
//  Created by 刘江 on 2018/7/31.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import "UINavigationItem+AttributeTitle.h"
#import <objc/runtime.h>

static const void * attributeTitleKey = &attributeTitleKey;

@implementation UINavigationItem (AttributeTitle)

- (void)setAttributeTitle:(NSAttributedString *)attributeTitle {
    UIView *title = self.titleView;
    if (![title isKindOfClass:[UILabel class]]) {
        title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [self getAttributeStringWidth:attributeTitle], 44)];
        self.titleView = title;
    }else if (![((UILabel *)title).text isEqualToString:attributeTitle.string]) {
        title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [self getAttributeStringWidth:attributeTitle], 44)];
        self.titleView = title;
    }
    ((UILabel *)title).textAlignment = NSTextAlignmentCenter;
    ((UILabel *)title).attributedText = attributeTitle;
    
    objc_setAssociatedObject(self, &attributeTitleKey, attributeTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSAttributedString *)attributeTitle {
    return objc_getAssociatedObject(self, &attributeTitleKey);
}

- (CGFloat)getAttributeStringWidth:(NSAttributedString *)attrTitle {
    if (attrTitle.string.length < 1) {
        return 0.f;
    }
    
    NSRange sampling = NSMakeRange(0, 1);
    return ceilf([attrTitle.string boundingRectWithSize:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 44) options:NSStringDrawingUsesFontLeading attributes:[attrTitle attributesAtIndex:0 effectiveRange:&sampling] context:nil].size.width);
    
}
@end

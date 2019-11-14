//
//  SJAlertViewPresenter.m
//  HNTransport
//
//  Created by 刘江 on 2018/7/13.
//  Copyright © 2018年 com.liangla. All rights reserved.
//http://sj.test.brightcns.cn:8806/cash.html

#import "SJAlertViewPresenter.h"
#import "BaseAlertView.h"
#import "SJNormalAlertView.h"
#import "SheetAlertView.h"

#define NullObject(object) \
({ \
BOOL flag = NO; \
if ([object isKindOfClass:[NSNull class]] || object == nil || object == Nil || object == NULL) \
flag = YES; \
if ([object isKindOfClass:[NSString class]]) \
if ([(NSString *)object length] < 1) \
flag = YES; \
if ([object isKindOfClass:[NSArray class]]) \
if ([(NSArray *)object count] < 1) \
flag = YES; \
if ([object isKindOfClass:[NSDictionary class]]) \
if ([(NSDictionary *)object allKeys].count < 1) \
flag = YES; \
(flag); \
})

@interface SJAlertViewPresenter ()
@property (nonatomic, strong)NSMutableDictionary *alertAttributes;
@property (nonatomic, strong)UIView *showView;
@end

NSString * const AlertTitleAttributes = @"AlertTitleAttributes";
NSString * const AlertContentAttributes = @"AlertContentAttributes";
NSString * const AlertClickItemsAttributes = @"AlertClickItemsAttributes";

@implementation SJAlertViewPresenter

+ (instancetype)shareInstance {
    static SJAlertViewPresenter *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SJAlertViewPresenter alloc] init];
        manager.alertAttributes = [NSMutableDictionary dictionaryWithCapacity:0];
    });
    return manager;
}

- (void)presentNormalAlertViewWithTitle:(NSString *)title contentList:(NSArray<NSString *> *)contentList bottomClickItem:(NSArray<NSString *> *)clickItems dismissFreedom:(BOOL)freedom {
    title = [self rejectInvalidValues:title];
    contentList = [self rejectInvalidValues:contentList];
    clickItems = [self rejectInvalidValues:clickItems];
    
    if (self.showView.superview) {///如果当前屏幕正在展示弹框, 返回
        return;
    }
    
    if (self.showView) {
        [self.delegate removeObserver:self forKeyPath:@"passMsg"];
    }
    
    self.delegate = [[SJNormalAlertView alloc] init];
    self.showView = [self producePresentedAlertViewWithTitle:title contentList:contentList bottomClickItem:clickItems];
    
    [self performAlertViewStyle];
    
    if (self.showView) {
        [[BaseAlertView share] setCloseStyle:!freedom];
        [[BaseAlertView share] show:self.showView withType:BaseAlertViewStyleAlert];
        [self.delegate addObserver:self forKeyPath:@"passMsg" options:NSKeyValueObservingOptionNew context:nil];
        
    }
}

- (void)presentSheetAlertViewWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles dismissFreedom:(BOOL)freedom {
    title = [self rejectInvalidValues:title];
    cancelButtonTitle = [self rejectInvalidValues:cancelButtonTitle];
    destructiveButtonTitle = [self rejectInvalidValues:destructiveButtonTitle];
    otherButtonTitles = [self rejectInvalidValues:otherButtonTitles];
    
    if (self.showView.superview) {///如果当前屏幕正在展示弹框, 返回
        return;
    }
    
    if (self.showView) {
        [self.delegate removeObserver:self forKeyPath:@"passMsg"];
    }
    
    self.delegate = [[SheetAlertView alloc] init];
    self.showView = [self producePresentedSheetAlertViewWithTitle:title cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles];
    
    if (self.showView) {
        [[BaseAlertView share] setCloseStyle:!freedom];
        [[BaseAlertView share] show:self.showView withType:BaseAlertViewStyleActionSheetDown];
        [self.delegate addObserver:self forKeyPath:@"passMsg" options:NSKeyValueObservingOptionNew context:nil];
        
    }
}


- (UIView *)producePresentedAlertViewWithTitle:(NSString *)title contentList:(NSArray<NSString *> *)contentList bottomClickItem:(NSArray<NSString *> *)clickItems {
    if ([self.delegate respondsToSelector:@selector(produceSJNormalAlertViewWithTitle:content:bottomClickItem:)]) {
        return [self.delegate produceSJNormalAlertViewWithTitle:title content:contentList.firstObject bottomClickItem:clickItems];
        
    }
    
    return nil;
}

- (UIView *)producePresentedSheetAlertViewWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles {
    if ([self.delegate respondsToSelector:@selector(produceSheetAlertViewWithTitle:cancelButtonTitle:destructiveButtonTitle:otherButtonTitles:)]) {
        return [self.delegate produceSheetAlertViewWithTitle:title cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles];
        
    }
    
    return nil;
}

- (void)performAlertViewStyle {
    if ([self.delegate respondsToSelector:@selector(configTitleStyle:contentStyle:clickItemsStyle:)]) {
        [self.delegate configTitleStyle:self.alertAttributes[AlertTitleAttributes] contentStyle:self.alertAttributes[AlertContentAttributes] clickItemsStyle:self.alertAttributes[AlertClickItemsAttributes]];
    }
    self.alertAttributes = [NSMutableDictionary dictionaryWithCapacity:0];
}

- (void)setTitleStyle:(NSDictionary *)titleAttributes contentStyle:(NSDictionary *)contentAttributes clickItemsStyle:(NSArray <NSDictionary *> *)clickItemAttributes {
    [self.alertAttributes setValue:[titleAttributes isKindOfClass:[NSDictionary class]]?titleAttributes:@{} forKey:AlertTitleAttributes];
    [self.alertAttributes setValue:[contentAttributes isKindOfClass:[NSDictionary class]]?contentAttributes:@{} forKey:AlertContentAttributes];
    [self.alertAttributes setValue:[clickItemAttributes isKindOfClass:[NSArray class]]?clickItemAttributes:@[] forKey:AlertClickItemsAttributes];
    
   
}


- (id)rejectInvalidValues:(id)obj {
    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *tempArr = [obj mutableCopy];
        for (id item in obj) {
            if (NullObject(item)) {
                [tempArr removeObject:item];
            }
        }
        return [tempArr copy];
    }else if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *tempDic = [obj mutableCopy];
        for (NSString *key in [obj allKeys]) {
            if (NullObject(tempDic[key])) {
                [tempDic removeObjectForKey:key];
            }
        }
        return [tempDic copy];
    }else {
        if (NullObject(obj)) {
            return nil;
        }
        return obj;
    }
}

- (void)dismissAnyway {
    [[BaseAlertView share] dismiss:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"passMsg"]) {
        id result = change[NSKeyValueChangeNewKey];
        [self dismissAnyway];
        if (self.execResult) {
            self.execResult(result);
        }
    }
}

- (void)dealloc {
    if (self.delegate) {
        [self.delegate removeObserver:self forKeyPath:@"passMsg"];

    }
}

@end

//
//  SJAlertViewPresenter.h
//  HNTransport
//
//  Created by 刘江 on 2018/7/13.
//  Copyright © 2018年 com.liangla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJAlertViewProduce-Protocol.h"

extern NSString * const AlertTitleAttributes;
extern NSString * const AlertContentAttributes;
extern NSString * const AlertClickItemsAttributes;

@interface SJAlertViewPresenter : NSObject
@property (nonatomic, copy)void(^execResult)(id result);
@property (nonatomic, strong)NSObject<SJAlertViewProduceDelegate> *delegate;


+ (instancetype)shareInstance;
- (void)presentNormalAlertViewWithTitle:(NSString *)title contentList:(NSArray<NSString *> *)contentList bottomClickItem:(NSArray<NSString *> *)clickItems dismissFreedom:(BOOL)freedom;


- (void)presentSheetAlertViewWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles dismissFreedom:(BOOL)freedom;


//样式
- (void)setTitleStyle:(NSDictionary *)titleAttributes contentStyle:(NSDictionary *)contentAttributes clickItemsStyle:(NSArray <NSDictionary *> *)clickItemAttributes;

- (void)dismissAnyway;
@end

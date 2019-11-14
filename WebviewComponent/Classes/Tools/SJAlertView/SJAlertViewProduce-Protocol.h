//
//  SJAlertViewProduce-Protocol.h
//  HNTransport
//
//  Created by 刘江 on 2018/7/13.
//  Copyright © 2018年 com.liangla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AlertStyle) {
    AlertStyleNormal = 0,
    AlertStyleSheet,
    
};

@protocol SJAlertViewProduceDelegate <NSObject>
@required
@property (nonatomic, strong)id passMsg;///所有alertView均需实现以传递信息

@optional
//产生一个alert
- (UIView *)produceSJNormalAlertViewWithTitle:(NSString *)title content:(NSString *)content bottomClickItem:(NSArray *)bottomClickItem;
- (UIView *)produceSheetAlertViewWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles;



//alert样式
- (void)configTitleStyle:(NSDictionary *)titleAttributes contentStyle:(NSDictionary *)contentAttributes clickItemsStyle:(NSArray <NSDictionary *> *)clickItemAttributes;

@end

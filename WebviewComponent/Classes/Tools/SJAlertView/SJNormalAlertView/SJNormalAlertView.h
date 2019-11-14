//
//  SJNormalAlertView.h
//  HNTransport
//
//  Created by 刘江 on 2018/7/13.
//  Copyright © 2018年 com.liangla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJAlertViewProduce-Protocol.h"

@interface SJNormalAlertView : UIView<SJAlertViewProduceDelegate>
@property (nonatomic, strong)UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UILabel *separator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonW;


@end

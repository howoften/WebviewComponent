
//
//  BaseAlertView.m
//  AlertTest
//
//  Created by jonh on 2017/10/26.
//  Copyright © 2017年 jonh. All rights reserved.
//

#import "BaseAlertView.h"

#define SCREEN_W  [UIScreen mainScreen].bounds.size.width

#define SCREEN_H [UIScreen mainScreen].bounds.size.height
#define KEYWINDOW     [[UIApplication sharedApplication] keyWindow]
#define ANIMATION_TIME 0.5
@interface BaseAlertView ()
///遮罩层
@property (nonatomic, strong) UIView *maskView;
//响应事件的控件
@property (nonatomic, strong) UITapGestureRecognizer *dismissTap;
//保存弹出视图
@property (nonatomic, strong) UIView *contentView;
///弹出模式
@property (nonatomic, assign) BaseAlertViewStyle alertStyle;
///动画前的位置
@property (nonatomic, assign) CGAffineTransform starTransForm;

@end
@implementation BaseAlertView
+ (BaseAlertView *)share {
    static BaseAlertView *alertView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!alertView) {
            alertView = [[BaseAlertView alloc] init];
        }
    });
    return alertView;
}

- (void)show:(UIView *)contentView withType:(BaseAlertViewStyle)style{
    //判断是否赋于大小
    CGFloat contentViewHeight =  contentView.frame.size.height;
    CGFloat contentViewWidth  =  contentView.frame.size.width;
    if(contentViewHeight == 0.00||contentViewWidth == 0.00){
        NSLog(@"弹出视图 必须 赋予宽高");
        return;
    }
    _contentView = contentView;
    _contentView.center = CGPointMake(CGRectGetWidth(self.maskView.frame)/2.f, CGRectGetHeight(self.maskView.frame)/2.f);
    _alertStyle = style;
        // 根据弹出模式 添加动画
        switch (_alertStyle) {
            case BaseAlertViewStyleAlert:
                _starTransForm = CGAffineTransformMakeScale(0.01, 0.01);
                break;
            case BaseAlertViewStyleActiAlertLeft:
                _starTransForm = CGAffineTransformMakeTranslation(-SCREEN_W, 0);
                break;
            case BaseAlertViewStyleActiAlertRight:
                _starTransForm = CGAffineTransformMakeTranslation(SCREEN_W, 0);
                break;
            case BaseAlertViewStyleActionSheetTop:
              
                _starTransForm = CGAffineTransformMakeTranslation(0, -_contentView.frame.size.height);
                break;
            case BaseAlertViewStyleActionSheetDown:
             _contentView.center = CGPointMake(CGRectGetWidth(self.maskView.frame)/2.f, CGRectGetHeight(self.maskView.frame)-CGRectGetHeight(_contentView.frame)/2.f);
                _starTransForm = CGAffineTransformMakeTranslation(0, SCREEN_H);
                break;
            default:
                break;
        }
        [self alertAnimatedPrensent];
    
}
//  自定义的alert或actionSheet内容view必须初始化大小
- (void)show:(UIView *)contentView withType:(BaseAlertViewStyle)style animationFinish:(showBlock)show dismissHandle:(dismissBlock)dismiss {
    //保存 回调
    if (show) {
        _showBlock = [show copy];
    }
    if(dismiss){
        _dismissBlock = [dismiss copy];
    }
    [self show:contentView withType:style];
}

- (void)setCloseStyle:(CloseStyle)closeStyle {
    _closeStyle = closeStyle;
    if (closeStyle == CloseStyleNever) {
        [_maskView removeGestureRecognizer:_dismissTap];
    }else {
        if (!_dismissTap) {
            [_maskView addGestureRecognizer:self.dismissTap];
        }
    }
}

///添加遮罩
- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H)];
        [_maskView setFrame:[[UIScreen mainScreen] bounds]];
        [_maskView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.50]];
        [_maskView addGestureRecognizer:self.dismissTap];
        self.closeStyle = _closeStyle;
    }
    if (!_maskView.superview) {
        [KEYWINDOW addSubview:_maskView];
    }
    return _maskView;
    
}


- (UITapGestureRecognizer *)dismissTap {
    if (!_dismissTap) {
        _dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        _dismissTap.numberOfTapsRequired = 1;
        _dismissTap.numberOfTapsRequired = 1;
    }
    return _dismissTap;
}

- (void)dismiss:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self.maskView];
    if ((tap && (point.y < CGRectGetMinY(self.contentView.frame) || point.y > CGRectGetMaxY(self.contentView.frame) || point.x < CGRectGetMinX(self.contentView.frame) || point.x > CGRectGetMaxX(self.contentView.frame))) || !tap) {
        
    //移除弹出框
    [self alertAnimatedOut];
    
    // 移除遮罩
    for (UIView *subview in _maskView.subviews) {
        [subview removeFromSuperview];
    }
    [_maskView removeFromSuperview];
    }
}

- (void)alertAnimatedPrensent {
    _contentView.transform = _starTransForm;
    [self.maskView addSubview:_contentView];
    _maskView.userInteractionEnabled = NO;
    if (_alertStyle != BaseAlertViewStyleActionSheetDown && _alertStyle != BaseAlertViewStyleActionSheetTop) {
        [UIView animateWithDuration:ANIMATION_TIME delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            _contentView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            _maskView.userInteractionEnabled = YES;
            if (self.showBlock) {
                //动画完成后回调
                self.showBlock();
            }
        }];
    }else {
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _contentView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            _maskView.userInteractionEnabled = YES;
            if (self.showBlock) {
                //动画完成后回调
                self.showBlock();
            }
        }];
    }
    
}

- (void)addCoreAnimation{
    
    CATransition *animation = [CATransition animation];
    animation.type = @"rippleEffect";
    animation.duration = ANIMATION_TIME;
    [_contentView.layer addAnimation:animation forKey:@""];
    
}

- (void)alertAnimatedOut{
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        _contentView.transform = self.starTransForm;
        _maskView.userInteractionEnabled = NO;
    } completion:^(BOOL finished) {
        _maskView.userInteractionEnabled = YES;
        if (self.dismissBlock) {
            self.dismissBlock();
        }
    }];
    
}


@end

//
//  LLModalTransition.h
//  WebviewComponent
//
//  Created by 刘江 on 2019/1/23.
//  Copyright © 2019年 Liujiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
extern NSString *const ViewControllerModalStyleDefault;
extern NSString *const ViewControllerModalStyleMask;
extern NSString *const ViewControllerModalStyleFold;
extern NSString *const ViewControllerModalStyleLikeSystemNavigation;


@interface LLModalTransition : UIPresentationController<UIViewControllerTransitioningDelegate>

@property (nonatomic, assign)NSString * modalStyle;
/**
 @abstract 初始化present 转场控制器
 @param style 转场动画样式
 @param presentedViewController 下一跳ViewController
 @param presentingViewController 当前ViewController
 */
+ (LLModalTransition *)transitionFromModalStyle:(NSString *)style presentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController;

@end

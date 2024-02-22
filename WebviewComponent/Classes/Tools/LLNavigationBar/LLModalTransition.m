//
//  LLModalTransition.m
//  WebviewComponent
//
//  Created by 刘江 on 2019/1/23.
//  Copyright © 2019年 Liujiang. All rights reserved.
//

#import "LLModalTransition.h"

@interface LLModalTransition ()<UIViewControllerAnimatedTransitioning, UINavigationControllerDelegate>
@property (nonatomic, strong)UIView *snapshot;
@property (nonatomic) CATransform3D foldTransform;
//@property (nonatomic, strong)UIView *dimingView;

@end

//static BOOL isEnter = YES;
NSString *const ViewControllerModalStyleDefault = @"ViewControllerModalStyleDefault";
NSString *const ViewControllerModalStyleMask = @"ViewControllerModalStyleMask";
NSString *const ViewControllerModalStyleFold = @"ViewControllerModalStyleFold";
NSString *const ViewControllerModalStyleLikeSystemNavigation = @"ViewControllerModalStyleLikeSystemNavigation";

@implementation LLModalTransition

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController
{
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    
    if (self) {
        presentedViewController.modalPresentationStyle = UIModalPresentationCustom;
    }
    
    return self;
}

///负责过渡效果
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    if ([self.modalStyle isEqualToString:ViewControllerModalStyleMask] || [self.modalStyle isEqualToString:ViewControllerModalStyleFold] || [self.modalStyle isEqualToString:ViewControllerModalStyleLikeSystemNavigation]) return self;
    return nil;
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if ([self.modalStyle isEqualToString:ViewControllerModalStyleMask] || [self.modalStyle isEqualToString:ViewControllerModalStyleFold] || [self.modalStyle isEqualToString:ViewControllerModalStyleLikeSystemNavigation]) return self;
    return nil;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    if ([transitionContext isAnimated]) {
        if([self.modalStyle isEqualToString:ViewControllerModalStyleMask]) return 0;
        if([self.modalStyle isEqualToString:ViewControllerModalStyleFold]) return 0.3;
        if([self.modalStyle isEqualToString:ViewControllerModalStyleLikeSystemNavigation]) return 0.35;
    }
    
    return 0;
}


- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    UIView *fromView = fromViewController.view;
    UIView *toView = toViewController.view;
    if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {
        if (!fromView) {
            fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        }
        if (!toView) {
            toView = [transitionContext viewForKey:UITransitionContextToViewKey];
        }
    }
    BOOL isPresenting = (fromViewController == self.presentingViewController);
   
    if ([self.modalStyle isEqualToString:ViewControllerModalStyleMask]) {
        if (isPresenting) {
            [self forceCallViewControllerLifeSelector:fromViewController active:NO willDo:YES animated:[transitionContext isAnimated]];
            UIView *snap = [self snapshot];
            [containerView addSubview:snap];
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            [self forceCallViewControllerLifeSelector:fromViewController active:NO willDo:NO animated:[transitionContext isAnimated]];

        }else {
            [self forceCallViewControllerLifeSelector:toViewController active:YES willDo:YES animated:[transitionContext isAnimated]];
            if ([fromView isDescendantOfView:containerView]) {
                [fromView removeFromSuperview];
            }
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            [self forceCallViewControllerLifeSelector:toViewController active:YES willDo:NO animated:[transitionContext isAnimated]];

        }
    }else if ([self.modalStyle isEqualToString:ViewControllerModalStyleFold]) {
        if (isPresenting) {
            [self forceCallViewControllerLifeSelector:fromViewController active:NO willDo:YES animated:[transitionContext isAnimated]];
            toView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(containerView.frame)-CGRectGetMinY(fromView.frame));
            [containerView addSubview:toView];
            
            fromView.layer.zPosition = -1000.f;
            [UIView animateWithDuration:[self transitionDuration:transitionContext]/2 animations:^{
                fromView.layer.transform = self.foldTransform;
            } completion:nil];

            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                toView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                [self forceCallViewControllerLifeSelector:fromViewController active:NO willDo:NO animated:[transitionContext isAnimated]];

            }];
        }else {
            [self forceCallViewControllerLifeSelector:toViewController active:YES willDo:YES animated:[transitionContext isAnimated]];
            

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([self transitionDuration:transitionContext]/2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:[self transitionDuration:transitionContext]/2 animations:^{
                    toView.layer.transform = CATransform3DIdentity;
                } completion:^(BOOL finished) {

                }];
            });
            
            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                fromView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(containerView.frame)-CGRectGetMinY(fromView.frame));;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                [self forceCallViewControllerLifeSelector:toViewController active:YES willDo:NO animated:[transitionContext isAnimated]];

            }];
           
        }
    }else if ([self.modalStyle isEqualToString:ViewControllerModalStyleLikeSystemNavigation]) {
        if (isPresenting) {
            [self forceCallViewControllerLifeSelector:fromViewController active:NO willDo:YES animated:[transitionContext isAnimated]];
            containerView.frame = CGRectMake(0, 0, CGRectGetWidth(containerView.frame), CGRectGetHeight(containerView.frame) + (CGRectGetMinY(containerView.frame)-0));
            [containerView addSubview:toView];
            toView.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(containerView.frame) - CGRectGetMinX(toView.frame), 0);
            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.05 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                toView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                [self forceCallViewControllerLifeSelector:fromViewController active:NO willDo:NO animated:[transitionContext isAnimated]];
                fromView.transform = CGAffineTransformIdentity;
            }];
            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                fromView.transform = CGAffineTransformMakeTranslation(-CGRectGetWidth(fromView.frame)*0.45, 0);
            } completion:^(BOOL finished) {
                
            }];
        }else {
            [self forceCallViewControllerLifeSelector:toViewController active:YES willDo:YES animated:[transitionContext isAnimated]];

            [UIView animateWithDuration:[self transitionDuration:transitionContext]*0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                fromView.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(containerView.frame) - CGRectGetMinX(fromView.frame), 0);
            } completion:^(BOOL finished) {
               
            }];
            
            toView.transform = CGAffineTransformMakeTranslation(-CGRectGetWidth(toView.frame)*0.45, 0);
            [UIView animateWithDuration:[self transitionDuration:transitionContext]*0.8 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.05 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                toView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                [fromView removeFromSuperview];
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                [self forceCallViewControllerLifeSelector:toViewController active:YES willDo:NO animated:[transitionContext isAnimated]];

            }];
        }
    }
}

/*
 * 来告诉控制器，谁是动画主管
 */
- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    if ([self.modalStyle isEqualToString:ViewControllerModalStyleMask] || [self.modalStyle isEqualToString:ViewControllerModalStyleFold] || [self.modalStyle isEqualToString:ViewControllerModalStyleLikeSystemNavigation]) return self;
    return nil;
}

- (void)forceCallViewControllerLifeSelector:(UIViewController *)viewController active:(BOOL)isActive willDo:(BOOL)willDo animated:(BOOL)animated {
    if (isActive) {
        if (willDo) {
            if([viewController respondsToSelector:@selector(viewWillAppear:)]) {
                [viewController viewWillAppear:animated];
            }
        }else {
            if ([viewController respondsToSelector:@selector(viewDidAppear:)]) {
                [viewController viewDidAppear:animated];
            }
        }
    }else {
        if (willDo) {
            if([viewController respondsToSelector:@selector(viewWillDisappear:)]) {
                [viewController viewWillDisappear:animated];
            }
        }else {
            if ([viewController respondsToSelector:@selector(viewDidDisappear:)]) {
                [viewController viewDidDisappear:animated];
            }
        }
    }
}

- (UIView *)snapshot {
    return [[UIApplication sharedApplication].keyWindow snapshotViewAfterScreenUpdates:NO];
}

- (CATransform3D)foldTransform {
    _foldTransform = CATransform3DIdentity;
    _foldTransform.m34 = 1.0/-600;
    _foldTransform = CATransform3DScale(_foldTransform, 0.95, 0.95, 1);
    
    return _foldTransform;
}


+ (BOOL)validModalStyle:(NSString *)style {
    if (![style isKindOfClass:[NSString class]]) {
        return NO;
    }
    return [style isEqualToString:ViewControllerModalStyleMask] || [style isEqualToString:ViewControllerModalStyleFold] || [style isEqualToString:ViewControllerModalStyleLikeSystemNavigation];
}

+ (LLModalTransition *)transitionFromModalStyle:(NSString *)style presentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    if ([self validModalStyle:style]) {
        LLModalTransition *transition = [[LLModalTransition alloc] initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
        presentedViewController.transitioningDelegate = transition;
        transition.modalStyle = style;
        return transition;
    }
    return nil;
}


@end

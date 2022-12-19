//
//  LLNavigationController.m
//  WebviewComponent
//
//  Created by 刘江 on 2018/7/18.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import "LLWebNavigationController.h"

@interface LLWebNavigationController ()<UIGestureRecognizerDelegate>

@end

@implementation LLWebNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //    self.navigationBar.barStyle = UIBarStyleBlack;

//    self.interactivePopGestureRecognizer.enabled = NO;
    __weak typeof(self) weakself = self;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = (id)weakself;
    }
    self.navigationBar.hidden = YES;
    self.navigationBar.alpha = 0;
    [self.navigationBar setBackgroundImage:[self imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
}
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.navigationBar.hidden = YES;
    self.navigationBar.alpha = 0;
    [self.navigationBar setBackgroundImage:[self imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
}
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        // 屏蔽调用rootViewController的滑动返回手势
        if (self.viewControllers.count < 2 || self.visibleViewController == [self.viewControllers objectAtIndex:0]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}
//
-(UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}
- (UIImage *)imageWithColor:(UIColor *)color {
    
    CGRect rect =CGRectMake(0.0f,0.0f,1.0f,1.0f);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage *image =UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}

- (void)dealloc {
    
}

@end

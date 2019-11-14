//
//  UIViewController+Refresh.m
//  EntranceControl
//
//  Created by jiang liu on 2017/2/9.
//  Copyright © 2017年 jiang liu. All rights reserved.
//

#import <objc/runtime.h>
#import "UIViewController+Refresh.h"

@interface UIViewController ()

@property (nonatomic, strong)MBProgressHUD *refreshHUD;
@property (nonatomic, strong)MBProgressHUD *toastHUD;
@property (nonatomic, strong)MBProgressHUD *progressHUD;

@end

@implementation UIViewController (Refresh)

- (MBProgressHUD *)refreshHUD {
    return objc_getAssociatedObject(self, @selector(refreshHUD));
}

- (void)setRefreshHUD:(MBProgressHUD *)refreshHUD {
     objc_setAssociatedObject(self, @selector(refreshHUD), refreshHUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MBProgressHUD *)toastHUD {
    return objc_getAssociatedObject(self, @selector(toastHUD));
}

- (void)setToastHUD:(MBProgressHUD *)toastHUD {
    objc_setAssociatedObject(self, @selector(toastHUD), toastHUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (MBProgressHUD *)progressHUD {
    return objc_getAssociatedObject(self, @selector(progressHUD));
}

- (void)setProgressHUD:(MBProgressHUD *)progressHUD {
    objc_setAssociatedObject(self, @selector(progressHUD), progressHUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)refreshViewWithTitle:(NSString *)title content:(NSString *)content {
    if ((![title isKindOfClass:[NSString class]] && title != nil) || (![content isKindOfClass:[NSString class]] && content != nil)) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.view) {
            if (!self.refreshHUD) {
                self.refreshHUD = [[MBProgressHUD alloc] initWithView:self.view];
                self.refreshHUD.contentColor = [UIColor colorWithWhite:1 alpha:0.8];
                self.refreshHUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
                self.refreshHUD.bezelView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
                self.refreshHUD.offset = CGPointMake(0, -30*CGRectGetHeight([UIScreen mainScreen].bounds)/667);
                self.refreshHUD.margin = 16.f;
                self.refreshHUD.mode = MBProgressHUDModeIndeterminate;
                self.refreshHUD.removeFromSuperViewOnHide = YES;
                self.refreshHUD.square = YES;// 方的
                [self.view addSubview:self.refreshHUD];
            }
            if (title && title.length > 0) {
                self.refreshHUD.label.text = title;
                self.refreshHUD.label.font = [UIFont systemFontOfSize:17*CGRectGetWidth([UIScreen mainScreen].bounds)/375];
            }
            if (content && content.length > 0) {
                self.refreshHUD.detailsLabel.text = content;
            }
            [self.refreshHUD showAnimated:YES];
        }else {
            NSLog(@"找不到依附的View");
        }
    });
    
}

- (void)refreshFullScreenViewWithTitle:(NSString *)title content:(NSString *)content {
    if ((![title isKindOfClass:[NSString class]] && title != nil) || (![content isKindOfClass:[NSString class]] && content != nil)) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *fullView = [UIApplication sharedApplication].delegate.window;
        if (fullView) {
            if (!self.refreshHUD) {
                self.refreshHUD = [[MBProgressHUD alloc] initWithView:fullView];
                self.refreshHUD.contentColor = [UIColor colorWithWhite:1 alpha:0.8];
                self.refreshHUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
                self.refreshHUD.bezelView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
                self.refreshHUD.offset = CGPointMake(0, -30*CGRectGetHeight([UIScreen mainScreen].bounds)/667);
                self.refreshHUD.margin = 16.f;
                self.refreshHUD.mode = MBProgressHUDModeIndeterminate;
                self.refreshHUD.removeFromSuperViewOnHide = YES;
                self.refreshHUD.square = YES;// 方的
                [fullView addSubview:self.refreshHUD];
            }
            if (title && title.length > 0) {
                self.refreshHUD.label.text = title;
                self.refreshHUD.label.font = [UIFont systemFontOfSize:17*CGRectGetWidth([UIScreen mainScreen].bounds)/375];
            }
            if (content && content.length > 0) {
                self.refreshHUD.detailsLabel.text = content;
            }
           
            [self.refreshHUD showAnimated:YES];
        }else {
            NSLog(@"找不到依附的View");
        }
    });
    
}

- (void)hideRefreshView {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.refreshHUD) {
            [self.refreshHUD hideAnimated:NO];
            self.refreshHUD = nil;
        }
        if (self.toastHUD) {
            [self.toastHUD hideAnimated:YES];
            self.toastHUD = nil;
        }
        if (self.progressHUD) {
            [self.progressHUD hideAnimated:NO];
            self.progressHUD = nil;
        }
    });
}

- (void)toastWithText:(NSString *)text {
    [self hideRefreshView];
    if ((![text isKindOfClass:[NSString class]] && text != nil)) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.view) {
            if (!self.toastHUD) {
                self.toastHUD = [[MBProgressHUD alloc] initWithView:self.view];
                self.toastHUD.animationType = MBProgressHUDAnimationZoom;
                self.toastHUD.removeFromSuperViewOnHide = YES;
                self.toastHUD.mode = MBProgressHUDModeText;
                
                self.toastHUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
                self.toastHUD.contentColor = [UIColor whiteColor];
                self.toastHUD.bezelView.color = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
                self.toastHUD.bezelView.layer.cornerRadius = 4;
                self.toastHUD.minSize = CGSizeMake(217*CGRectGetWidth([UIScreen mainScreen].bounds)/375, 50*CGRectGetHeight([UIScreen mainScreen].bounds)/667);
                self.toastHUD.detailsLabel.text = @"温馨提示";
                [self.view addSubview:self.toastHUD];
            }
            if (text && text.length > 0) {
                self.toastHUD.detailsLabel.text = text;
            }
            self.toastHUD.detailsLabel.font = [UIFont systemFontOfSize:17*CGRectGetWidth([UIScreen mainScreen].bounds)/375];
            [self.toastHUD showAnimated:YES];
            [self.toastHUD hideAnimated:YES afterDelay:2.f];
        }else {
            NSLog(@"找不到依附的View!");
        }
    });
}

- (void)toastFullScreenWithText:(NSString *)text {
    if ((![text isKindOfClass:[NSString class]] && text != nil)) {
        return;
    }
    [self hideRefreshView];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *fullView = [UIApplication sharedApplication].delegate.window;
        if (fullView) {
            if (!self.toastHUD) {
                self.toastHUD = [[MBProgressHUD alloc] initWithView:fullView];
                self.toastHUD.animationType = MBProgressHUDAnimationZoom;
                self.toastHUD.removeFromSuperViewOnHide = YES;
                self.toastHUD.mode = MBProgressHUDModeText;
                
                self.toastHUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
                self.toastHUD.contentColor = [UIColor whiteColor];
                self.toastHUD.bezelView.color = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
                self.toastHUD.bezelView.layer.cornerRadius = 4;
                self.toastHUD.minSize = CGSizeMake(217*CGRectGetWidth([UIScreen mainScreen].bounds)/375, 50*CGRectGetHeight([UIScreen mainScreen].bounds)/667);
                //        toast.margin = 15.f; //5pt
                //        toast.offset = CGPointMake(0, 200);
                self.toastHUD.detailsLabel.text = @"温馨提示";
                [fullView addSubview:self.toastHUD];
            }
            if (text && text.length > 0) {
                self.toastHUD.detailsLabel.text = text;
            }
            //            NSMutableParagraphStyle *
            self.toastHUD.detailsLabel.font = [UIFont systemFontOfSize:17*CGRectGetWidth([UIScreen mainScreen].bounds)/375];
            [self.toastHUD showAnimated:YES];
            [self.toastHUD hideAnimated:YES afterDelay:2.f];
        }else {
            NSLog(@"找不到依附的View!");
        }
    });
}

- (void)toastWithText:(NSString *)text duration:(NSTimeInterval)duration {
    if ((![text isKindOfClass:[NSString class]] && text != nil)) {
        return;
    }
    [self hideRefreshView];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.view) {
            if (!self.toastHUD) {
                self.toastHUD = [[MBProgressHUD alloc] initWithView:self.view];
                self.toastHUD.animationType = MBProgressHUDAnimationZoom;
                self.toastHUD.removeFromSuperViewOnHide = YES;
                self.toastHUD.mode = MBProgressHUDModeText;
                
                self.toastHUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
                self.toastHUD.contentColor = [UIColor whiteColor];
                self.toastHUD.bezelView.color = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
                self.toastHUD.bezelView.layer.cornerRadius = 4;
                self.toastHUD.minSize = CGSizeMake(217*CGRectGetWidth([UIScreen mainScreen].bounds)/375, 50*CGRectGetHeight([UIScreen mainScreen].bounds)/667);
                self.toastHUD.detailsLabel.text = @"温馨提示";
                [self.view addSubview:self.toastHUD];
            }
            if (text && text.length > 0) {
                self.toastHUD.detailsLabel.text = text;
            }
            self.toastHUD.detailsLabel.font = [UIFont systemFontOfSize:17*CGRectGetWidth([UIScreen mainScreen].bounds)/375];
            [self.toastHUD showAnimated:YES];
            [self.toastHUD hideAnimated:YES afterDelay:duration];
        }else {
            NSLog(@"找不到依附的View!");
        }
    });
}

- (void)showProgressWithTitle:(NSString *)title progress:(CGFloat)progress {
    if ((![title isKindOfClass:[NSString class]] && title != nil)) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.view) {
            for (UIView *subview in self.view.subviews) {
                if ([subview isKindOfClass:[MBProgressHUD class]] && ((MBProgressHUD *)subview).mode == MBProgressHUDModeDeterminateHorizontalBar) {
                    self.progressHUD = (MBProgressHUD *)subview;
                    break;
                }
            }

            if (self.progressHUD) {
                self.progressHUD.progress = progress;
                if (progress >= 1) {
                    [self.progressHUD hideAnimated:YES afterDelay:1.5f];
                }
                
            }else {
                    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    self.progressHUD.removeFromSuperViewOnHide = YES;
                    self.progressHUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
                    
                    self.progressHUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
                    self.progressHUD.contentColor = [UIColor whiteColor];
                    self.progressHUD.bezelView.color = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
                    self.progressHUD.bezelView.layer.cornerRadius = 4;
                    self.progressHUD.minSize = CGSizeMake(217*CGRectGetWidth([UIScreen mainScreen].bounds)/375, 50*CGRectGetHeight([UIScreen mainScreen].bounds)/667);
                    //        progress.margin = 15.f; //5pt
                    //        progress.offset = CGPointMake(0, 200);
                    self.progressHUD.detailsLabel.text = @"uploading";
                    self.progressHUD.detailsLabel.font = [UIFont systemFontOfSize:14*CGRectGetWidth([UIScreen mainScreen].bounds)/375];
                if (self.progressHUD) {
                    self.progressHUD.progress = progress;
                    if (title && title.length > 0) {
                        self.progressHUD.detailsLabel.text = title;
                    }
                    if (progress >= 1) {
                        [self.progressHUD hideAnimated:YES afterDelay:1.5f];
                    }
                }
            }
        }else {
            NSLog(@"找不到依附的View!");
        }
    });
}

- (void)showFullScreenProgressWithTitle:(NSString *)title progress:(CGFloat)progress {
    if ((![title isKindOfClass:[NSString class]] && title != nil)) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *fullView = [UIApplication sharedApplication].delegate.window;
        if (fullView) {
            for (UIView *subview in self.view.subviews) {
                if ([subview isKindOfClass:[MBProgressHUD class]] && ((MBProgressHUD *)subview).mode == MBProgressHUDModeDeterminateHorizontalBar) {
                    self.progressHUD = (MBProgressHUD *)subview;
                    break;
                }
            }
            
            if (!self.progressHUD) {
                self.progressHUD = [MBProgressHUD showHUDAddedTo:fullView animated:YES];
                self.progressHUD.removeFromSuperViewOnHide = YES;
                self.progressHUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
                
                self.progressHUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
                self.progressHUD.contentColor = [UIColor whiteColor];
                self.progressHUD.bezelView.color = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
                self.progressHUD.bezelView.layer.cornerRadius = 4;
                self.progressHUD.minSize = CGSizeMake(217*CGRectGetWidth([UIScreen mainScreen].bounds)/375, 50*CGRectGetHeight([UIScreen mainScreen].bounds)/667);
                //        progress.margin = 15.f; //5pt
                //        progress.offset = CGPointMake(0, 200);
                self.progressHUD.detailsLabel.text = @"uploading";
                self.progressHUD.detailsLabel.font = [UIFont systemFontOfSize:14*CGRectGetWidth([UIScreen mainScreen].bounds)/375];
            }
            if (self.progressHUD) {
                self.progressHUD.progress = progress;
                if (title && title.length > 0) {
                    self.progressHUD.detailsLabel.text = title;
                }
                if (progress >= 1) {
                    [self.progressHUD hideAnimated:YES afterDelay:1.5f];
                }
            }
            
        }else {
            NSLog(@"找不到依附的View!");
        }
    });
}

- (UIViewController *)getCurrentVC {
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

@end

//
//  UIViewController+Refresh.h
//  EntranceControl
//
//  Created by jiang liu on 2017/2/9.
//  Copyright © 2017年 jiang liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface UIViewController (Refresh)


- (void)refreshViewWithTitle:(NSString *)title content:(NSString *)content;

- (void)refreshFullScreenViewWithTitle:(NSString *)title content:(NSString *)content;

- (void)hideRefreshView;

- (void)toastWithText:(NSString *)text;

- (void)toastWithText:(NSString *)text duration:(NSTimeInterval)duration;

- (void)toastFullScreenWithText:(NSString *)text;

- (void)showProgressWithTitle:(NSString *)title progress:(CGFloat)progress;

- (void)showFullScreenProgressWithTitle:(NSString *)title progress:(CGFloat)progress;
@end

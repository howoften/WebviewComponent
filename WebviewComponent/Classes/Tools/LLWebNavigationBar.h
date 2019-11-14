//
//  LLNavigationBar.h
//  WebviewComponent
//
//  Created by 刘江 on 2018/8/4.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLWebNavigationBar : UIImageView
@property (nonatomic, assign)BOOL showNavigationBarShadow;
+ (void)contributeForViewController:(Class _Nonnull __unsafe_unretained)viewController navigationController:(Class _Nonnull __unsafe_unretained)navigationController;
@end

@interface UIViewController(NavigationBar)

@property (nonatomic, strong, readonly)LLWebNavigationBar * _Nullable navigationBar;

@end


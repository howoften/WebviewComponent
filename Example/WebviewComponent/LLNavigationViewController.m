//
//  LLNavigationViewController.m
//  WebviewComponent_Example
//
//  Created by 刘江 on 2019/8/6.
//  Copyright © 2019 howoften. All rights reserved.
//

#import "LLNavigationViewController.h"

@interface LLNavigationViewController ()

@end

@implementation LLNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

-(UIViewController *)childViewControllerForStatusBarStyle {
    if (self.presentedViewController) {
        return self.presentedViewController;
    }
   return [self topViewController];
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return [self topViewController];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

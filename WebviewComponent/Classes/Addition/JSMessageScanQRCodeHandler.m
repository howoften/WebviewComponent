//
//  JSMessageScanQRCodeHandler.m
//  WebviewComponent_Example
//
//  Created by 刘江 on 2019/8/6.
//  Copyright © 2019 howoften. All rights reserved.
//

#import "JSMessageScanQRCodeHandler.h"
#import "LLWebJSBridgeManage.h"
#import "QRCScanner.h"
#import "LLWebViewHelper.h"
@interface JSMessageScanQRCodeHandler ()<LLWebJSBridgeMessageDelegate, QRCodeScanneDelegate>
@property (nonatomic)UIStatusBarStyle originalStatusBarStyle;
@property (nonatomic, strong)NSString *scanResult;
@property (nonatomic, strong)void(^callBack)(id);
@end


@implementation JSMessageScanQRCodeHandler

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageWithContentsOfFile:[LLWebViewHelper pngImagefilePathForName:@"web_nav_back_light"]] forState:UIControlStateNormal];
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [backButton sizeToFit];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.originalStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    UILabel *title = [[UILabel alloc] init];
    title.text = @"二维码/条码";
    title.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
    title.textColor = [UIColor whiteColor];
    
    [title sizeToFit];
    self.navigationItem.titleView = title;
    
    QRCScanner *scanner = [[QRCScanner alloc]initQRCScannerWithView:self.view];
    scanner.frame = [UIScreen mainScreen].bounds;
    scanner.scanningLieColor = [UIColor greenColor];
    scanner.cornerLineColor = [UIColor greenColor];
    scanner.delegate = self;
    [self.view addSubview:scanner];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (![self.scanResult isKindOfClass:[NSString class]]) {
        if (self.callBack) {
            self.callBack(@{@"code":@-1, @"msg":@"fail"});
        }
    }else if (self.callBack) {
        self.callBack(@{@"code":@0, @"responseData":@{@"code":self.scanResult, @"status": @"0"}, @"msg":@"success"});
        self.callBack = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:LLWebScanQRCodeResultNotificationName object:nil userInfo:@{@"data":self.scanResult}];
    }
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

+ (BOOL)handleJSBridgeCallBackByMyself {
    return YES;
}

+ (void)webviewJSBridgeMessageForHandler:(NSString *)handler message:(NSDictionary *)message callback:(void(^)(id))callback {
    if ([handler isEqualToString:@"scanCode"]) {
        JSMessageScanQRCodeHandler *scan = [self new];
        scan.callBack = callback;
        [(UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController.presentedViewController pushViewController:scan animated:YES];
    }
}

- (void)didFinshedScanningQRCode:(NSString *)result {
    self.scanResult = result;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
    
}

@end

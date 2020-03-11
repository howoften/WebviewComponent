//
//  LLViewController.m
//  WebviewComponent
//
//  Created by howoften on 07/29/2019.
//  Copyright (c) 2019 howoften. All rights reserved.
//


#import "LLViewController.h"
#import <LLWebviewLoader.h>
#import <LLWebJSBridgeManage.h>
#import <LLOAuthManager.h>
#import <LLWebViewSimplifyLoader.h>

@interface LLViewController ()<LLWebViewOAuthDelegate, LLWebviewLoaderDelegate>
@property (weak, nonatomic) IBOutlet UITextField *sessionID;
@property (weak, nonatomic) IBOutlet UITextField *url;

@end

@implementation LLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   
    //@"https://lzgj.test.brightcns.cn/gateway"
    //https://lzgj.brightcns.com/gateway
    [LLOAuthManager setWebViewOAuthRequestURL:@"https://lzgj.test.brightcns.cn/gateway" delegate:self];
//    [self setNeedsStatusBarAppearanceUpdate];
    [LLWebviewLoader observeLocalizedWebViewNavigationActionForURL:@"liangla://main/certificate" didMeet:^(NSString *meetURL) {
        NSLog(@"%@", meetURL);
    }];

}

- (IBAction)present:(id)sender {
    [LLWebviewLoader setProgressBarTintColor:[UIColor redColor]];
    [LLWebviewLoader setProgressBarTrackTintColor:[UIColor blackColor]];
    if ([self.url.text length] > 0) {
        [LLWebviewLoader loadWebViewByURL:[NSURL URLWithString:self.url.text] fromSourceViewController:self.navigationController title:nil shouleShare:YES];
    }else {
//    [LLWebviewLoader loadWebViewByURL:[NSURL URLWithString:@"https://find.test.brightcns.cn/#/OauthPage"] fromSourceViewController:self.navigationController title:nil shouleShare:YES];
    
    [LLWebviewLoader loadWebViewByURL:[NSURL URLWithString:@"http://www.windysummer.cn:3001/dist/index.html#/"] fromSourceViewController:self.navigationController title:nil shouleShare:YES];
//    [LLWebViewSimplifyLoader loadWebViewByURL:[NSURL URLWithString:@"https://www.baidu.com"] webViewTitle:@"weqweqwqwwqrqwerqwewerqweqrqwwerqwqerwqerqwerqwerqwqewrq" fromSourceViewController:self.navigationController];
//        [LLWebviewLoader loadWebViewByLocalFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"] fromSourceViewController:self.navigationController title:@"Example" shouleShare:YES];
//    [LLWebViewSimplifyLoader loadWebViewByFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"] webViewTitle:@"hello" fromSourceViewController:self.navigationController];
//    [LLWebviewLoader loadWebViewByURL:[NSURL URLWithString:@"http://windysummer.cn:3001/dist2/index.html#/"] fromSourceViewController:self.navigationController title:nil shouleShare:YES];
    }
    [LLWebviewLoader setWebviewSocialShareDelegate:self];
}

- (void)webviewSocialShareForWebViewTitle:(NSString *)webViewTilte contentText:(NSString *)contentText imageURL:(NSString *)imageURL linkURL:(NSString *)linkURL {
    NSLog(@"webViewTilte:%@, contentText:%@, imageURL:%@, linkURL:%@", webViewTilte, contentText, imageURL, linkURL);
}

- (void)webviewJSHandlerSocialShareForWebViewTitle:(NSString *)webViewTilte contentText:(NSString *)contentText imageURL:(NSString *)imageURL linkURL:(NSString *)linkURL {
    NSLog(@"jsHandler:webViewTilte:%@, contentText:%@, imageURL:%@, linkURL:%@", webViewTilte, contentText, imageURL, linkURL);
}

- (IBAction)show:(id)sender {
    [LLWebViewSimplifyLoader setProgressBarTintColor:[UIColor redColor]];
       [LLWebViewSimplifyLoader setProgressBarTrackTintColor:[UIColor blackColor]];
     if ([self.url.text hasPrefix:@"http"]) {
        [LLWebViewSimplifyLoader loadWebViewByURL:[NSURL URLWithString:self.url.text] webViewTitle:nil fromSourceViewController:self.navigationController];
     }else {
         [LLWebViewSimplifyLoader loadWebViewByURL:[NSURL URLWithString:@"https://www.baidu.com"] webViewTitle:nil fromSourceViewController:self.navigationController];
     }
    
}

- (void)webViewAuthTokenForRequestParameter:(NSDictionary *)parameter didFinished:(void (^)(NSString *dic))finished {
   
    if (finished) {
        finished(self.sessionID.text);
    }
}

- (void)webViewOAuthDidFailWithInfo:(NSDictionary *)info {
    NSLog(@"%@", info);
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//     NSLog(@"%@%s",self, _cmd);
//}
//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    NSLog(@"%@%s",self, _cmd);
//}
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    NSLog(@"%@%s",self, _cmd);
//
//}
//
//- (void)viewDidDisappear:(BOOL)animated {
//    [super viewDidDisappear:animated];
//    NSLog(@"%@%s",self, _cmd);
//
//}

//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleDarkContent;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
}
@end

//
//  JSMessageMediaHandler.m
//  WebviewComponent_Example
//
//  Created by 刘江 on 2019/8/5.
//  Copyright © 2019 howoften. All rights reserved.
//

#import <Photos/PHPhotoLibrary.h>
#import <AVFoundation/AVCaptureDevice.h>
#import "JSMessageMediaHandler.h"
#import "SJAlertViewPresenter.h"
#import "LLImagePicker.h"
#import "UIImage+Compress.h"
#import "UIViewController+Refresh.h"
#import "Base64Tool.h"
#import "JCVideoRecordView.h"

@implementation JSMessageMediaHandler
static JCVideoRecordView *recordView = nil;

+ (BOOL)handleJSBridgeCallBackByMyself {
    return YES;
}

+ (void)webviewJSBridgeMessageForHandler:(NSString *)handler message:(NSDictionary *)message callback:(void(^)(id))callback {
    if ([handler isEqualToString:@"chooseImage"]) {
        [[SJAlertViewPresenter shareInstance] presentSheetAlertViewWithTitle:@"请选择照片来源" cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"手机相册", @"照相机"] dismissFreedom:NO];
        [[SJAlertViewPresenter shareInstance] setExecResult:^(id result) {
             [self hans];
            if ([result isEqualToNumber:@1]) {
                [self handlePhotoAlbumChooseWithMessage:message callback:callback];
                
            }else if ([result isEqualToNumber:@2]) {
                [self handlePhotoCameraChooseWithMessage:message callback:callback];
            }
        }];
    }else if ([handler isEqualToString:@"chooseVideo"]) {
        [self handleVideoRecordWithMessage:message callback:callback];
    }

}

+ (void)handlePhotoAlbumChooseWithMessage:(NSDictionary *)message callback:(void(^)(id))callback {
    if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0 || [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined || [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
       
        [[LLImagePicker sharedInstance] showImagePickerWithType:LLImagePickerTypePhoto videoOnly:NO InViewController:[UIApplication sharedApplication].delegate.window.rootViewController.presentedViewController willFinished:nil didFinished:^(LLImagePicker *picker, UIImage *image,  NSURL *filePath) {
            if (!image) {
                [[UIApplication sharedApplication].delegate.window.rootViewController.presentedViewController toastWithText:@"选择图片时, 出现异常."];
                if (callback) {
                    callback(@{@"code":@(-1), @"msg":@"Application suffer a problem"});
                }
            }else{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [UIImage compressImage:image toByte:[[self specificImageQuality:message[@"reductionRatio"]] unsignedIntegerValue] callback:^(NSData *imgData, CGFloat progress, bool *stop) {
                        if (!*stop) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[UIApplication sharedApplication].delegate.window.rootViewController.presentedViewController showFullScreenProgressWithTitle:nil progress:progress];
                            });
                        }else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[UIApplication sharedApplication].delegate.window.rootViewController.presentedViewController hideRefreshView];
                            });
                            if ([message[@"uploadTarget"] isEqualToString:@"base64"]) {
                                if (callback) {
                                    callback(@{@"code":@(0),@"responseData":@{@"result":[imgData base64String]}, @"msg":@"success"});
                                }
                            }else {
                                if (callback) {
                                    callback(@{@"code":@(-1), @"msg":@"unsupport uploadTarget!"});
                                }
                            }
                        }
                    }];
                });
            }

        } didCancel:^(LLImagePicker *picker) {
            if (callback) {
                callback(@{@"code":@(-1), @"msg":@"user cancel picking photos."});
            }
        }];
        
    }else {
        if (callback) {
            callback(@{@"code":@(-1), @"msg":@"This application is not authorized to access."});
        }
        [[SJAlertViewPresenter shareInstance] presentNormalAlertViewWithTitle:@"温馨提示" contentList:@[@"请在设置中，允许APP访问你的相册。"] bottomClickItem:@[@"取消", @"确定"] dismissFreedom:NO];
        [[SJAlertViewPresenter shareInstance] setExecResult:^(id result) {
            if ([result isEqualToString:@"确定"]) {
                [self openSetting];
            }
        }];
    }
}

+ (void)handlePhotoCameraChooseWithMessage:(NSDictionary *)message callback:(void(^)(id))callback {
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusRestricted || [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusDenied) {
        if (callback) {
            callback(@{@"code":@(-1), @"msg":@"This application is not authorized to access."});
        }
        [[SJAlertViewPresenter shareInstance] presentNormalAlertViewWithTitle:@"温馨提示" contentList:@[@"请在设置中，允许APP访问你的相机。"] bottomClickItem:@[@"取消", @"确定"] dismissFreedom:NO];
        [[SJAlertViewPresenter shareInstance] setExecResult:^(id result) {
            if ([result isEqualToString:@"确定"]) {
                [self openSetting];
            }
        }];
    }else {
        [[LLImagePicker sharedInstance] showImagePickerWithType:LLImagePickerTypeCamera videoOnly:NO InViewController:[UIApplication sharedApplication].delegate.window.rootViewController.presentedViewController willFinished:nil didFinished:^(LLImagePicker *picker, UIImage *image, NSURL *filePath) {
            if (!image) {
                [[UIApplication sharedApplication].delegate.window.rootViewController.presentedViewController toastWithText:@"选取图片时, 出现异常."];
                if (callback) {
                    callback(@{@"code":@(-1), @"msg":@"Application suffer a problem"});
                }
            }else{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [UIImage compressImage:image toByte:[[self specificImageQuality:message[@"reductionRatio"]] unsignedIntegerValue] callback:^(NSData *imgData, CGFloat progress, bool *stop) {
                        if (!*stop) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[UIApplication sharedApplication].delegate.window.rootViewController.presentedViewController showFullScreenProgressWithTitle:nil progress:progress];
                            });
                        }else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[UIApplication sharedApplication].delegate.window.rootViewController.presentedViewController hideRefreshView];
                            });
                            if ([message[@"uploadTarget"] isEqualToString:@"base64"]) {
                                if (callback) {
                                    callback(@{@"code":@(0),@"responseData":@{@"result":[imgData base64String]}, @"msg":@"success"});
                                }
                            }else {
                                if (callback) {
                                    callback(@{@"code":@(-1), @"msg":@"unsupport uploadTarget!"});
                                }
                            }
                        }
                    }];
                });
            }
            
        } didCancel:^(LLImagePicker *picker) {
            if (callback) {
                callback(@{@"code":@(-1), @"msg":@"user cancel picking photos."});
            }
        }];
      
        }

}

+ (void)handleVideoRecordWithMessage:(NSDictionary *)message callback:(void(^)(id))callback {
     if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusRestricted || [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusDenied) {
         if (callback) {
             callback(@{@"code":@(-1), @"msg":@"This application is not authorized to access."});
         }
         [[SJAlertViewPresenter shareInstance] presentNormalAlertViewWithTitle:@"温馨提示" contentList:@[@"请在设置中，允许APP访问你的相机。"] bottomClickItem:@[@"取消", @"确定"] dismissFreedom:NO];
         [[SJAlertViewPresenter shareInstance] setExecResult:^(id result) {
             if ([result isEqualToString:@"确定"]) {
                 [self openSetting];
             }
         }];
     }else {
         recordView = [[JCVideoRecordView alloc]initWithFrame:[UIScreen mainScreen].bounds];

         recordView.cancelBlock = ^{
             if (callback) {
                 callback(@{@"code":@-1, @"msg":@" user cancele recording"});
             }
         };
         recordView.completionBlock = ^(NSURL *fileUrl) {

         };
         [recordView present];
     }
}

+ (void)openSetting {
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    }else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

+ (void)hans {
    [LLImagePicker sharedInstance].albumText = @"选择照片";
    [LLImagePicker sharedInstance].cancelText = @"取消";
    [LLImagePicker sharedInstance].doneText = @"完成";
    [LLImagePicker sharedInstance].retakeText = @"重拍";
    [LLImagePicker sharedInstance].choosePhotoText = @"选中照片";
    [LLImagePicker sharedInstance].automaticText = @"自动";
    [LLImagePicker sharedInstance].closeText = @"关闭";
    [LLImagePicker sharedInstance].openText = @"打开";
}

+ (NSNumber *)specificImageQuality:(NSString *)quality {
    
    NSUInteger compressFactor = 100;
    if ([quality isKindOfClass:[NSString class]]) {
        if ([quality isEqualToString:@"high"]) {
            compressFactor = 50;
        } else if ([quality isEqualToString:@"medium"]) {
            compressFactor = 100;
        } else if ([quality isEqualToString:@"low"]) {
            compressFactor = 500;
        } else if ([quality isEqualToString:@"superLow"]) {
            compressFactor = 3000;
        }
    }
    return@(compressFactor*1000);
}

@end

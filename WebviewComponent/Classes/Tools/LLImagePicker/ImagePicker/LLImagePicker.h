//
//  LLImagePicker.h
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/24.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <UIKit/UIKit.h>
#import "TOCropViewController.h"

@class LLImagePicker;

typedef void(^imagePickerWillFinished)(LLImagePicker *picker,UIImage *image);
typedef void(^imagePickerDidFinished)(LLImagePicker *picker,UIImage *image, NSURL *filePath);
typedef void(^imagePickerDidCancel)(LLImagePicker *picker);

typedef TOCropViewController*(^customCropViewController)(UIImage *image);

typedef NS_ENUM(NSInteger,LLImagePickerType){
    LLImagePickerTypeCamera = 0,
    LLImagePickerTypePhoto = 1
};

@interface LLImagePicker : NSObject

/**
 LLImagePicker *picker = [LLImagePicker sharedInstance];
 //自定义裁剪图片的ViewController
 picker.customCropViewController = ^TOCropViewController *(UIImage *image) {
 
 if (picker.type == LLImagePickerTypePhoto) {
 //使用默认
 return nil;
 }
 
 TOCropViewController  *cropController = [[TOCropViewController alloc] initWithImage:image];
 
 //选择框可以按比例来手动调节
 cropController.aspectRatioLockEnabled = NO;
 //        cropController.resetAspectRatioEnabled = NO;
 //设置选择宽比例
 cropController.aspectRatioPreset = TOCropViewControllerAspectRatioPresetSquare;
 //显示选择框比例的按钮
 cropController.aspectRatioPickerButtonHidden = NO;
 //显示选择按钮
 cropController.rotateButtonsHidden = NO;
 //设置选择框可以手动移动
 cropController.cropView.cropBoxResizeEnabled = YES;
 return cropController;
 };
 picker.albumText = @"albumText";
 picker.cancelText = @"cancelText";
 picker.doneText = @"doneText";
 picker.retakeText = @"retakeText";
 picker.choosePhotoText = @"choosePhotoText";
 picker.automaticText = @"Automatic";
 picker.closeText = @"CloseText";
 picker.openText = @"openText";
 UIViewController *choiceController = [picker actionSheetWithTakePhotoTitle:@"拍照" albumTitle:@"从相册选择一张图片" cancelTitle:@"取消" InViewController:self didFinished:^(LLImagePicker *picker, UIImage *image) {
 [self.avatarBtn setImage:image forState:UIControlStateNormal];
 }];
 
 [self.viewModel.navigatorService presentViewModel:choiceController animated:YES completion:nil];
 */

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic ,copy) customCropViewController  customCropViewController;
@property (nonatomic ,assign,readonly)LLImagePickerType type;
//取消按钮字体
@property (nonatomic ,strong) NSString *cancelText;
//完成按钮字体
@property (nonatomic ,strong) NSString *doneText;
//相册标题
@property (nonatomic ,strong) NSString *albumText;
//拍照后，重拍按钮字体
@property (nonatomic ,strong) NSString *retakeText;
//拍照后，使用照片按钮字体
@property (nonatomic ,strong) NSString *choosePhotoText;
//相机，自动
@property (nonatomic ,strong) NSString *automaticText;
//相机，打开
@property (nonatomic ,strong) NSString *openText;
//相机，关闭
@property (nonatomic ,strong) NSString *closeText;

+ (instancetype) sharedInstance;

- (UIImagePickerController *)showImagePickerWithType:(LLImagePickerType)type videoOnly:(BOOL)videoOnly InViewController:(UIViewController *)viewController willFinished:(imagePickerWillFinished)willFinished didFinished:(imagePickerDidFinished)finished;
- (UIImagePickerController *)showImagePickerWithType:(LLImagePickerType)type videoOnly:(BOOL)videoOnly InViewController:(UIViewController *)viewController willFinished:(imagePickerWillFinished)willFinished didFinished:(imagePickerDidFinished)finished didCancel:(imagePickerDidCancel)cancel;

- (UIViewController *)actionSheetWithTakePhotoTitle:(NSString *)takePhotoTitle  albumTitle:(NSString *)albumTitle cancelTitle:(NSString *)cancelTitle InViewController:(UIViewController *)viewController willFinished:(imagePickerWillFinished)willFinished didFinished:(imagePickerDidFinished)finished;
- (UIViewController *)actionSheetWithTakePhotoTitle:(NSString *)takePhotoTitle  albumTitle:(NSString *)albumTitle cancelTitle:(NSString *)cancelTitle InViewController:(UIViewController *)viewController willFinished:(imagePickerWillFinished)willFinished didFinished:(imagePickerDidFinished)finished didCancel:(imagePickerDidCancel)cancel;

@end

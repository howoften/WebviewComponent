//
//  LLImagePicker.m
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/24.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import "LLImagePicker.h"

@interface LLImagePicker()<UINavigationControllerDelegate,UIImagePickerControllerDelegate, TOCropViewControllerDelegate>

@property (nonatomic ,strong) UIViewController *viewController;
@property (nonatomic, copy)imagePickerWillFinished willFinished;
@property (nonatomic ,copy)imagePickerDidFinished didFinished;
@property (nonatomic ,copy)imagePickerDidCancel didCancel;
@property (nonatomic ,assign) BOOL isCustomTitle;
@end

static LLImagePicker *LLImagePickerSharedInstance = nil;
static dispatch_once_t LLImagePickerDispatch_once = 0;

@implementation LLImagePicker
+ (instancetype) sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        LLImagePickerSharedInstance = [[LLImagePicker alloc] init];
    });
 
    return LLImagePickerSharedInstance;
}

- (UIImagePickerController *)showImagePickerWithType:(LLImagePickerType)type videoOnly:(BOOL)videoOnly InViewController:(UIViewController *)viewController willFinished:(imagePickerWillFinished)willFinished didFinished:(imagePickerDidFinished)finished {
    return [self showImagePickerWithType:type videoOnly:videoOnly InViewController:viewController willFinished:willFinished didFinished:finished didCancel:nil];
}

- (UIImagePickerController *)showImagePickerWithType:(LLImagePickerType)type videoOnly:(BOOL)videoOnly InViewController:(UIViewController *)viewController willFinished:(imagePickerWillFinished)willFinished didFinished:(imagePickerDidFinished)finished didCancel:(imagePickerDidCancel)cancel {
    
    if (finished) {
        self.didFinished = finished;
    }
    if (cancel) {
        self.didCancel = cancel;
    }
    if (willFinished) {
        self.willFinished = willFinished;
    }
    if (type == LLImagePickerTypeCamera) {
        
        if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        {
            NSLog(@"模拟其中无法打开照相机,请在真机中使用");
            return nil;
        }
        self.imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
        _type = LLImagePickerTypeCamera;
    }else{
        self.imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
        if (videoOnly) {
            
            self.imagePickerController.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeVideo];
        }else {
            self.imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
        }
        _type = LLImagePickerTypePhoto;
    }
    
    self.imagePickerController.allowsEditing = NO;
    [LLImagePicker sharedInstance].viewController = viewController;
    [viewController presentViewController:self.imagePickerController animated:YES completion:nil];
    
    return self.imagePickerController;
    
}

- (UIViewController *)actionSheetWithTakePhotoTitle:(NSString *)takePhotoTitle  albumTitle:(NSString *)albumTitle cancelTitle:(NSString *)cancelTitle InViewController:(UIViewController *)viewController willFinished:(imagePickerWillFinished)willFinished didFinished:(imagePickerDidFinished)finished {
    return [self actionSheetWithTakePhotoTitle:takePhotoTitle albumTitle:albumTitle cancelTitle:cancelTitle InViewController:viewController willFinished:willFinished didFinished:finished didCancel:nil];
}

- (UIViewController *)actionSheetWithTakePhotoTitle:(NSString *)takePhotoTitle  albumTitle:(NSString *)albumTitle cancelTitle:(NSString *)cancelTitle InViewController:(UIViewController *)viewController willFinished:(imagePickerWillFinished)willFinished didFinished:(imagePickerDidFinished)finished didCancel:(imagePickerDidCancel)cancel{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (takePhotoTitle.length) {
        [alertController addAction: [UIAlertAction actionWithTitle: takePhotoTitle style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //处理点击拍照
            [self showImagePickerWithType:LLImagePickerTypeCamera videoOnly:NO InViewController:viewController willFinished:willFinished didFinished:finished didCancel:cancel];
        }]];
    }
    if (albumTitle.length) {
        [alertController addAction: [UIAlertAction actionWithTitle: albumTitle style: UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            //处理点击从相册选取
            [self showImagePickerWithType:LLImagePickerTypePhoto videoOnly:NO InViewController:viewController  willFinished:willFinished didFinished:finished didCancel:cancel];
        }]];
    }
    if (cancelTitle.length) {
        [alertController addAction: [UIAlertAction actionWithTitle: cancelTitle style: UIAlertActionStyleCancel handler:nil]];
    }
    
    return alertController;
}

- (void)dealloc{
    NSLog(@"相册助手已经销毁");
}

//当选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([info[UIImagePickerControllerMediaType] isEqualToString:@"public.movie"]) {
    
        [self cropDismissViewController:YES image:nil fileUrl:info[@"UIImagePickerControllerMediaURL"]];
    }else {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        TOCropViewController *  cropController = nil;
        if (self.customCropViewController) {
            cropController =  self.customCropViewController(image);
            if (cropController == nil) {
                cropController = [self defaultCropViewControllerWithImage:image];
            }
        }else{
            cropController = [self defaultCropViewControllerWithImage:image];
        }
        cropController.toolbar.cancelTextButton.titleLabel.adjustsFontSizeToFitWidth = YES; cropController.toolbar.doneTextButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        cropController.delegate = self;
        
        if ([LLImagePicker sharedInstance].cancelText.length) {
            [cropController.toolbar.cancelTextButton setTitle:[LLImagePicker sharedInstance].cancelText forState:UIControlStateNormal];
        }
        if ([LLImagePicker sharedInstance].doneText.length) {
            [cropController.toolbar.doneTextButton setTitle:[LLImagePicker sharedInstance].doneText forState:UIControlStateNormal];
        }
        
        if (picker.sourceType ==UIImagePickerControllerSourceTypeCamera ) {
            [picker pushViewController:cropController animated:NO];
        }else{
            [picker pushViewController:cropController animated:NO];
        }
    }
}

- (TOCropViewController *)defaultCropViewControllerWithImage:(UIImage *)image{
    TOCropViewController * cropController = [[TOCropViewController alloc] initWithImage:image];
    cropController.aspectRatioLockEnabled = YES;
    cropController.resetAspectRatioEnabled = NO;
    //        //设置选择宽比例
    cropController.aspectRatioPreset = TOCropViewControllerAspectRatioPresetSquare;
    cropController.aspectRatioPickerButtonHidden = YES;
    cropController.rotateButtonsHidden = NO;
    return cropController;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (self.didCancel) {
        [LLImagePicker sharedInstance].didCancel(self);
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        [[LLImagePicker sharedInstance] destroy];
    }];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if ([navigationController isEqual:[LLImagePicker sharedInstance].imagePickerController]) {
        
        if (navigationController.viewControllers.count == 1&&[LLImagePicker sharedInstance].imagePickerController.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
            
            if ([LLImagePicker sharedInstance].albumText.length) {
                navigationController.navigationBar.topItem.title = [LLImagePicker sharedInstance].albumText;
            }
        }
        if ([LLImagePicker sharedInstance].imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
            [self setupTakePhotoCustomTitleWithController:viewController];
        }
    }
    
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
}

- (void)setupTakePhotoCustomTitleWithController:(UIViewController *)viewController{
    
    if (![LLImagePicker sharedInstance].isCustomTitle) {
        return;
    }
    
    @try{
        UIViewController *viewfinderViewController = [viewController valueForKey:@"_viewfinderViewController"];
        UIView *bottomBar = [viewfinderViewController valueForKey:@"__bottomBar"];
        UIControl *modeDial = [bottomBar valueForKey:@"_modeDial"];
        [modeDial removeFromSuperview];
        //取消
        if ([LLImagePicker sharedInstance].cancelText.length) {
            UIButton *reviewButton = [bottomBar valueForKey:@"_reviewButton"];
            [reviewButton setTitle:[LLImagePicker sharedInstance].cancelText forState:UIControlStateNormal];
        }
        
        UIView *topBar = [viewfinderViewController valueForKey:@"__topBar"];
        UIView *flashButton = [topBar valueForKey:@"_flashButton"];
        NSArray *menuItems = [flashButton valueForKey:@"__menuItems"];
        NSString *key = @"_text";
        for (int i = 0; i < menuItems.count; i ++) {
            UIView *itemView = menuItems[i];
            UILabel *label = [itemView valueForKey:@"__label"];
            CGRect rect = label.frame;
            rect.size.width = 80;
            label.frame = rect;
            //自动
            if (i == 0) {
                if ([LLImagePicker sharedInstance].automaticText.length) {
                    label.text = [LLImagePicker sharedInstance].automaticText;
                    [itemView setValue:[LLImagePicker sharedInstance].automaticText forKey:key];
                }
            }
            //打开
            if (i == 1) {
                if ([LLImagePicker sharedInstance].openText.length) {
                    label.text = [LLImagePicker sharedInstance].openText;
                    [itemView setValue:[LLImagePicker sharedInstance].openText forKey:key];
                }
            }
            
            //关闭
            if (i == 2) {
                if ([LLImagePicker sharedInstance].closeText.length) {
                    label.text = [LLImagePicker sharedInstance].closeText;
                    [itemView setValue:[LLImagePicker sharedInstance].closeText forKey:key];
                }
            }
            
            
        }
        
        
        
        
        UIView *cropOverlay = [viewController valueForKey:@"__cropOverlay"];
        //选择图片
        if ([LLImagePicker sharedInstance].choosePhotoText.length) {
            [cropOverlay setValue:[LLImagePicker sharedInstance].choosePhotoText forKey:@"_defaultOKButtonTitle"];
        }
        
        //重拍
        if ([LLImagePicker sharedInstance].retakeText.length) {
            UIView *cropOverlayBottomBar = [cropOverlay valueForKey:@"__bottomBar"];
            UIView *previewBottomBar = [cropOverlayBottomBar valueForKey:@"_previewBottomBar"];
            UIButton *canceButton = [previewBottomBar valueForKey:@"_cancelButton"];
            [canceButton setTitle:[LLImagePicker sharedInstance].retakeText forState:UIControlStateNormal];
        }
        
        
        
    }@catch(NSException *e){
        NSLog(@"相机自定义字体时出现异常：%@",e);
    }@finally{}
    
    
}

- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle {
    if ([LLImagePicker sharedInstance].willFinished) {
        [LLImagePicker sharedInstance].willFinished(self, image);
    }
    [self cropDismissViewController:YES image:image fileUrl:nil];
}

- (void)cropViewController:(nonnull TOCropViewController *)cropViewController didFinishCancelled:(BOOL)cancelled{
    
    if (self.didCancel) {
        [LLImagePicker sharedInstance].didCancel(self);
        [LLImagePicker sharedInstance].didCancel = nil;
    }
    [self cropDismissViewController:NO image:nil fileUrl:nil];
    
}

- (void)cropDismissViewController:(BOOL)didFinish image:(UIImage *)image fileUrl:(NSURL *)fileUrl{
    if (self.imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
//        UIViewController *vc =  [LLImagePicker sharedInstance].imagePickerController;
//        while (vc.presentingViewController) {
//            vc = vc.presentingViewController;
//        }
        [[LLImagePicker sharedInstance].imagePickerController dismissViewControllerAnimated:YES completion:^{
            if (image != nil) {
                if (self.didFinished) {
                    self.didFinished(self, image, fileUrl);
                }
            }else {
                if (self.didCancel) {
                    self.didCancel(self);
                }
            }
            [[LLImagePicker sharedInstance] destroy];
        }];
        
    }else{
        if (didFinish) {
            [self.imagePickerController popViewControllerAnimated:NO];
            [[LLImagePicker sharedInstance].viewController dismissViewControllerAnimated:YES completion:^{
                if (self.didFinished) {
                    self.didFinished(self, image, fileUrl);
                }
                [[LLImagePicker sharedInstance] destroy];
            }];
        }else{
            [self.imagePickerController popViewControllerAnimated:YES];
        }
        
        
    }
}

- (UIImagePickerController *)imagePickerController{
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.allowsEditing = NO;
    }
    return _imagePickerController;
}

- (void)destroy{
//    [LLImagePicker sharedInstance].viewController = nil;
////    [LLImagePicker sharedInstance].imagePickerController = nil;
//    [LLImagePicker sharedInstance].customCropViewController = nil;
    [LLImagePicker sharedInstance].didCancel = nil;
    [LLImagePicker sharedInstance].didFinished = nil;
    [LLImagePicker sharedInstance].willFinished = nil;
//    [LLImagePicker sharedInstance].doneText = nil;
//    [LLImagePicker sharedInstance].cancelText = nil;
//    [LLImagePicker sharedInstance].albumText = nil;
//    [LLImagePicker sharedInstance].retakeText = nil;
//    [LLImagePicker sharedInstance].automaticText = nil;
//    [LLImagePicker sharedInstance].closeText = nil;
//    [LLImagePicker sharedInstance].openText = nil;
//    [LLImagePicker sharedInstance].choosePhotoText = nil;
//    [LLImagePicker sharedInstance].isCustomTitle = NO;
////    LLImagePickerSharedInstance = nil;
//    LLImagePickerDispatch_once = 0;
    
}



- (void)setDoneText:(NSString *)doneText{
    _doneText = doneText;
    if (_doneText.length) {
        self.isCustomTitle = YES;
    }
}

- (void)setCancelText:(NSString *)cancelText{
    _cancelText = cancelText;
    if (_cancelText.length) {
        self.isCustomTitle = YES;
    }
}

- (void)setAlbumText:(NSString *)albumText{
    _albumText = albumText;
    if (_albumText.length) {
        self.isCustomTitle = YES;
    }
}

- (void)setRetakeText:(NSString *)retakeText{
    _retakeText = retakeText;
    if (_retakeText.length) {
        self.isCustomTitle = YES;
    }
}

- (void)setChoosePhotoText:(NSString *)choosePhotoText{
    _choosePhotoText = choosePhotoText;
    if (_choosePhotoText.length) {
        self.isCustomTitle = YES;
    }
}

- (void)setAutomaticText:(NSString *)automaticText{
    _automaticText = automaticText;
    if (_automaticText.length) {
        self.isCustomTitle = YES;
    }
}

- (void)setOpenText:(NSString *)openText{
    _openText = openText;
    if (_openText.length) {
        self.isCustomTitle = YES;
    }
}

- (void)setCloseText:(NSString *)closeText{
    _closeText = closeText;
    if (_closeText.length) {
        self.isCustomTitle = YES;
    }
}

@end


//
//  LLNavigationBar.m
//  WebviewComponent
//
//  Created by 刘江 on 2018/8/4.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import "LLWebNavigationBar.h"
#import <objc/runtime.h>

@interface LLWebNavigationBar ()
@property (nonatomic, strong)CAShapeLayer *shadowLine;
@property (nonatomic, strong)UIViewController *contributeVC;
@property (nonatomic, strong)UIViewController *contributeNav;
@property (nonatomic, strong)UIVisualEffectView *backMaskView;

@end

static LLWebNavigationBar *config = nil;
static NSMutableArray *unsatisfiedVC = nil;
static NSMutableArray *unsatisfiedNav = nil;

@implementation LLWebNavigationBar

+ (void)contributeForViewController:(Class _Nonnull __unsafe_unretained)viewController navigationController:(Class _Nonnull __unsafe_unretained)navigationController {
    id sampleVC = [viewController new];
    id sampleNav = [navigationController new];
    if ([sampleVC isKindOfClass:[UINavigationController class]] || [sampleVC isKindOfClass:[UITabBarController class]] || ![sampleVC isKindOfClass:[UIViewController class]] || [sampleVC isKindOfClass:[NSClassFromString(@"UIInputWindowController") class]] || ![sampleNav isKindOfClass:[UINavigationController class]]) {
        NSLog(@"Cannot add LLNavigationBar, ViewController type or navigationController type is wrong !");
        return;
    }
    config = [[LLWebNavigationBar alloc] init];
    config.contributeVC = sampleVC;
    config.contributeNav = sampleNav;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _init];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self _init];
    }
    return self;
}
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    
    [_backMaskView removeFromSuperview];
}

- (void)setImage:(UIImage *)image {
    [super setImage:image];
    
    [_backMaskView removeFromSuperview];
}

- (void)_init {
    self.frame = CGRectZero;
    self.showNavigationBarShadow = YES;
    [self addSubview:self.backMaskView];
    //    self.clipsToBounds = NO;
    
}

- (void)setFrame:(CGRect)frame {
    CGRect informal = frame;
    informal.origin.x = 0;
    informal.origin.y = 0;
    informal.size.width = CGRectGetWidth([UIScreen mainScreen].bounds);
    informal.size.height = 44+(CGRectGetHeight([UIApplication sharedApplication].statusBarFrame)==40?20:CGRectGetHeight([UIApplication sharedApplication].statusBarFrame));
    
    [super setFrame:informal];
}

- (void)setShowNavigationBarShadow:(BOOL)showNavigationBarShadow {
    
    if (_showNavigationBarShadow != showNavigationBarShadow) {
        if (showNavigationBarShadow) {
            self.layer.shadowColor = [UIColor colorWithRed:203/255.f green:203/255.f blue:203/255.f alpha:1].CGColor;
            self.layer.shadowOffset = CGSizeMake(0, 3);
            self.layer.shadowRadius = 3;
            self.layer.shadowOpacity = 0.7;
            
            [self.layer setShadowPath:[[UIBezierPath bezierPathWithRect:self.bounds] CGPath]];
        }else {
            self.layer.shadowColor = [UIColor clearColor].CGColor;
            self.layer.shadowOffset = CGSizeMake(0, 0);
            self.layer.shadowRadius = 0;
            self.layer.shadowOpacity = 0.f;
            
            [self.layer setShadowPath:[[UIBezierPath bezierPathWithRect:CGRectZero] CGPath]];
        }
        [self setNeedsDisplay];
    }
    _showNavigationBarShadow = showNavigationBarShadow;
}

- (UIVisualEffectView *)backMaskView {
    if (!_backMaskView) {
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _backMaskView = [[UIVisualEffectView alloc] initWithEffect:blur];
        _backMaskView.frame = self.bounds;
    }
    return _backMaskView;
}

@end

@interface UIViewController()

@property (nonatomic, strong)LLWebNavigationBar *navigationBar;

@end

static const void *kNavigationBarKey = &kNavigationBarKey;
@implementation UIViewController(NavigationBar)
+ (void)load {
    if (!unsatisfiedVC) {
        unsatisfiedVC = [NSMutableArray arrayWithCapacity:0];
    }
    if (!unsatisfiedNav) {
        unsatisfiedNav = [NSMutableArray arrayWithCapacity:0];
    }
    
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL origin_SEL = @selector(viewDidLoad);
        SEL swizzing_SEL = @selector(t_viewDidLoad);
        
        Method origin_Method = class_getInstanceMethod(self.class, origin_SEL);
        Method swizzing_Method = class_getInstanceMethod(self.class, swizzing_SEL);
        
        BOOL didAdd = class_addMethod(self.class, origin_SEL, method_getImplementation(swizzing_Method), method_getTypeEncoding(swizzing_Method));
        
        if (didAdd) {
            class_replaceMethod(self.class, swizzing_SEL, method_getImplementation(origin_Method), method_getTypeEncoding(origin_Method));
        }else {
            method_exchangeImplementations(origin_Method, swizzing_Method);
        }
        
        SEL origin_SEL1 = @selector(viewWillAppear:);
        SEL swizzing_SEL1 = @selector(t_viewWillAppear:);
        
        Method origin_Method1 = class_getInstanceMethod(self.class, origin_SEL1);
        Method swizzing_Method1 = class_getInstanceMethod(self.class, swizzing_SEL1);
        
        BOOL didAdd1 = class_addMethod(self.class, origin_SEL1, method_getImplementation(swizzing_Method1), method_getTypeEncoding(swizzing_Method1));
        
        if (didAdd1) {
            class_replaceMethod(self.class, swizzing_SEL1, method_getImplementation(origin_Method1), method_getTypeEncoding(origin_Method1));
        }else {
            method_exchangeImplementations(origin_Method1, swizzing_Method1);
        }
    });
}

- (void)t_viewDidLoad {
    
    if (config.contributeVC && [self isKindOfClass:[[config.contributeVC class] class]]) {
        self.navigationBar = [[LLWebNavigationBar alloc] init];
        [self.view addSubview:self.navigationBar];
        
        [self satisfyMissedNavigaion];
    }else if (![self isKindOfClass:[UINavigationController class]] && ![self isKindOfClass:[UITabBarController class]] && [self isKindOfClass:[UIViewController class]] && ![self isKindOfClass:[NSClassFromString(@"UIInputWindowController") class]] && ![unsatisfiedVC containsObject:self]) {
        [unsatisfiedVC addObject:self];
        
    }
    
    if (config.contributeNav && [self isKindOfClass:[[config.contributeNav class] class]]) {
        [[(UINavigationController *)self navigationBar] setTranslucent:YES];
        [[(UINavigationController *)self navigationBar] setBackgroundImage:[self imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
        [(UINavigationController *)self navigationBar].shadowImage = [UIImage new];
        [(UINavigationController *)self navigationBar].subviews.firstObject.alpha = 0.f;
        
        [self satisfyMissedViewController];
    }else if (([self isKindOfClass:[UINavigationController class]] && ![unsatisfiedNav containsObject:self])) {
        [unsatisfiedNav addObject:self];
        
    }
    
}

- (void)t_viewWillAppear:(BOOL)animated {
    if ([self isKindOfClass:[[config.contributeVC class] class]]) {
        if (self.navigationController) {
            if (self.view.subviews.lastObject != self.navigationBar) {
                if (self.navigationBar) {
                    if (!self.navigationBar.superview) { //xib bug
                        UIColor *foregroundColor = self.navigationBar.backgroundColor;
                        self.navigationBar = nil;
                        [self.navigationBar removeFromSuperview];
                        self.navigationBar = [[LLWebNavigationBar alloc] init];
                        [self.view addSubview:self.navigationBar];
                        self.navigationBar.backgroundColor = foregroundColor;
                    }else {
                        [self.view bringSubviewToFront:self.navigationBar];
                    }
                }
            }
        }else if (self.navigationBar) {
            [self.navigationBar removeFromSuperview];
            self.navigationBar = nil;
        }
    }
}

- (void)setNavigationBar:(LLWebNavigationBar *)navigationBar {
    objc_setAssociatedObject(self, &kNavigationBarKey, navigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (LLWebNavigationBar *)navigationBar {
    return objc_getAssociatedObject(self, &kNavigationBarKey);
}

- (void)satisfyMissedNavigaion {
    if (unsatisfiedNav.count > 0) {
        [unsatisfiedNav enumerateObjectsUsingBlock:^(UINavigationController *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[config.contributeNav class]]) {
                [[(UINavigationController *)self navigationBar] setTranslucent:YES];
                [[(UINavigationController *)obj navigationBar] setBackgroundImage:[self imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
                [(UINavigationController *)obj navigationBar].shadowImage = [UIImage new];
                [(UINavigationController *)self navigationBar].subviews.firstObject.alpha = 0.f;
            }
        }];
        [unsatisfiedNav removeAllObjects];
    }
}

- (void)satisfyMissedViewController {
    if (unsatisfiedVC.count > 0) {
        [unsatisfiedVC enumerateObjectsUsingBlock:^(UIViewController *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[config.contributeVC class]]) {
                obj.navigationBar = [[LLWebNavigationBar alloc] init];
                [obj.view addSubview:obj.navigationBar];
            }
        }];
        [unsatisfiedVC removeAllObjects];
    }
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
@end

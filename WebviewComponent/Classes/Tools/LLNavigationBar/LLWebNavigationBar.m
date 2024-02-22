//
//  LLNavigationBar.m
//  LLNavigationBar
//
//  Created by liujiang on 2022/9/22.
//

#import <objc/runtime.h>
#import "LLWebNavigationBar.h"

@interface LLWebNavigationBar ()
@property (nonatomic, strong)UIImageView *backgroundImageView;
@property (nonatomic, strong)UIVisualEffectView *blurView;
@property (nonatomic, strong)UIView *contentView;
@property (nonatomic, assign)CGFloat statusBarHeight;

@property (nonatomic, strong)UIStackView *titleStack;
@property (nonatomic, strong)UILabel *titleLabel;
@property (nonatomic, strong)UILabel *subTitleLabel;

@property (nonatomic, strong)UIStackView *leftStack;
@property (nonatomic, strong)UIStackView *rightStack;

@property (nonatomic, strong)NSLayoutConstraint *topInset;
@property (nonatomic, strong)NSLayoutConstraint *leftInset;
@property (nonatomic, strong)NSLayoutConstraint *bottomInset;
@property (nonatomic, strong)NSLayoutConstraint *rightInset;
@property (nonatomic, strong)NSLayoutConstraint *contentHeight;


@property (nonatomic, strong)NSLayoutConstraint *barBottomAnchor;

@property (nonatomic) BOOL titleColorModified;
@property (nonatomic, strong)LLNavigationBackButton *privateBackButton;
@property (nonatomic, strong) NSNumber *setHiddenBackButton;
@property (nonatomic) BOOL markNeedLayout;
@end
const NSInteger llNavigationBarTag = 3145;
@implementation LLWebNavigationBar

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configBarStyle];
        [self setup];
        __weak LLNavigationBar *bar_weak_ref = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillChangeStatusBarFrameNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
                bar_weak_ref.barBottomAnchor.constant = -[bar_weak_ref barStandarMarginBottom];
                [bar_weak_ref setNeedsUpdateConstraints];
            }else {
                bar_weak_ref.markNeedLayout = YES;
            }
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            if (bar_weak_ref.markNeedLayout)  {
                bar_weak_ref.barBottomAnchor.constant = -[bar_weak_ref barStandarMarginBottom];
                [bar_weak_ref setNeedsUpdateConstraints];
                bar_weak_ref.markNeedLayout = NO;
            }
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            if (bar_weak_ref.markNeedLayout)  {
                bar_weak_ref.barBottomAnchor.constant = -[bar_weak_ref barStandarMarginBottom];
                [bar_weak_ref setNeedsUpdateConstraints];
                bar_weak_ref.markNeedLayout = NO;
            }
        }];
    }
    return self;
}
- (void)configBarStyle {
    self.tag = llNavigationBarTag;
    _translucent= YES;
    _lightStyle = YES;
    _shadowColor = [UIColor colorWithRed:203/255.f green:203/255.f blue:203/255.f alpha:1];
    _backButtonColor = UIColor.systemBlueColor;
    self.layer.shadowColor = _shadowColor.CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 3);
    self.layer.shadowRadius = 3;
    self.layer.shadowOpacity = 0.7;
}
- (void)setup {
    self.backgroundImageView = [UIImageView new];
    [self addSubview:self.backgroundImageView];
    self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backgroundImageView.leftAnchor constraintEqualToAnchor:self.backgroundImageView.superview.leftAnchor constant:0].active = YES;
    [self.backgroundImageView.topAnchor constraintEqualToAnchor:self.backgroundImageView.superview.topAnchor constant:0].active = YES;
    [self.backgroundImageView.bottomAnchor constraintEqualToAnchor:self.backgroundImageView.superview.bottomAnchor constant:0].active = YES;
    [self.backgroundImageView.rightAnchor constraintEqualToAnchor:self.backgroundImageView.superview.rightAnchor constant:0].active = YES;
    
    
    UIBlurEffect *style = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:style];
    [self addSubview:self.blurView];
    self.blurView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.blurView.leftAnchor constraintEqualToAnchor:self.blurView.superview.leftAnchor constant:0].active = YES;
    [self.blurView.topAnchor constraintEqualToAnchor:self.blurView.superview.topAnchor constant:0].active = YES;
    [self.blurView.bottomAnchor constraintEqualToAnchor:self.blurView.superview.bottomAnchor constant:0].active = YES;
    [self.blurView.rightAnchor constraintEqualToAnchor:self.blurView.superview.rightAnchor constant:0].active = YES;
    
    self.contentView = [UIView new];
    [self addSubview:self.contentView];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    _topInset = [self.contentView.topAnchor constraintEqualToAnchor:self.contentView.superview.topAnchor constant:self.contentInset.top + self.statusBarHeight];
    _leftInset = [self.contentView.leftAnchor constraintEqualToAnchor:self.contentView.superview.leftAnchor constant:self.contentInset.left];
    _bottomInset = [self.contentView.bottomAnchor constraintEqualToAnchor:self.contentView.superview.bottomAnchor constant:self.contentInset.bottom];
    _rightInset = [self.contentView.rightAnchor constraintEqualToAnchor:self.contentView.superview.rightAnchor constant:self.contentInset.right];
    _contentHeight = [self.contentView.heightAnchor constraintEqualToConstant:44];
    _topInset.priority = UILayoutPriorityDefaultLow;
    _topInset.active = YES;
    _leftInset.active = YES;
    _bottomInset.active = YES;
    _rightInset.active = YES;
    _contentHeight.active = YES;
    
    
    self.titleStack = [UIStackView new];
    self.titleStack.axis = UILayoutConstraintAxisVertical;
    self.titleStack.spacing = 2;
    self.titleStack.distribution = UIStackViewDistributionFillProportionally;
    self.titleStack.alignment = UIStackViewAlignmentCenter;
    self.titleStack.translatesAutoresizingMaskIntoConstraints = false;
    [self.contentView addSubview:self.titleStack];
    [self.titleStack.centerXAnchor constraintEqualToAnchor:self.titleStack.superview.centerXAnchor].active = YES;
    [self.titleStack.centerYAnchor constraintEqualToAnchor:self.titleStack.superview.centerYAnchor].active = YES;
    self.titleLabel = [UILabel new];
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.titleStack addArrangedSubview:self.titleLabel];
    self.subTitleLabel = [UILabel new];
    [self.subTitleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    self.subTitleLabel.font = [UIFont systemFontOfSize:12];
    [self.titleStack addArrangedSubview:self.subTitleLabel];
    
    
    self.leftStack = [UIStackView new];
    self.leftStack.axis = UILayoutConstraintAxisHorizontal;
    self.leftStack.distribution = UIStackViewDistributionEqualSpacing;
    self.leftStack.alignment = UIStackViewAlignmentCenter;
    self.leftStack.translatesAutoresizingMaskIntoConstraints = false;
    [self.contentView addSubview:self.leftStack];
    [self.leftStack.leftAnchor constraintEqualToAnchor:self.leftStack.superview.leftAnchor].active = YES;
    [self.leftStack.centerYAnchor constraintEqualToAnchor:self.leftStack.superview.centerYAnchor].active = YES;
    [self.leftStack.rightAnchor constraintLessThanOrEqualToAnchor:self.titleStack.leftAnchor constant:-3].active = YES;
    [self.leftStack.heightAnchor constraintEqualToConstant:44].active = YES;
    
    self.privateBackButton = [[LLNavigationBackButton alloc] init];
    self.privateBackButton.strokeColor = self.backButtonColor;
    [self.leftStack addArrangedSubview:self.privateBackButton];
    [self.privateBackButton addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
    self.backButton = self.privateBackButton;
    
    self.rightStack = [UIStackView new];
    self.rightStack.axis = UILayoutConstraintAxisHorizontal;
    self.rightStack.distribution = UIStackViewDistributionEqualSpacing;
    self.rightStack.alignment = UIStackViewAlignmentCenter;
    self.rightStack.translatesAutoresizingMaskIntoConstraints = false;
    [self.contentView addSubview:self.rightStack];
    [self.rightStack.rightAnchor constraintEqualToAnchor:self.rightStack.superview.rightAnchor].active = YES;
    [self.rightStack.centerYAnchor constraintEqualToAnchor:self.rightStack.superview.centerYAnchor].active = YES;
    [self.rightStack.leftAnchor constraintGreaterThanOrEqualToAnchor:self.titleStack.rightAnchor constant:3].active = YES;
    [self.rightStack.heightAnchor constraintEqualToConstant:44].active = YES;
    
    
}
- (void)onBack {
    UIViewController *current = [self viewController];
    if (current.navigationController == nil) {
        if (current.navigationController.presentingViewController != nil) {
            [current.navigationController dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        if (current.presentingViewController != nil) {
            [current dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        return;
    }
    if ([current.navigationController.viewControllers indexOfObject:current] > 0) {
        [current.navigationController popViewControllerAnimated:YES];
        return;
    }
    if (current.navigationController.presentingViewController != nil) {
        [current.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    if (current.presentingViewController != nil) {
        [current dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
}
- (void)applyConstraintInView:(UIView *)view {
    UIView *superView = view ?: self.superview;
    [superView addSubview: self];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.leftAnchor constraintEqualToAnchor:self.superview.leftAnchor].active = YES;
    [self.rightAnchor constraintEqualToAnchor:self.superview.rightAnchor].active = YES;
    [self.heightAnchor constraintEqualToConstant:self.statusBarHeight+44].active = YES;
    
    
    self.barBottomAnchor = [self.bottomAnchor constraintEqualToAnchor:self.superview.bottomAnchor constant:-[self barStandarMarginBottom]];
    self.barBottomAnchor.active = YES;
    
}
- (void)layoutSubviews {
    [super layoutSubviews];
    [self.superview bringSubviewToFront:self];
    self.barBottomAnchor.constant = -[self barStandarMarginBottom];
    [self hiddenBackButtonIfNeeded];
    [self setNeedsUpdateConstraints];
}
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    [self.superview bringSubviewToFront:self];
    self.barBottomAnchor.constant = -[self barStandarMarginBottom];
    [self hiddenBackButtonIfNeeded];
    [self setNeedsUpdateConstraints];
    [[self viewController] hiddenDefaultNavigationBar];
}
- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    [self.superview bringSubviewToFront:self];
    self.barBottomAnchor.constant = -[self barStandarMarginBottom];
    [self hiddenBackButtonIfNeeded];
    [self setNeedsUpdateConstraints];
    [[self viewController] hiddenDefaultNavigationBar];
}

- (void)hiddenBackButtonIfNeeded {
    if (self.backButton != self.privateBackButton) return;
    
    if (self.setHiddenBackButton) {
        self.backButton.hidden = [self.setHiddenBackButton boolValue];
        return;
    }
    UIViewController *current = [self viewController];
    if (current.presentingViewController != nil || current.navigationController.presentingViewController != nil) {
        self.backButton.hidden = NO;
        return;
    }
    if ([current.navigationController.viewControllers indexOfObject:current] > 0) {
        self.backButton.hidden = NO;
        return;
    }
    self.backButton.hidden = YES;
    
}
- (void)setContentInset:(UIEdgeInsets)contentInset {
    if (UIEdgeInsetsEqualToEdgeInsets(contentInset, _contentInset)) return;
    _contentInset = contentInset;
    
    _topInset.constant = contentInset.top + self.statusBarHeight;
    _leftInset.constant = contentInset.left;
    _bottomInset.constant = -contentInset.bottom;
    _rightInset.constant = -contentInset.right;
    [self setNeedsLayout];
}
- (void)setLeftItems:(NSArray<UIView *> *)leftItems {
    [_leftItems enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
        [obj removeFromSuperview];
    }];
    
    _leftItems = leftItems;
    [leftItems enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.leftStack addArrangedSubview:obj];
    }];
    
}
- (void)setRightItems:(NSArray<UIView *> *)rightItems {
    [_rightItems enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
        [obj removeFromSuperview];
    }];
    
    _rightItems = rightItems;
    [rightItems enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.rightStack addArrangedSubview:obj];
    }];
}
- (void)setTitleView:(UIView *)titleView {
    if (_titleView) {
        [self.titleStack removeArrangedSubview:_titleView];
    }
    _titleView = titleView;
    [_titleView removeFromSuperview];
    _titleLabel.hidden = titleView != nil;
    _subTitleLabel.hidden = titleView != nil;
    if (!titleView) return;
    [self.titleStack insertArrangedSubview:titleView atIndex:0];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}
- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    _titleLabel.textColor = titleColor;
    _titleColorModified = YES;
}
- (void)setAttributeTitle:(NSAttributedString *)attributeTitle {
    _attributeTitle = attributeTitle;
    _titleLabel.attributedText = attributeTitle;
}
- (void)setSubTitle:(NSString *)subTitle {
    _subTitle = subTitle;
    _subTitleLabel.text = subTitle;
}
- (void)setSubTitleColor:(UIColor *)subTitleColor {
    _subTitleColor = subTitleColor;
    _subTitleLabel.textColor = subTitleColor;
    _titleColorModified = YES;
}
- (void)setSubAttributeTitle:(NSAttributedString *)subAttributeTitle {
    _subAttributeTitle = subAttributeTitle;
    _subTitleLabel.attributedText = subAttributeTitle;
}
- (void)setTitleSpacing:(CGFloat)titleSpacing {
    _titleSpacing = titleSpacing;
    _titleStack.spacing = titleSpacing;
}
- (void)setLeftItemSpacing:(CGFloat)leftItemSpacing {
    _leftItemSpacing = leftItemSpacing;
    _leftStack.spacing = leftItemSpacing;
}
- (void)setRightItemSpacing:(CGFloat)rightItemSpacing {
    _rightItemSpacing = rightItemSpacing;
    _rightStack.spacing = rightItemSpacing;
}
- (void)setLightStyle:(BOOL)lightStyle {
    _lightStyle = lightStyle;
    UIBlurEffect *style = [UIBlurEffect effectWithStyle:lightStyle ? UIBlurEffectStyleLight : UIBlurEffectStyleDark];
    self.blurView.effect = style;
    
    if (!self.titleColorModified ) {
        self.titleLabel.textColor = lightStyle ? UIColor.blackColor : UIColor.whiteColor;
        self.subTitleLabel.textColor = lightStyle ? UIColor.blackColor : UIColor.whiteColor;
    }
    
}
- (void)setShadowColor:(UIColor *)shadowColor {
    _shadowColor = shadowColor;
    self.layer.shadowColor = shadowColor.CGColor;
}

- (void)showAnimated:(BOOL)animated {
    if (!animated) {
        self.transform = CGAffineTransformIdentity;
        return;
    }
    self.transform = CGAffineTransformMakeTranslation(0, -MAX(self.statusBarHeight + 44, CGRectGetMaxY(self.frame)));
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}
- (void)hiddenAnimated:(BOOL)animated {
    if (!animated) {
        self.transform = CGAffineTransformMakeTranslation(0, -MAX(self.statusBarHeight + 44, CGRectGetMaxY(self.frame)) - 5); //+阴影偏移量
        return;
    }
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, -MAX(self.statusBarHeight + 44, CGRectGetMaxY(self.frame)) - 5);
    } completion:^(BOOL finished) {
        
    }];
}
- (void)hiddenPercent:(CGFloat)percent {
    if (percent < 0) {
        self.transform = CGAffineTransformMakeTranslation(0, 0);
        return;
    }
    self.transform = CGAffineTransformMakeTranslation(0, -MAX(self.statusBarHeight + 44, CGRectGetHeight(self.frame)) * percent);
}
- (void)showPercent:(CGFloat)percent {
    if (percent > 1) {
        self.transform = CGAffineTransformIdentity;
        return;
    }
    self.transform = CGAffineTransformMakeTranslation(0, -MAX(self.statusBarHeight + 44, CGRectGetHeight(self.frame)) * (1-percent));
}

- (void)setTranslucent:(BOOL)translucent {
    _translucent = translucent;
    
    self.blurView.hidden = !translucent;
    
    if (self.backgroundColor == nil && !translucent) {
        self.backgroundColor = _lightStyle ? [UIColor colorWithWhite:250 / 255.0 alpha:1] : [UIColor colorWithWhite:100 / 255.0 alpha:1];
    }else if ((CGColorEqualToColor(self.backgroundColor.CGColor, [UIColor colorWithWhite:250 / 255.0 alpha:1].CGColor) ||
               CGColorEqualToColor(self.backgroundColor.CGColor, [UIColor colorWithWhite:100 / 255.0 alpha:1].CGColor)) && translucent) {
        self.backgroundColor = nil;
    }
}
- (void)setBackButton:(UIView *)backButton {
    if ([self.leftStack.arrangedSubviews containsObject:_backButton]) {
        _backButton.hidden = YES;
        [self.leftStack removeArrangedSubview:_backButton];
        
    }
    _backButton = backButton;
    [self.leftStack insertArrangedSubview:backButton atIndex:0];
    
}
- (void)setHiddenBackButton:(BOOL)hiddenBackButton {
    _hiddenBackButton = hiddenBackButton;
    self.setHiddenBackButton = @(hiddenBackButton);
    [self hiddenBackButtonIfNeeded];
}
- (void)setBackButtonColor:(UIColor *)backButtonColor {
    _backButtonColor = backButtonColor;
    self.privateBackButton.strokeColor = backButtonColor;
}

- (CGFloat)statusBarHeight {
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    if (CGRectGetHeight([UIScreen mainScreen].nativeBounds) / [UIScreen mainScreen].scale < 737 ) { // plus: 414 * 736
        return 20;
    }
    if (@available(iOS 11.0, *)) {
        if (window.safeAreaInsets.bottom > 0 && _statusBarHeight < 40) {
            _statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        }else if (window.safeAreaInsets.bottom < 1 && _statusBarHeight < 1) {
            _statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        }
    }
    if (_statusBarHeight < 1) {
        if (@available(iOS 11.0, *)) {
            if (window.safeAreaInsets.top > 0) {
                _statusBarHeight = 44;
            }else if (window.safeAreaInsets.top < 1) {
                _statusBarHeight = 20;
            }
        } else {
            _statusBarHeight = 20;
        }
    }
    return _statusBarHeight;
}
- (CGFloat)barStandarMarginBottom {
    UIViewController *barController = [self viewController];
    CGFloat height = CGRectGetHeight(barController.view.frame);
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    if (height < CGRectGetHeight(window.frame) - self.statusBarHeight - 44 ) {
        barController = window.rootViewController;
        height = CGRectGetHeight(barController.view.frame);
    }
    return height - self.statusBarHeight - 44;
}

- (UIViewController *)viewController {
    UIResponder *viewController = self;
    while (viewController.nextResponder != nil && ![viewController isKindOfClass:UIViewController.class]) {
        viewController = viewController.nextResponder;
    }
    return [viewController isKindOfClass:UIViewController.class] ? viewController : nil;
}



@end


@implementation UIViewController (LLNavigationBar)

- (LLNavigationBar *)navigationBar {
    LLNavigationBar *bar = [self.view viewWithTag:llNavigationBarTag];
    if (![bar isKindOfClass:LLNavigationBar.class]) {
        bar = [[LLNavigationBar alloc] initWithFrame:CGRectZero];
        [self.view addSubview:bar];
        [bar applyConstraintInView:nil];
        [self hiddenDefaultNavigationBar];
    }
    return bar;
}
- (void)hiddenDefaultNavigationBar {
    if (!self.navigationController) return;
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.alpha = 0;
    [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *apperance =  [UINavigationBarAppearance new];
        [apperance setBackgroundImage:[self imageWithColor:[UIColor clearColor]]];
        [apperance setShadowImage:[UIImage new]];
        self.navigationController.navigationBar.scrollEdgeAppearance = self.navigationController.navigationBar.standardAppearance = apperance;
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

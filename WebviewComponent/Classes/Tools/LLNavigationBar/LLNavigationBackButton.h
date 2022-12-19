//
//  LLNavigationBackButton.h
//  LLNavigationBar
//
//  Created by liujiang on 2022/12/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LLNavigationBackButton : UIControl
@property(nonatomic) CAShapeLayerLineCap lineCap;
@property(nonatomic) CAShapeLayerLineJoin lineJoin;
@property(nonatomic) CGFloat lineWidth;
@property(nonatomic, strong) UIColor *strokeColor;
@property(nonatomic) CGFloat strokeAngle;

@end

NS_ASSUME_NONNULL_END

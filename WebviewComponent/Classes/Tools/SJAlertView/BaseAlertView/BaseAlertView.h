//
//  BaseAlertView.h
//  AlertTest
//
//  Created by jonh on 2017/10/26.
//  Copyright © 2017年 jonh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
///弹窗模式
typedef enum{
    ///默认 从窗口正中 弹出
    BaseAlertViewStyleAlert = 0,
    ///下
    BaseAlertViewStyleActionSheetDown,
    ///上
    BaseAlertViewStyleActionSheetTop,
    ///左
    BaseAlertViewStyleActiAlertLeft,
    ///右边
    BaseAlertViewStyleActiAlertRight,
    
}BaseAlertViewStyle;
///关闭模式
typedef enum{
    ///触摸背景 关闭窗口 【默认】
    CloseStyleTapClose = 0,
    /// 不允许触摸背景 关闭窗口
    CloseStyleNever,
}CloseStyle;
typedef void(^showBlock)(void);;
typedef void(^dismissBlock)(void);

@interface BaseAlertView : NSObject
///弹出动画完成后的 回调
@property (nonatomic, copy) showBlock showBlock;
///关闭回调
@property (nonatomic, copy) dismissBlock dismissBlock;
///关闭模式
@property (nonatomic, assign) CloseStyle closeStyle;


/// 开启或关闭 自带的 移除弹窗事件 如果关闭需要自己调用 dismiss
//@property (nonatomic, assign) BOOL on;
/// 关闭按钮 图片 30*30
//@property (nonatomic, strong) UIImage *closeImage;
/**  创建弹出试图 */
+ (BaseAlertView *)share;
/**
 * show:withType:     弹出视图
 * @param contentView 需要弹出的视图
 * @param style       弹出模式
 */
- (void)show:(UIView *)contentView withType:(BaseAlertViewStyle)style;
/**w
 *  show:withType:animationFinish:dismissHandle: 弹出视图
 *  @param contentView 需要弹出的视图
 *  @param style       弹出模式
 *  @param show        弹出回调
 *  @param dismiss     消失回调
 *
 */
- (void)show:(UIView *)contentView withType:(BaseAlertViewStyle)style animationFinish:(showBlock)show dismissHandle:(dismissBlock)dismiss;
/**  移除弹出视图 */
- (void)dismiss:(UITapGestureRecognizer *)tap;

@end


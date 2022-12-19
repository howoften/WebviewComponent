//
//  CJSignatureView.h
//  CJSignatureDome
//
//  Created by zxjk on 17/8/17.
//
//

#import <UIKit/UIKit.h>

@interface CJSignatureView : UIView
// 线宽 默认1
@property (nonatomic, assign) CGFloat lineWidth;
// 线颜色 默认黑
@property (nonatomic, strong) UIColor *lineColor;
// 生成图片的缩放比例 默认1不缩放 范围0.1~1.0
@property (nonatomic, assign) CGFloat imageScale;
// 生成的图片
@property (nonatomic, strong) UIImage *signImage;

// 初始化视图之后调用 准备画图
- (void)startDraw;
// 重置
- (void)resetDraw;
// 保存成图片
- (void)saveDraw;

@end

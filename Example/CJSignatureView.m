//
//  CJSignatureView.m
//  CJSignatureDome
//
//  Created by zxjk on 17/8/17.
//
//

#import "CJSignatureView.h"

@implementation CJSignatureView
{
    UIBezierPath *path;// 签名的线
    CGPoint previousPoint;// 上一个点
}
#pragma mark 获取两点中点
CGPoint midpoint(CGPoint p0, CGPoint p1) {
    return (CGPoint) {
        (p0.x + p1.x) / 2.0,
        (p0.y + p1.y) / 2.0
    };
}

#pragma mark 准备开始签名
- (void)startDraw
{
    // 背景色
    self.backgroundColor = [UIColor whiteColor];
    // 初始化 设置属性
    path = [UIBezierPath bezierPath];
    // 线宽
    path.lineWidth = _lineWidth ? _lineWidth : 1;
    // 线颜色
    if (_lineColor) {
        [_lineColor set];
    }
}
#pragma mark 画线刚开始，保存上一个点
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 获取点击点坐标
    UITouch * touch = touches.anyObject;
    CGPoint currentPoint = [touch locationInView:self];
    // 保存成上一点
    previousPoint = currentPoint;
    // 开始点移动到点击点
    [path moveToPoint:currentPoint];
}
#pragma mark 开始画线，连接上一个点和当前点
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 获取点击点坐标
    UITouch * touch = touches.anyObject;
    CGPoint currentPoint = [touch locationInView:self];
    
    // 获取两点中点
    CGPoint midPoint = midpoint(previousPoint, currentPoint);
    // 画曲线
    [path addQuadCurveToPoint:midPoint controlPoint:previousPoint];
    // 替换当前点为上一点
    previousPoint = currentPoint;
    // 画图
    [self setNeedsDisplay];
}
#pragma mark 系统画线方法
- (void)drawRect:(CGRect)rect
{
    [path stroke];
}
#pragma mark 重置path
- (void)resetDraw
{
    [self startDraw];
    [self setNeedsDisplay];
}
#pragma mark 保存成图片
- (void)saveDraw
{
    self.signImage = [self captureWithView:self];
    if (!_imageScale) {
        return;
    }
    // 这里控制范围，范围可以自己定
    if (_imageScale < 0.1) {
        _imageScale = 0.1;
    }
    if (_imageScale > 1) {
        _imageScale = 1;
    }
    if (_imageScale != 1) {
        [self scaleImage];
    }
    
}

#pragma mark 缩放图片
- (UIImage *)scaleImage
{
    // 用这个方法 画质会变渣
//    UIGraphicsBeginImageContext(CGSizeMake(_signImage.size.width * _imageScale, _signImage.size.height * _imageScale));
//    [_signImage drawInRect:CGRectMake(0, 0, _signImage.size.width * _imageScale, _signImage.size.height * _imageScale)];
//    self.signImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    // 判断机型
    if([[UIScreen mainScreen] scale] == 2.0){      // @2x
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(_signImage.size.width * _imageScale, _signImage.size.height * _imageScale), NO, 2.0);
    }else if([[UIScreen mainScreen] scale] == 3.0){ // @3x ( iPhone 6plus 、iPhone 6s plus)
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(_signImage.size.width * _imageScale, _signImage.size.height * _imageScale), NO, 3.0);
    }else{
        UIGraphicsBeginImageContext(CGSizeMake(_signImage.size.width * _imageScale, _signImage.size.height * _imageScale));
    }
    // 绘制改变大小的图片
    [_signImage drawInRect:CGRectMake(0, 0, _signImage.size.width * _imageScale, _signImage.size.height * _imageScale)];
    // 从当前context中创建一个改变大小后的图片
    _signImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    
    return self.signImage;
}

#pragma mark 截屏
- (UIImage *)captureWithView:(UIView *)view
{
    CGRect screenRect = [view bounds];
    UIGraphicsBeginImageContext(screenRect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}




@end

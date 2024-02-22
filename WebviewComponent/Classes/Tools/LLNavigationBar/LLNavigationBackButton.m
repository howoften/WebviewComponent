//
//  LLNavigationBackButton.m
//  LLNavigationBar
//
//  Created by liujiang on 2022/12/12.
//

#import "LLNavigationBackButton.h"

@interface LLNavigationBackButton ()
@property (nonatomic)CGSize intrinsicSize;
@property (nonatomic)CAShapeLayer *drawLayer;
@end
@implementation LLNavigationBackButton
const CGRect defaultRect = {{0, 0}, {25, 23}};
const CGRect negativeRect = {{0, 0}, {-111.222, -111.222}};
- (instancetype)init {
    return [self initWithFrame:negativeRect];
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (CGRectEqualToRect(frame, negativeRect)) {
        frame = defaultRect;
    }
    if (self = [super initWithFrame:frame]) {
        self.intrinsicSize = frame.size;
        [self initialState];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)initialState {
    _lineCap = kCALineCapSquare;
    _lineJoin = kCALineJoinMiter;
    _lineWidth = 2.5;
    _strokeColor = UIColor.systemBlueColor;
    _strokeAngle = 90;
    
    self.backgroundColor = UIColor.clearColor;
}
- (void)drawRect:(CGRect)rect {
    if (CGRectGetWidth(rect) < 1 || CGRectGetHeight(rect) < 1) {
        return [super drawRect:rect];
    }
    [_drawLayer removeFromSuperlayer];
    _drawLayer = [CAShapeLayer layer];
    _drawLayer.frame = rect;
    
    UIBezierPath *shape = [UIBezierPath bezierPath];
    [shape moveToPoint:CGPointMake(CGRectGetHeight(rect)/2*tan((90-self.strokeAngle/2)/180*M_PI), self.lineWidth)];
    [shape addLineToPoint:CGPointMake(self.lineWidth, CGRectGetHeight(rect)/2)];
    [shape addLineToPoint:CGPointMake(CGRectGetHeight(rect)/2*tan((90-self.strokeAngle/2)/180*M_PI), CGRectGetHeight(rect) - self.lineWidth)];
    _drawLayer.path = shape.CGPath;
    _drawLayer.strokeColor = self.strokeColor.CGColor;
    _drawLayer.fillColor = UIColor.clearColor.CGColor;
    _drawLayer.lineWidth = self.lineWidth;
    _drawLayer.lineCap = self.lineCap;
    _drawLayer.lineJoin = self.lineJoin;
    [self.layer insertSublayer:_drawLayer atIndex:0];
    
    
    
}
- (void)setFrame:(CGRect)frame {
    if (!CGSizeEqualToSize(frame.size, self.intrinsicSize)) {
        self.intrinsicSize = frame.size;
        [self invalidateIntrinsicContentSize];
    }
    [super setFrame:frame];
    
}
- (CGSize)intrinsicContentSize {
    return self.intrinsicSize;
}
@end

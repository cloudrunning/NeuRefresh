//
//  NeuRefreshHeader.m
//  SURefreshDemo
//
//  Created by caozhen@neusoft on 16/8/22.
//  Copyright © 2016年 KevinSu. All rights reserved.
//

#import "NeuRefreshHeader.h"
#import "UIView+SURefresh.h"
const CGFloat NeuRefreshHeaderHeight = 35.0;
const CGFloat NeuRefreshPointRadius = 5.0;

const CGFloat NeuRefreshPullLen     = 55.0;
const CGFloat NeuRefreshTranslatLen = 5.0;

#define topPointColor    [UIColor colorWithRed:90 / 255.0 green:200 / 255.0 blue:200 / 255.0 alpha:1.0].CGColor
#define leftPointColor   [UIColor colorWithRed:250 / 255.0 green:85 / 255.0 blue:78 / 255.0 alpha:1.0].CGColor
#define bottomPointColor [UIColor colorWithRed:92 / 255.0 green:201 / 255.0 blue:105 / 255.0 alpha:1.0].CGColor
#define rightPointColor  [UIColor colorWithRed:253 / 255.0 green:175 / 255.0 blue:75 / 255.0 alpha:1.0].CGColor

@interface NeuRefreshHeader ()

@property (nonatomic,weak) UIScrollView *scrollView;
@property (nonatomic,strong) CAShapeLayer *topPointLayer;
@property (nonatomic,strong) CAShapeLayer *bottomPointLayer;
@property (nonatomic,strong) CAShapeLayer *leftPointLayer;
@property (nonatomic,strong) CAShapeLayer *rightPointLayer;
@property (nonatomic,strong) CAShapeLayer *lineLayer;


@property (nonatomic,assign) CGFloat progress;
@property (nonatomic,assign,getter=isRefreshing) BOOL refreshing;


@end
@implementation NeuRefreshHeader

- (instancetype)init {
    
    self = [super initWithFrame:CGRectMake(0, 0, NeuRefreshHeaderHeight, NeuRefreshHeaderHeight)];
    if (self) {
        [self initLayers];
    }
    return self;
}

- (void)initLayers {
    
    CGFloat halfH = NeuRefreshHeaderHeight * 0.5;
    CGFloat pRadius = NeuRefreshPointRadius;
    
    CGPoint topPoint     =   CGPointMake(halfH, pRadius);
    CGPoint leftPoint    =   CGPointMake(pRadius, halfH);
    CGPoint bottomPoint  =   CGPointMake(halfH, halfH - pRadius);
    CGPoint rightPoint   =   CGPointMake(halfH - pRadius, halfH);
    
    // 创建4个点
    self.topPointLayer      = [self layerWithPoint:topPoint colorRef:topPointColor];
    self.topPointLayer.hidden = NO;
    self.topPointLayer.opacity = 0.0f;
    [self.layer addSublayer:self.topPointLayer];
    
    self.leftPointLayer     = [self layerWithPoint:leftPoint colorRef:topPointColor];
    [self.layer addSublayer:self.topPointLayer];
    
    self.bottomPointLayer   = [self layerWithPoint:bottomPoint colorRef:topPointColor];
    [self.layer addSublayer:self.topPointLayer];
    
    self.rightPointLayer    = [self layerWithPoint:rightPoint colorRef:topPointColor];
    [self.layer addSublayer:self.topPointLayer];
    
    
    // 连接4个点的路径
    self.lineLayer = [self lineLayerWithKeyPoints:@[[NSValue valueWithCGPoint:topPoint],[NSValue valueWithCGPoint:leftPoint],[NSValue valueWithCGPoint:bottomPoint],[NSValue valueWithCGPoint:rightPoint]]];
    [self.layer insertSublayer:self.lineLayer above:self.topPointLayer];
}

- (CAShapeLayer *)layerWithPoint:(CGPoint)point colorRef:(CGColorRef)colorRef {
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    CGFloat radius = NeuRefreshPointRadius;
    layer.fillColor = colorRef;
    layer.path = [self pointPath];
    layer.hidden = YES;
    layer.frame = CGRectMake(point.x - radius, point.y - radius, radius * 2, radius * 2);
    return layer;
}

- (CGPathRef)pointPath {
    
    CGFloat radius = NeuRefreshPointRadius;
    return [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius) radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES].CGPath;
}

// 点的连线
- (CAShapeLayer *)lineLayerWithKeyPoints:(NSArray*)points {
    
    CAShapeLayer *line = [CAShapeLayer layer];
    line.frame = self.bounds;
    line.lineWidth = NeuRefreshPointRadius * 2;
    line.lineCap = kCALineCapRound;
    line.lineJoin = kCALineJoinRound;
    line.fillColor = topPointColor;
    line.strokeColor = topPointColor;
    
    // 路径
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (int i = 0; i<points.count; i++) {
        CGPoint point = [points[i] CGPointValue];
        [path moveToPoint:point];
        [path addLineToPoint:point];
    }
    
    line.path = path.CGPath;
    
    line.strokeStart = 0.f;
    line.strokeEnd   = 0.f;
    return line;
}

#pragma mark ---- override
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview) {
        self.scrollView = (UIScrollView *)newSuperview;
        self.center = CGPointMake(self.scrollView.centerX, self.scrollView.centerY);
        [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }else {
        [self.superview removeObserver:self forKeyPath:@"contentOffset"];
    }
}

#pragma mark ---- KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        self.progress = - self.scrollView.contentOffset.y;
    }
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    if (!self.isRefreshing) {
        // 超过渐变范围
        if (progress >= NeuRefreshPullLen) {
            self.y = - (NeuRefreshPullLen - (NeuRefreshPullLen - NeuRefreshHeaderHeight)) * 0.5;
        }else {
            if (progress < self.h) {
                self.y = -progress;
            }else {
                self.y = - (self.h + (progress - self.h) * 0.5);
            }
        }
        [self setLineLayerStrokeWithProgress:progress];
    }
    
    if (progress > NeuRefreshPullLen && !self.refreshing && !self.scrollView.dragging) {
        [self startAni];
        if (self.handle) {
            self.handle();
        }
    }
}
/**
 *  渐变的过程中绘制路径
 *
 *  @param progress 偏移的距离 ［0,RefreshPullLen］
 */
- (void)setLineLayerStrokeWithProgress:(CGFloat)progress{

}

/**
 *  根据绘制的第几个点，调整4个点的状态
 *
 *  @param index
 */
- (void)adjustPointsStatusWithIndex:(NSInteger)index {
    
    self.leftPointLayer.hidden = !(index > 1);
//    self.bottomPointLayer.hidden =

}

- (void)startAni {

}


@end




















//
//  DGLHistogramView.h
//  BezierHistogram
//
//  Created by DonLee on 2019/5/14.
//  Copyright © 2019 DonLee. All rights reserved.
//
/*
 UIBezierPath ：画贝塞尔曲线的path类
 UIBezierPath定义 ： 贝赛尔曲线的每一个顶点都有两个控制点，用于控制在该顶点两侧的曲线的弧度。
 曲线的定义有四个点：起始点、终止点（也称锚点）以及两个相互分离的中间点。
 滑动两个中间点，贝塞尔曲线的形状会发生变化。
 UIBezierPath ：对象是CGPathRef数据类型的封装，可以方便的让我们画出 矩形 、 椭圆 或者 直线和曲线的组合形状
 
 最基本的使用方法是：
 //设置描绘的起点
 - (void)moveToPoint:(CGPoint)point;
 
 //画直线
 - (void)addLineToPoint:(CGPoint)point;
 
 //画曲线
 (1)绘制二次贝塞尔曲线   分别对应终点和一个控制点
 - (void)addQuadCurveToPoint:(CGPoint)endPoint controlPoint:(CGPoint)controlPoint
 
 (1)绘制三次贝塞尔曲线   分别对应终点和两个控制点
 - (void)addCurveToPoint:(CGPoint)endPoint controlPoint1:(CGPoint)controlPoint1 controlPoint2:(CGPoint)controlPoint2;
 
 //画圆弧
 - (void)addArcWithCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clockwise
 
 使用贝塞尔曲线的基本步骤是：
 (1）创建一个Bezier path对象。
 （2）使用方法moveToPoint:去设置初始线段的起点。
 （3）添加line或者curve去定义一个或者多个subpaths。
 （4）改变UIBezierPath对象跟绘图相关的属性。
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DGLHistogramModel : NSObject
@property (nonatomic, copy) NSString *knownStr; //已知
@property (nonatomic, copy) NSString *forecastStr; //预测
@property (nonatomic, copy) NSString *unitStr; //单位
@property (nonatomic, strong) NSArray *dataSourceArr; //柱状图数据源数据
@end

@interface DGLHistogramView : UIView

- (void)updateDataWithHistogramMode:(DGLHistogramModel *)model;
@end

NS_ASSUME_NONNULL_END

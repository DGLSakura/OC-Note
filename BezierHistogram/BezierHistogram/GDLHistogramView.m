//
//  GDLHistogramView.m
//  BezierHistogram
//
//  Created by DonLee on 2019/5/8.
//  Copyright © 2019 DonLee. All rights reserved.
//

#import "GDLHistogramView.h"

#import "Masonry.h"


#define kWidthScale(x)    ((x)*_frameRect.size.width/375.0f)
#define kHeightScale(x)   ((x)*_frameRect.size.height/228.0f)

#define ORIGIN_X           kWidthScale(59)  //原点x坐标
#define ORIGIN_Y           _frameRect.size.height -kHeightScale(32)  //原点y坐标
#define COORDINATE_X_LENGTH kWidthScale(278)  //X轴长度
#define Y_EVERY_INTERVAL     (_frameRect.size.height -kHeightScale(101))/4  //y轴每一个值的间隔数

#define LabelColor  [UIColor colorWithRed:62/255.0 green:62/255.0 blue:62/255.0 alpha:1/1.0]
#define lineColor  [UIColor colorWithRed:226/255.0 green:226/255.0 blue:226/255.0 alpha:1/1.0]
#define knowColor  [UIColor colorWithRed:86/255.0 green:133/255.0 blue:228/255.0 alpha:1/1.0]
#define forecastColor [UIColor colorWithRed:187/255.0 green:206/255.0 blue:244/255.0 alpha:1/1.0]

static CGRect _frameRect;

@interface GDLHistogramView()

//已知
@property (nonatomic, nullable, strong) UILabel *knownLabel;
//预测
@property (nonatomic, nullable, strong) UILabel *forecastLabel;

@property (nullable, strong) NSMutableArray<CAShapeLayer*> *bezierArray;//需要清除的贝塞尔曲线
@property (nullable, strong) NSMutableArray<UILabel*> *yearArray; //需要清除的年份label
@end

@implementation GDLHistogramView

//初始化画布
- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor yellowColor];
        _frameRect = frame;
        
        [self setLabelUI];
        //坐标轴
        [self drawCoordinatesLine];
        _bezierArray = [NSMutableArray array];
        _yearArray  = [NSMutableArray array];
    }
    return self;
    
}

- (void)setLabelUI {
    UIView *forecastView = [UIView new];
    forecastView.backgroundColor = forecastColor;
    [self addSubview:forecastView];
    [forecastView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(kWidthScale(190));
        make.top.mas_equalTo(self).offset(kHeightScale(18));
        make.width.and.height.mas_equalTo(kHeightScale(6.0));
    }];
    [self addSubview:self.forecastLabel];
    [self.forecastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(forecastView.mas_right).offset(kWidthScale(8));
        make.top.mas_equalTo(self).offset(kHeightScale(12));
    }];
    [self addSubview:self.knownLabel];
    [self.knownLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(forecastView.mas_left).offset(kWidthScale(-32));
        make.top.mas_equalTo(self).offset(kHeightScale(12));
    }];
    UIView *knowView = [UIView new];
    knowView.backgroundColor = knowColor;
    [self addSubview:knowView];
    [knowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(kHeightScale(18));
        make.right.mas_equalTo(self.knownLabel.mas_left).offset(-8);
        make.width.and.height.mas_equalTo(kHeightScale(6.0));
    }];
}

/**
 *  画坐标轴
 */
-(void)drawCoordinatesLine {
    UIBezierPath *path = [UIBezierPath bezierPath];
    //X轴
    [path moveToPoint:CGPointMake(ORIGIN_X, ORIGIN_Y)];
    [path addLineToPoint:CGPointMake(ORIGIN_X + COORDINATE_X_LENGTH, ORIGIN_Y)];
    //Y轴
    [path moveToPoint:CGPointMake(ORIGIN_X, ORIGIN_Y)];
    [path addLineToPoint:CGPointMake(ORIGIN_X, ORIGIN_Y - kHeightScale(132))];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.strokeColor = lineColor.CGColor;
    shapeLayer.fillColor = lineColor.CGColor;
    shapeLayer.borderWidth = 1.0;
    [self.layer addSublayer:shapeLayer];
    
    for (NSInteger i = 0; i < 5; i ++) {
        //Y轴索引格文字
        UILabel *scaleLabel = [UILabel new];
        scaleLabel.tag = 100 + i;
        scaleLabel.font = [UIFont systemFontOfSize:kWidthScale(10)];
        scaleLabel.textColor = LabelColor;
        scaleLabel.text = [NSString stringWithFormat:@"%ld",500*i];
        [self addSubview:scaleLabel];
        float floatY = ORIGIN_Y- kWidthScale(5) - Y_EVERY_INTERVAL*i;
        [scaleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.mas_left).offset(kWidthScale(48));
            make.top.mas_equalTo(self).offset(floatY);
        }];
        if (i == 4) {
            break;
        }
        //Y轴虚线
        CAShapeLayer *imaginaryLine = [CAShapeLayer layer];
        // 设置虚线颜色
        imaginaryLine.strokeColor = lineColor.CGColor;
        //设置虚线的宽度
        imaginaryLine.lineWidth = 1;
        imaginaryLine.lineJoin = kCALineJoinRound;
        // 1=线的宽度 1=每条线的间距
        imaginaryLine.lineDashPattern = @[@(3),@(2)];
        //setup the path
        CGMutablePathRef linePath = CGPathCreateMutable();
        CGPathMoveToPoint(linePath, NULL, ORIGIN_X, ORIGIN_Y - Y_EVERY_INTERVAL *(i+1));
        CGPathAddLineToPoint(linePath, NULL, ORIGIN_X+COORDINATE_X_LENGTH, ORIGIN_Y - Y_EVERY_INTERVAL *(i+1));
        imaginaryLine.path = linePath;
        CGPathRelease(linePath);
        [self.layer addSublayer:imaginaryLine];
    }
    
    UILabel *unitLabel = [UILabel new];
    unitLabel.text = @"亿元";
    unitLabel.font = [UIFont systemFontOfSize:kWidthScale(10)];
    unitLabel.textColor = LabelColor;
    [self addSubview:unitLabel];
    [unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).offset(-kHeightScale(174));
        make.centerX.mas_equalTo(self.mas_left).offset(ORIGIN_X);
    }];
}


- (void)configDataWithTargets:(NSArray *)targets {
    if (targets.count == 0) {
        return;
    }
    for (CAShapeLayer *shapeLayer in _bezierArray) {
        [shapeLayer removeFromSuperlayer];
    }
    for (UILabel *yearLabel in _yearArray) {
        [yearLabel removeFromSuperview];
    }
    //获取最小刻度数值
    CGFloat maxValue = [[targets valueForKeyPath:@"@max.floatValue"] floatValue];
    NSInteger scaleValue = [self getScaleForCoordinateXWithMaxValue:maxValue];
    for (NSInteger i = 0; i < 5; i++) {
        UILabel *scaleLabel = (UILabel *)[self viewWithTag:100+i];
        scaleLabel.text = [NSString stringWithFormat:@"%ld",scaleValue*i];
    }
    //获取当前年份
    NSDateFormatter *dateformatter = [NSDateFormatter new];
    [dateformatter setDateFormat:@"yyyy"];
    NSInteger thisYearValue=[dateformatter stringFromDate:[NSDate date]].integerValue;
    //获得圆柱形宽度及间距
    CGFloat HistogramWidth = COORDINATE_X_LENGTH/(2*targets.count+1);
    for (NSInteger i = 0; i < targets.count; i ++) {
        //添加柱状图
        CGFloat HeightValue = [targets[i] floatValue]*Y_EVERY_INTERVAL/scaleValue;
        CGFloat histogramX = ORIGIN_X + HistogramWidth + 2*HistogramWidth*i;
        CGFloat histogramY = ORIGIN_Y - HeightValue;
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(histogramX, histogramY,HistogramWidth, HeightValue)];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        shapeLayer.strokeColor = [UIColor clearColor].CGColor;
        if (i > targets.count-3) {
            shapeLayer.fillColor = forecastColor.CGColor;
        }else{
            shapeLayer.fillColor = knowColor.CGColor;
        }
        
        shapeLayer.borderWidth = 2.0;
        [self.layer addSublayer:shapeLayer];
        [_bezierArray addObject:shapeLayer];
        
        //3.添加文字
        UILabel *yearLabel = [UILabel new];
        yearLabel.font = [UIFont systemFontOfSize:kWidthScale(10)];
        yearLabel.text = [NSString stringWithFormat:@"%ld",thisYearValue-4+i];
        yearLabel.textColor = LabelColor;
        [self addSubview:yearLabel];
        [yearLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self).offset(ORIGIN_Y+kWidthScale(8));
            make.centerX.mas_equalTo(self.mas_left).offset(histogramX+HistogramWidth/2);
        }];
        [_yearArray addObject:yearLabel];
    }
    
}

- (void)setKnownString:(NSString *)knownString {
    self.knownLabel.text = knownString;
}

- (void)setForecastString:(NSString *)forecastString {
    self.forecastLabel.text = forecastString;
}

/**
 根据最大值算出Y坐标刻度值
 
 @param maxValue 获得数据最大值
 @return 返回Y坐标刻度值
 */
- (NSInteger)getScaleForCoordinateXWithMaxValue:(CGFloat)maxValue {
    NSInteger scaleValue = 0;
    NSInteger value = maxValue/4;
    NSInteger digit = 1;
    while (value >= 10) {
        value /= 10;
        digit *= 10;
    }
    scaleValue = (value + 1)*digit;
    return scaleValue;
}

#pragma mark ----- lazy load -----

- (UILabel *)knownLabel{
    if (!_knownLabel) {
        _knownLabel = [UILabel new];
        _knownLabel.font = [UIFont systemFontOfSize:kWidthScale(13)];
        _knownLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];
    }
    return _knownLabel;
}
- (UILabel *)forecastLabel{
    if (!_forecastLabel) {
        _forecastLabel = [UILabel new];
        _forecastLabel.font = [UIFont systemFontOfSize:kWidthScale(13)];
        _forecastLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];
    }
    return _forecastLabel;
}


@end

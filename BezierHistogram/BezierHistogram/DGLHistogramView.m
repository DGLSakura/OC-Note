//
//  DGLHistogramView.m
//  BezierHistogram
//
//  Created by DonLee on 2019/5/14.
//  Copyright © 2019 DonLee. All rights reserved.
//

#import "DGLHistogramView.h"
#import "Masonry.h"

#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT    [UIScreen mainScreen].bounds.size.height
#define kIphone6Scale(x)   ((x)*MIN(SCREEN_WIDTH,SCREEN_HEIGHT)/375.0f)
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue &0xFF0000) >> 16))/255.0 green:((float)((rgbValue &0xFF00) >> 8))/255.0 blue:((float)(rgbValue &0xFF))/255.0 alpha:1]

#define ORIGIN_X            kIphone6Scale(59)  //原点x坐标
#define TOP_Y               kIphone6Scale(64) //Y轴顶点距离上界面距离
#define COORDINATE_X_LENGTH kIphone6Scale(280)  //X轴长度
#define INTERVAL_Y          kIphone6Scale(5)    //Y轴间距

#define LabelColor  [HTColor colorWithHex:0x3E3E3E]
#define LineColor  [HTColor colorWithHex:0xC3C3C3]
#define KnownColor  [HTColor colorWithHex:0x5685E4]
#define ForecastColor [HTColor colorWithHex:0xBBCEF4]

static const NSInteger ImaginaryCount = 4; //虚线的数量

@implementation DGLHistogramModel
@end

@interface DGLHistogramView()
{
    CGFloat _coordinateY; //Y轴长度
    CGFloat _originY; //原点Y轴坐标
}
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, strong) UIView *knownView;
@property (nonatomic, strong) UIView *forecastView;
@property (nonatomic, strong) UILabel *knownLabel; //已知
@property (nonatomic, strong) UILabel *forecastLabel; //预测
@property (nonatomic, strong) UILabel *unitLabel; //单位
@property (nonatomic, strong) CAShapeLayer *coordinateLayer; //坐标轴
@property (nonatomic, strong) CAShapeLayer *imaginaryLayer; //虚线
@property (nonatomic, strong) NSMutableArray<CAShapeLayer*> *layerArr; //需要清除的ShapeLayer
@property (nonatomic, strong) NSMutableArray<UILabel*> *labelArr; //需要清除的label
@end

@implementation DGLHistogramView

#pragma mark - public
- (void)updateDataWithHistogramMode:(DGLHistogramModel *)model {
    self.knownLabel.text = model.knownStr;
    self.forecastLabel.text = model.forecastStr;
    self.unitLabel.text = model.unitStr;
    if (!model.dataSourceArr || model.dataSourceArr.count == 0) {
        return;
    }
    self.dataArr = [model.dataSourceArr copy];
    [self removeSubViewAndLayer];
    [self stroke];
}

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _coordinateY = CGRectGetHeight(self.frame) - TOP_Y - kIphone6Scale(40);
        [self setViewUI];
         [self setConstraints];
        [self drawDefaultCoordinatesLines];
    }
    return self;
}
- (void)setViewUI {
    [self addSubview:self.knownView];
    [self addSubview:self.knownLabel];
    [self addSubview:self.forecastView];
    [self addSubview:self.forecastLabel];
    [self addSubview:self.unitLabel];
}
- (void)setConstraints {
    [self.forecastView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(kIphone6Scale(190));
        make.top.mas_equalTo(self).offset(kIphone6Scale(18));
        make.width.and.height.mas_equalTo(kIphone6Scale(6.0));
    }];
    [self.forecastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.forecastView.mas_right).offset(kIphone6Scale(8));
        make.top.mas_equalTo(self).offset(kIphone6Scale(12));
    }];
    [self.knownLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.forecastView.mas_left).offset(-kIphone6Scale(32));
        make.top.mas_equalTo(self).offset(kIphone6Scale(12));
    }];
    [self.knownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(kIphone6Scale(18));
        make.right.mas_equalTo(self.knownLabel.mas_left).offset(-8);
        make.width.and.height.mas_equalTo(kIphone6Scale(6.0));
    }];
    [self.unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(kIphone6Scale(42));
        make.centerX.mas_equalTo(self.mas_left).offset(ORIGIN_X);
    }];
}

#pragma mark - private
- (void)stroke {
    NSArray *incomeArr = [self.dataArr valueForKeyPath:@"income"];
    CGFloat maxValue = [[incomeArr valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat minValue = [[incomeArr valueForKeyPath:@"@min.floatValue"] floatValue];
    CGFloat scaleValue = [self getScaleForCoordinateXWithMaxValue:maxValue minValue:minValue];
    [self drawCoordinatesLineWithMaxValue:maxValue minValue:minValue scaleValue:scaleValue];
    [self addScaleLabelWithMaxValue:maxValue minValue:minValue];
    //获取年份数组
    NSArray *yearArray = [self.dataArr valueForKeyPath:@"year"];
    //获得圆柱形宽度及间距
    CGFloat HistogramWidth = COORDINATE_X_LENGTH/(2*self.dataArr.count+1);
    for (NSInteger i = 0; i < self.dataArr.count; i ++) {
        //添加柱状图
        CGFloat HeightValue = [incomeArr[i] floatValue]*scaleValue;
        CGFloat histogramX = ORIGIN_X + HistogramWidth + 2*HistogramWidth*i;
        CGFloat histogramY = _originY - HeightValue;
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(histogramX, histogramY, HistogramWidth, HeightValue)];
        CAShapeLayer *shapeLayer = [self getHistogramLayer];
        shapeLayer.path = path.CGPath;
        if (i > self.dataArr.count-3) {
            shapeLayer.fillColor = UIColorFromRGB(0xBBCEF4).CGColor;
        }else{
            shapeLayer.fillColor = UIColorFromRGB(0x5685E4).CGColor;
        }
        [self.layerArr addObject:shapeLayer];
        //3.添加文字
        UILabel *yearLabel = [self getTextLabel];
        yearLabel.text = [NSString stringWithFormat:@"%@",yearArray[i]];
        [yearLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self).offset(kIphone6Scale(-18));
            make.centerX.mas_equalTo(self.mas_left).offset(histogramX+HistogramWidth/2);
        }];
        [self.labelArr addObject:yearLabel];
    }
}
- (void)drawCoordinatesLineWithMaxValue:(CGFloat)maxValue minValue:(CGFloat)minValue scaleValue:(CGFloat)scaleValue {
    //X轴
    if (minValue >= 0) {//当数据全为正数
        return;
    }
    else if (maxValue <= 0){//当数据全为负数
        _originY = TOP_Y;
    }
    else{//当数据有正有负
        _originY = TOP_Y + INTERVAL_Y + maxValue *scaleValue;
    }
    //坐标轴
    UIBezierPath *coordinatePath = [UIBezierPath bezierPath];
    [coordinatePath moveToPoint:CGPointMake(ORIGIN_X, _originY)];
    [coordinatePath addLineToPoint:CGPointMake(ORIGIN_X+COORDINATE_X_LENGTH, _originY)];
    //Y轴
    [coordinatePath moveToPoint:CGPointMake(ORIGIN_X, TOP_Y)];
    [coordinatePath addLineToPoint:CGPointMake(ORIGIN_X, TOP_Y+_coordinateY)];
    self.coordinateLayer.path = coordinatePath.CGPath;
    //虚线
    UIBezierPath *imaginaryPath = [UIBezierPath bezierPath];
    for (NSInteger i = 0; i < ImaginaryCount; i ++) {
        CGFloat imaginaryY = TOP_Y+INTERVAL_Y+(_coordinateY-INTERVAL_Y)/(ImaginaryCount)*i;;
        if (maxValue <= 0) {
            imaginaryY = TOP_Y+(_coordinateY-INTERVAL_Y)/(ImaginaryCount)*(i+1);
        }else if (maxValue > 0 && minValue < 0) {
            imaginaryY = TOP_Y+INTERVAL_Y+(_coordinateY-2*INTERVAL_Y)/(ImaginaryCount-1)*i;
        }
        [imaginaryPath moveToPoint:CGPointMake(ORIGIN_X, imaginaryY)];
        [imaginaryPath addLineToPoint:CGPointMake(ORIGIN_X+COORDINATE_X_LENGTH, imaginaryY)];
    }
    self.imaginaryLayer.path = imaginaryPath.CGPath;
}
- (void)addScaleLabelWithMaxValue:(CGFloat)maxValue minValue:(CGFloat)minValue {
    for (NSInteger i = 0; i < ImaginaryCount+1; i ++) {
        UILabel *scaleLabel = [self getTextLabel];
        scaleLabel.textAlignment = NSTextAlignmentRight;
        scaleLabel.adjustsFontSizeToFitWidth = YES;
        NSString *unitString = @"0";
        if (minValue >= 0) {//当数据全为正数
            if (i != ImaginaryCount) {
                unitString = [NSString stringWithFormat:@"%.2f",maxValue/ImaginaryCount*(ImaginaryCount-i)];
            }
        }
        else if (maxValue <= 0){//当数据全为负数
            if (i != 0) {
                unitString = [NSString stringWithFormat:@"%.2f",minValue/ImaginaryCount*i];
            }
        }
        else{//当数据有正有负
            if (i == ImaginaryCount) {
                break;
            }
            unitString = [NSString stringWithFormat:@"%.2f",maxValue-(maxValue-minValue)/(ImaginaryCount-1)*i];
        }
        scaleLabel.text = [self calculateCanBillionUnit:unitString];
        float floatY = TOP_Y+INTERVAL_Y+(_coordinateY-INTERVAL_Y)/ImaginaryCount*i;
        if (maxValue <= 0) {
            floatY = TOP_Y+(_coordinateY-INTERVAL_Y)/ImaginaryCount*i;
        }else if (maxValue > 0 && minValue < 0) {
            floatY = TOP_Y+INTERVAL_Y+(_coordinateY-2*INTERVAL_Y)/(ImaginaryCount-1)*i;
        }
        [scaleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.mas_left).offset(kIphone6Scale(48));
            make.left.mas_equalTo(self).offset(kIphone6Scale(2));
            make.centerY.mas_equalTo(self.mas_top).offset(floatY);
        }];
        [self.labelArr addObject:scaleLabel];
    }
}
//绘制默认坐标轴
- (void)drawDefaultCoordinatesLines {
    //坐标轴
    UIBezierPath * coordinatePath = [UIBezierPath bezierPath];
    _originY = TOP_Y + _coordinateY;
    //X轴
    [coordinatePath moveToPoint:CGPointMake(ORIGIN_X, _originY)];
    [coordinatePath addLineToPoint:CGPointMake(ORIGIN_X+COORDINATE_X_LENGTH, _originY)];
    //Y轴
    [coordinatePath moveToPoint:CGPointMake(ORIGIN_X, TOP_Y)];
    [coordinatePath addLineToPoint:CGPointMake(ORIGIN_X, TOP_Y+_coordinateY)];
    self.coordinateLayer.path = coordinatePath.CGPath;
    //虚线
    UIBezierPath *imaginaryPath = [UIBezierPath bezierPath];
    for (NSInteger i = 0; i < ImaginaryCount; i ++) {
        CGFloat imaginaryY = TOP_Y+INTERVAL_Y+(_coordinateY-INTERVAL_Y)/(ImaginaryCount)*i;
        [imaginaryPath moveToPoint:CGPointMake(ORIGIN_X, imaginaryY)];
        [imaginaryPath addLineToPoint:CGPointMake(ORIGIN_X+COORDINATE_X_LENGTH, imaginaryY)];
    }
    self.imaginaryLayer.path = imaginaryPath.CGPath;
}

- (CGFloat)getScaleForCoordinateXWithMaxValue:(CGFloat)maxValue minValue:(CGFloat)minValue {
    CGFloat scaleValue = 0;
    if (minValue >= 0) {//当数据全为正数
        scaleValue = (_coordinateY-INTERVAL_Y) /maxValue;
    }
    else if (maxValue <= 0){//当数据全为负数
        scaleValue = - (_coordinateY-INTERVAL_Y) /minValue;
    }
    else{//当数据有正有负
        scaleValue = (_coordinateY-2*INTERVAL_Y) /(maxValue-minValue);
    }
    return scaleValue;
}

- (NSString *)calculateCanBillionUnit:(NSString*)string {
    if (!string) {
        return @"";
    }
    NSString *valueString = [string copy];
    NSString *unitString = @"";
    CGFloat floatValue = [string floatValue];
    if (floatValue >= 10000 || floatValue <= -10000) {
        if (floatValue >= 100000000 || floatValue <= -100000000) {
            unitString = @"亿";
            floatValue = floatValue / 100000000;
        }else{
            unitString = @"万";
            floatValue = floatValue / 10000;
        }
        NSNumber *number = @(floatValue) ;
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.roundingMode = NSNumberFormatterRoundFloor;
        formatter.maximumIntegerDigits = 3;
        formatter.maximumFractionDigits = 2;
        formatter.minimumFractionDigits = 2;
        valueString = [formatter stringFromNumber:number];
    }
    
    return [NSString stringWithFormat:@"%@%@",valueString,unitString]; ;
}

- (void)removeSubViewAndLayer {
    [self.labelArr enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.labelArr removeAllObjects];
    [self.layerArr enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperlayer];
    }];
    [self.layerArr removeAllObjects];
}
#pragma mark - lazy load
- (UILabel *)getTextLabel {
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:kIphone6Scale(10)];
    label.textColor = UIColorFromRGB(0x3E3E3E);
    [self addSubview:label];
    return label;
}
- (CAShapeLayer *)getHistogramLayer {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = [UIColor clearColor].CGColor;
    shapeLayer.borderWidth = 1.0;
    [self.layer addSublayer:shapeLayer];
    return shapeLayer;
}
- (UIView *)knownView {
    if (!_knownView) {
        _knownView = [UIView new];
        _knownView.backgroundColor = UIColorFromRGB(0x5685E4);
    }
    return _knownView;
}
- (UIView *)forecastView {
    if (!_forecastView) {
        _forecastView = [UIView new];
        _forecastView.backgroundColor = UIColorFromRGB(0xBBCEF4);
    }
    return _forecastView;
}
- (UILabel *)knownLabel {
    if (!_knownLabel) {
        _knownLabel = [UILabel new];
        _knownLabel.font = [UIFont systemFontOfSize:kIphone6Scale(13)];
        _knownLabel.textColor = UIColorFromRGB(0x999999);
    }
    return _knownLabel;
}
- (UILabel *)forecastLabel {
    if (!_forecastLabel) {
        _forecastLabel = [UILabel new];
        _forecastLabel.font = [UIFont systemFontOfSize:kIphone6Scale(13)];
        _forecastLabel.textColor = UIColorFromRGB(0x999999);
    }
    return _forecastLabel;
}
- (UILabel *)unitLabel {
    if (!_unitLabel) {
        _unitLabel = [UILabel new];
        _unitLabel.font = [UIFont systemFontOfSize:kIphone6Scale(10)];
        _unitLabel.textColor = UIColorFromRGB(0x3E3E3E);
    }
    return _unitLabel;
}
- (CAShapeLayer *)coordinateLayer {
    if (!_coordinateLayer) {
        _coordinateLayer = [CAShapeLayer layer];
        _coordinateLayer.strokeColor = UIColorFromRGB(0xC3C3C3).CGColor;
        _coordinateLayer.lineWidth = 0.5;
        [self.layer addSublayer:_coordinateLayer];
    }
    return _coordinateLayer;
}
- (CAShapeLayer *)imaginaryLayer {
    if (!_imaginaryLayer) {
        _imaginaryLayer = [CAShapeLayer layer];
        _imaginaryLayer.strokeColor = UIColorFromRGB(0xE9E9E9).CGColor;
        _imaginaryLayer.lineWidth = 0.5;
        _imaginaryLayer.lineJoin = kCALineCapRound;
        _imaginaryLayer.lineDashPattern = @[@(3),@(2)];
        [self.layer addSublayer:_imaginaryLayer];
    }
    return _imaginaryLayer;
}
- (NSMutableArray *)layerArr {
    if (!_layerArr) {
        _layerArr = [NSMutableArray new];
    }
    return _layerArr;
}
- (NSMutableArray *)labelArr {
    if (!_labelArr) {
        _labelArr = [NSMutableArray new];
    }
    return _labelArr;
}
@end

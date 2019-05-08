//
//  ViewController.m
//  BezierHistogram
//
//  Created by DonLee on 2019/5/8.
//  Copyright © 2019 DonLee. All rights reserved.
//

#import "ViewController.h"
#import "GDLHistogramView.h"

#define SCREEN_W  [UIScreen mainScreen].bounds.size.width

@interface ViewController ()

@property (nonatomic,strong) GDLHistogramView *histogramView;
@property (strong,nonatomic) NSMutableArray *targets;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 40, 100, 100);
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(clearHistogram) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    _histogramView = [[GDLHistogramView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, 228)];
    _histogramView.center = self.view.center;
    _histogramView.knownString = @"收入";
    _histogramView.forecastString = @"预计收入";
    [_histogramView configDataWithTargets:self.targets];
    [self.view addSubview:_histogramView];
}

-(NSMutableArray *)targets{
    if (!_targets) {
        _targets = [NSMutableArray arrayWithArray:@[@550,@1040,@900,@1200,@1350,@1890]];
    }
    return _targets;
}

- (void)clearHistogram {
    _targets = [NSMutableArray arrayWithArray:@[@1420,@1000,@1350,@1020,@500]];
    _histogramView.knownString = @"每股收益";
    _histogramView.forecastString = @"预测每股收益";
    [_histogramView configDataWithTargets:self.targets];
    
}


@end

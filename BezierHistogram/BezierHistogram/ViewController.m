//
//  ViewController.m
//  BezierHistogram
//
//  Created by DonLee on 2019/5/8.
//  Copyright © 2019 DonLee. All rights reserved.
//

#import "ViewController.h"
#import "DGLHistogramView.h"
#import "Masonry.h"
#define SCREEN_W  [UIScreen mainScreen].bounds.size.width

@interface ViewController ()

@property (nonatomic,strong) DGLHistogramView *histogramView;
@property (strong,nonatomic) NSMutableArray *targets;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 40, 50, 50);
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(clearHistogram) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    DGLHistogramModel *model = [DGLHistogramModel new];
    model.knownStr = @"收入";
    model.forecastStr = @"预计收入";
    model.unitStr = @"USA";
    model.dataSourceArr = self.targets;
    _histogramView = [[DGLHistogramView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, 228)];
    _histogramView.center = self.view.center;
    [self.view addSubview:_histogramView];
    [_histogramView updateDataWithHistogramMode:model];
}

-(NSMutableArray *)targets{
    if (!_targets) {
        _targets = [NSMutableArray arrayWithArray:@[
                                                    @{@"income":@"100",@"year":@"2010"},
                                                    @{@"income":@"300",@"year":@"2012"},
                                                    @{@"income":@"400",@"year":@"2013"},
                                                    @{@"income":@"200",@"year":@"2014"},
                                                    @{@"income":@"800",@"year":@"2015"},
                                                    @{@"income":@"250",@"year":@"2016"},
                                                    @{@"income":@"850",@"year":@"2017"},
                                                    @{@"income":@"1000",@"year":@"2018"},
                                                    @{@"income":@"500",@"year":@"2019"},
                                                    @{@"income":@"750",@"year":@"2020"}
                                                    ]];
    }
    return _targets;
}

- (void)clearHistogram {
    _targets = [NSMutableArray arrayWithArray:@[
                                                @{@"income":@"100",@"year":@"2010"},
                                                @{@"income":@"-300",@"year":@"2012"},
                                                @{@"income":@"400",@"year":@"2013"},
                                                @{@"income":@"200",@"year":@"2014"},
                                                @{@"income":@"-800",@"year":@"2015"},
                                                @{@"income":@"250",@"year":@"2016"},
                                                @{@"income":@"-50",@"year":@"2017"},
                                                @{@"income":@"100",@"year":@"2018"},
                                                @{@"income":@"500",@"year":@"2019"},
                                                @{@"income":@"-250",@"year":@"2020"}
                                                ]];
    DGLHistogramModel *model = [DGLHistogramModel new];
    model.knownStr = @"每股收入";
    model.forecastStr = @"预计每股收入";
    model.unitStr = @"RMB";
    model.dataSourceArr = _targets;
    [_histogramView updateDataWithHistogramMode:model];
}


@end

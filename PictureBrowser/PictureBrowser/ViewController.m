//
//  ViewController.m
//  PictureBrowser
//
//  Created by DonLee on 2019/4/25.
//  Copyright © 2019 DonLee. All rights reserved.
//

#import "ViewController.h"
#import "DGLPictureView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *pictureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    pictureBtn.center = self.view.center;
    pictureBtn.bounds = CGRectMake(0, 0, 200, 100);
    pictureBtn.contentMode = UIViewContentModeScaleAspectFit;
    [pictureBtn setBackgroundImage:[UIImage imageNamed:@"flower.jpg"] forState:UIControlStateNormal];
    [pictureBtn addTarget:self action:@selector(handlePictureAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pictureBtn];
}

- (void) handlePictureAction {
    
    DGLPictureView *pictureView = [[DGLPictureView alloc] initWithFrame:self.view.frame image:[UIImage imageNamed:@"flower.jpg"]];
    pictureView.gestureBlock = ^(NSString *event) {
        
        NSLog(@"%@",event);
    };
    [self.view addSubview:pictureView];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

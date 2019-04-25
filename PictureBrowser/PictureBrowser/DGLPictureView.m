//
//  DGLPictureView.m
//  PictureBrowser
//
//  Created by DonLee on 2019/4/25.
//  Copyright © 2019 DonLee. All rights reserved.
//

#import "DGLPictureView.h"

@interface DGLPictureView()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation DGLPictureView

- (instancetype) initWithFrame:(CGRect)frame image:(UIImage *)image{
    
    if (image == nil) {
        return nil;
    }
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor colorWithWhite:.5 alpha:.5];
        _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.minimumZoomScale = 1;
        _scrollView.maximumZoomScale = 3;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        //打开imageVIew的事件响应能力
        _imageView.userInteractionEnabled = YES;
        _imageView.image = image;
        [_scrollView addSubview:_imageView];
        
        //手势
        //一个手指 单击
        UITapGestureRecognizer *singleClickDog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singliDogTap:)];
        //一个手指 双击
        UITapGestureRecognizer *doubleClickTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        //两个手指
        UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handelTwoFingerTap:)];
        singleClickDog.numberOfTapsRequired = 1;
        singleClickDog.numberOfTouchesRequired = 1;
        doubleClickTap.numberOfTapsRequired = 2;//需要点两下
        twoFingerTap.numberOfTouchesRequired = 2;//需要两个手指touch
        [_imageView addGestureRecognizer:singleClickDog];
        [_imageView addGestureRecognizer:doubleClickTap];
        [_imageView addGestureRecognizer:twoFingerTap];
        [singleClickDog requireGestureRecognizerToFail:doubleClickTap];//如果双击了，则不响应单击事件
        [_scrollView setZoomScale:1];
        [self addSubview:_scrollView];
        
    }
    return self;
}

#pragma mark - ScrollView Delegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}
//缩放系数(倍数)
-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [scrollView setZoomScale:scale+0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
}
#pragma mark - 事件处理
-(void)singliDogTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if (_gestureBlock) {
        _gestureBlock(@"单击");
    }
    if (_scrollView.zoomScale == 1) {
        [self removeFromSuperview];
    }
}
-(void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer{
    if (_gestureBlock) {
        _gestureBlock(@"双击");
    }
    if (gestureRecognizer.numberOfTapsRequired == 2) {
        if(_scrollView.zoomScale == 1){
            float newScale = [_scrollView zoomScale] *2;
            CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
            [_scrollView zoomToRect:zoomRect animated:YES];
        }else{
            float newScale = [_scrollView zoomScale]/2;
            CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
            [_scrollView zoomToRect:zoomRect animated:YES];
        }
    }
}

-(void)handelTwoFingerTap:(UITapGestureRecognizer *)gestureRecongnizer{
    if (_gestureBlock) {
        _gestureBlock(@"2手指");
    }
    float newScale = [_scrollView zoomScale]/2;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecongnizer locationInView:gestureRecongnizer.view]];
    [_scrollView zoomToRect:zoomRect animated:YES];
    if (_scrollView.zoomScale < 1) {
        _scrollView.zoomScale = 1;
    }
}

#pragma mark - 缩放大小获取方法
-(CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center{
    CGRect zoomRect;
    //大小
    zoomRect.size.height = [_scrollView frame].size.height/scale;
    zoomRect.size.width = [_scrollView frame].size.width/scale;
    //原点
    zoomRect.origin.x = center.x - zoomRect.size.width/2;
    zoomRect.origin.y = center.y - zoomRect.size.height/2;
    return zoomRect;
}

@end

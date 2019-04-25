//
//  DGLPictureView.h
//  PictureBrowser
//
//  Created by DonLee on 2019/4/25.
//  Copyright © 2019 DonLee. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface DGLPictureView : UIView

typedef void(^ActionBlock)(NSString *event);
@property (nonatomic, copy) ActionBlock gestureBlock;

- (instancetype) initWithFrame:(CGRect)frame image:(UIImage *)image;

@end

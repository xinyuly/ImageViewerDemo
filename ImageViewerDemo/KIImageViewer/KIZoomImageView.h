//
//  KIZoomImageView.h
//  ImageViewerDemo
//
//  Created by xinyu on 2016/10/25.
//  Copyright © 2016年 xinyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KIZoomImageView;
typedef void(^KIZoomImageViewDidClickBlock) (KIZoomImageView *view);
typedef void(^KIZoomImageViewLongPressBlock) (KIZoomImageView *view);

@interface KIZoomImageView : UIScrollView

@property (nonatomic, strong) UIImage *image;

- (UIImageView *)imageView;

- (void)resetImageViewFrame;

// 调用此方法之后，会改变 UIImageView 的 Frame，如果想要正常进行缩放操作，需要调用一次 resetImageViewFrame 方法。
- (void)updateImageViewFrame:(CGRect)frame;

- (UITapGestureRecognizer *)zoomTapGesture;
- (UITapGestureRecognizer *)tapGesture;

- (void)setDidClickBlock:(KIZoomImageViewDidClickBlock)block;
- (void)setLongPressBlock:(KIZoomImageViewLongPressBlock)block;

@end

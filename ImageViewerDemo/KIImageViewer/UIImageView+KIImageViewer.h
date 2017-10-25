//
//  UIImageView+KIImageViewer.h
//  ImageViewerDemo
//
//  Created by xinyu on 2016/10/25.
//  Copyright © 2016年 xinyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KIImageViewer.h"

@interface UIImageView (KIImageViewer)

- (void)setupImageViewerWithURL:(NSURL *)url placeholderImage:(UIImage *)image;

- (void)setupImageViewerWithDelegate:(id<KIImageViewerDelegate>)delegate initialIndex:(NSInteger)index;

- (void)removeImageViewer;

@end

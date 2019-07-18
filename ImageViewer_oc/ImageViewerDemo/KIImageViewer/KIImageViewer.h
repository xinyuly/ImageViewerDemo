//
//  KIImageViewer.h
//  ImageViewerDemo
//
//  Created by xinyu on 2016/10/25.
//  Copyright © 2016年 xinyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KIImageCollectionView.h"
#import "UIImageView+WebCache.h"

@class KIImageViewer;

@protocol KIImageViewerDelegate <NSObject>
@required
- (NSInteger)numberOfImages:(KIImageViewer *)imageViewer;

- (NSURL *)imageViewer:(KIImageViewer *)imageViewer imageURLAtIndex:(NSInteger)index;

- (UIImage *)imageViewer:(KIImageViewer *)imageViewer placeholderImageAtIndex:(NSInteger)index;

@optional
- (UIView *)imageViewer:(KIImageViewer *)imageViewer targetViewAtIndex:(NSInteger)index;

- (void)imageViewer:(KIImageViewer *)imageView didDisplayImageAtIndex:(NSInteger)index;

- (void)imageViewer:(KIImageViewer *)imageViewer didEndDisplayingImageAtIndex:(NSInteger)index;

@end

@interface KIImageViewer : UIView

@property (nonatomic, weak) id<KIImageViewerDelegate> delegate;
@property (nonatomic, assign) NSInteger               initialIndex;

+ (void)showWithDelegate:(id<KIImageViewerDelegate>)delegate initialIndex:(NSInteger)index;

- (void)show;

- (void)dismiss;

@end

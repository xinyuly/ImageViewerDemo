//
//  KIImageViewer.m
//  ImageViewerDemo
//
//  Created by xinyu on 2016/10/25.
//  Copyright © 2016年 xinyu. All rights reserved.
//

#import "KIImageViewer.h"
#import "UIImage+KIImageViewer.h"
#import "KIActionSheet.h"

@interface KIImageViewer () <KIImageCollectionViewDelegate>
@property (nonatomic, strong) KIImageCollectionView *collectionView;

@property (nonatomic, assign) BOOL      isLoad;
@property (nonatomic, assign) BOOL      statusBarHidden;
@end

@implementation KIImageViewer

+ (void)showWithDelegate:(id<KIImageViewerDelegate>)delegate initialIndex:(NSInteger)index {
    if (delegate == nil) {
        return ;
    }
    
    KIImageViewer *imageViewer = [[KIImageViewer alloc] init];
    NSInteger total = 0;
    if ([delegate respondsToSelector:@selector(numberOfImages:)]) {
        total = [delegate numberOfImages:imageViewer];
    }
    
    if (index < 0 || index >= total) {
        index = 0;
    }
    
    [imageViewer setDelegate:delegate];
    [imageViewer setInitialIndex:index];
    [imageViewer show];
}

#pragma mark - Lifecycle
- (void)dealloc {
}

- (instancetype)init {
    if (self = [super init]) {
        [self ki__initFinished];
    }
    return self;
}

- (void)ki__initFinished {
    [self addSubview:self.collectionView];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self.collectionView setFrame:frame];
}

#pragma mark - KIImageCollectionViewDelegate
- (NSInteger)numberOfImages:(KIImageCollectionView *)collectionView {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(numberOfImages:)]) {
        return [self.delegate numberOfImages:self];
    }
    return 0;
}

- (void)collectionView:(KIImageCollectionView *)collectionView didClickedItem:(KIImageCollectionViewCell *)cell {
    [self dismiss];
}

- (void)collectionView:(KIImageCollectionView *)collectionView didLongPressItem:(KIImageCollectionViewCell *)cell {
    KIActionSheet *actionSheet = [[KIActionSheet alloc] initWithTitle:nil
                                                    cancelButtonTitle:NSLocalizedString(@"取消", nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"保存到相册", nil), nil];
    __weak KIImageCollectionViewCell *weakCell = cell;
    __weak KIImageViewer *weakSelf = self;
    [actionSheet setClickedButtonAtIndexBlock:^(KIActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            UIImageWriteToSavedPhotosAlbum(weakCell.imageZoomView.image,
                                           weakSelf,
                                           @selector(image:didFinishSavingWithError:contextInfo:),
                                           NULL);
        }
    }];
    [actionSheet show];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *msg = nil ;
    if (error != NULL) {
        msg = NSLocalizedString(@"保存图片失败", nil);
    } else {
        msg = NSLocalizedString(@"保存图片成功", nil);
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)collectionView:(KIImageCollectionView *)collectionView configCell:(KIImageCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    UIImage *placeholderImage = nil;
    NSURL *imageURL = nil;
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(imageViewer:placeholderImageAtIndex:)]) {
        placeholderImage = [self.delegate imageViewer:self placeholderImageAtIndex:indexPath.row];
    }
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(imageViewer:imageURLAtIndex:)]) {
        imageURL = [self.delegate imageViewer:self imageURLAtIndex:indexPath.row];
    }
    [cell.imageZoomView.imageView setContentMode:UIViewContentModeScaleAspectFill];
    
    if (!self.isLoad && self.initialIndex == indexPath.row) {
        [cell.imageZoomView setImage:placeholderImage];
        [cell.imageZoomView.imageView setClipsToBounds:NO];
        
        CGRect frame = [self viewFrameAtIndex:indexPath.row];
        
        if (!CGRectIsEmpty(frame)) {
            [cell.imageZoomView updateImageViewFrame:frame];
        } else {
            [cell setAlpha:0.0f];
        }
        
        CGRect bounds = [self mainViewBounds];
        [UIView animateWithDuration:0.3
                              delay:0
                            options:0
                         animations:^{
                             if (!CGRectIsEmpty(frame)) {
                                 [cell.imageZoomView updateImageViewFrame:[placeholderImage centerFrameToFrame:bounds]];
                             } else {
                                 [cell setAlpha:1.0];
                             }
                             [self processLongImage:placeholderImage cell:cell];
                         } completion:^(BOOL finished) {
                             [self loadImageWithURL:imageURL placeholderImage:placeholderImage cell:cell isInitial:YES];
                         }];
        self.isLoad = YES;
    } else {
        [self loadImageWithURL:imageURL placeholderImage:placeholderImage cell:cell isInitial:NO];
    }
    
    if (!self.collectionView.isUpdatingFrame && self.delegate != nil && [self.delegate respondsToSelector:@selector(imageViewer:didDisplayImageAtIndex:)]) {
        [self.delegate imageViewer:self didDisplayImageAtIndex:indexPath.row];
    }
}

- (void)collectionView:(KIImageCollectionView *)collectionView didEndDisplayingCell:(KIImageCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.collectionView.isUpdatingFrame && self.delegate != nil && [self.delegate respondsToSelector:@selector(imageViewer:didEndDisplayingImageAtIndex:)]) {
        [self.delegate imageViewer:self didEndDisplayingImageAtIndex:indexPath.row];
    }
}

#pragma mark - Methods
- (void)updateBackgroundColorWithAlpha:(CGFloat)alpha {
    [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:alpha]];
}

- (void)showBackgroundColor {
    [self updateBackgroundColorWithAlpha:1.0f];
}

- (void)hideBackgroundColor {
    [self updateBackgroundColorWithAlpha:0.0f];
}

- (UIView *)targetViewAtIndex:(NSInteger)index {
    UIView *v = nil;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(imageViewer:targetViewAtIndex:)]) {
        v = [self.delegate imageViewer:self targetViewAtIndex:index];
    }
    return v;
}

- (CGRect)viewFrameAtIndex:(NSInteger)index {
    UIView *mainView = [self mainView];
    UIView *targetView = [self targetViewAtIndex:index];
    if (targetView == nil) {
        return CGRectZero;
    }
    CGRect frame = [targetView.superview convertRect:targetView.frame toView:mainView];
    return frame;
}

- (void)show {
    self.statusBarHidden = [UIApplication sharedApplication].statusBarHidden;

    
    UIView *mainView = [self mainView];
    [self setIsLoad:NO];
    [self setFrame:mainView.bounds];
    [mainView addSubview:self];
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.initialIndex inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionNone
                                        animated:NO];
    
    [self hideBackgroundColor];
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         [self showBackgroundColor];
                     } completion:^(BOOL finished) {
                        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
                     }];
}

- (void)dismiss {
    [[UIApplication sharedApplication] setStatusBarHidden:self.statusBarHidden withAnimation:UIStatusBarAnimationNone];
    
    KIImageCollectionViewCell *cell = (KIImageCollectionViewCell *)[self.collectionView.visibleCells firstObject];
    NSIndexPath *indexPath = nil;
    CGRect frame = CGRectZero;
    
    if (cell != nil) {
        [cell.imageZoomView.imageView sd_cancelCurrentAnimationImagesLoad];
        
        indexPath = [self.collectionView indexPathForCell:cell];
        frame = [self viewFrameAtIndex:indexPath.row];
    }

    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         [self hideBackgroundColor];
                         [cell.imageZoomView setZoomScale:cell.imageZoomView.minimumZoomScale animated:NO];
                         if (!CGRectIsEmpty(frame)) {
                             [cell.imageZoomView.imageView setClipsToBounds:YES];
                             [cell.imageZoomView updateImageViewFrame:frame];
                         } else {
                             [cell setAlpha:0.0];
                         }
                        
                     } completion:^(BOOL finished) {
                         if (indexPath != nil) {
                             [self collectionView:self.collectionView didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
                         }
                         
                         [self removeFromSuperview];
                     }];
}

- (void)loadImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage cell:(KIImageCollectionViewCell *)cell isInitial:(BOOL)isInitial {
    CGRect bounds = [self mainViewBounds];
    
    if (!isInitial) {
        [cell.imageZoomView setImage:placeholderImage];
        [cell.imageZoomView updateImageViewFrame:[placeholderImage centerFrameToFrame:bounds]];
    }
    
    [self processLongImage:placeholderImage cell:cell];
    
    __weak KIImageViewer *weakSelf = self;
    [cell.imageZoomView.imageView sd_setImageWithURL:url
                                    placeholderImage:placeholderImage
                                             options:SDWebImageAvoidAutoSetImage
                                            progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                if (image != nil) {
                                                    image = [self kiiv_fixOrientation:image];
                                                    [cell.imageZoomView setImage:image];
                                                    [cell.imageZoomView updateImageViewFrame:[image centerFrameToFrame:bounds]];
                                                    [weakSelf processLongImage:image cell:cell];
                                                }
                                            }];
}

- (UIImage *)kiiv_fixOrientation:(UIImage *)image {
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (void)processLongImage:(UIImage *)image cell:(KIImageCollectionViewCell *)cell {
    CGSize imageSize = image.size;
    if (imageSize.width * 2 < imageSize.height) {
        [cell.imageZoomView setZoomScale:(self.mainViewBounds.size.width/imageSize.width)-0.0001 animated:NO];
        [cell.imageZoomView setContentOffset:CGPointMake(0, 0)];
    }
}

#pragma mark - Getters & Setters
- (UIView *)mainView {
    return [UIApplication sharedApplication].keyWindow;
}

- (CGRect)mainViewBounds {
    return [self mainView].bounds;
}

- (KIImageCollectionView *)collectionView {
    if (_collectionView == nil) {
        _collectionView = [[KIImageCollectionView alloc] init];
        [_collectionView setImageDelegate:self];
        [_collectionView setBackgroundColor:[UIColor clearColor]];
    }
    return _collectionView;
}

@end

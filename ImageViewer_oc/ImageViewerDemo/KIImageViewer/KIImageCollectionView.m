//
//  KIImageCollectionView.m
//  ImageViewerDemo
//
//  Created by xinyu on 2016/10/25.
//  Copyright © 2016年 xinyu. All rights reserved.
//

#import "KIImageCollectionView.h"
#import "UIImage+KIImageViewer.h"

@interface KIImageCollectionView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@end

@implementation KIImageCollectionView


- (instancetype)init {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    return [self initWithFrame:CGRectZero collectionViewLayout:layout];
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        [self ki__initFinished];
    }
    return self;
}

- (void)ki__initFinished {
    [self registerClass:[KIImageCollectionViewCell class] forCellWithReuseIdentifier:@"KIImageCollectionViewCell"];
    
    [self setPagingEnabled:YES];
    [self setDelegate:self];
    [self setDataSource:self];
    [self setShowsVerticalScrollIndicator:NO];
    [self setShowsHorizontalScrollIndicator:NO];
    if ([self respondsToSelector:@selector(setPrefetchingEnabled:)]) {
        [self performSelector:@selector(setPrefetchingEnabled:) withObject:@(NO)];
    }
}

- (void)setFrame:(CGRect)frame {
    BOOL sizeChanging = !CGSizeEqualToSize(frame.size, self.frame.size);
    
    CGFloat dx = self.contentOffset.x / CGRectGetWidth(self.frame);
    NSIndexPath *indexPath = nil;
    if (!isnan(dx)) {
         indexPath = [NSIndexPath indexPathForRow:(int)dx inSection:0];
    }
    
    [self setIsUpdatingFrame:YES];
    [super setFrame:frame];
    if (sizeChanging) {
        [self reloadData];
        if (indexPath != nil) {
            [self scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
    }
    [self setIsUpdatingFrame:NO];
}
#pragma mark - UICollectionView
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.frame.size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.imageDelegate != nil && [self.imageDelegate respondsToSelector:@selector(numberOfImages:)]) {
        return [self.imageDelegate numberOfImages:self];
    }
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.imageDelegate != nil && [self.imageDelegate respondsToSelector:@selector(collectionView:didEndDisplayingCell:forItemAtIndexPath:)]) {
        [self.imageDelegate collectionView:self didEndDisplayingCell:(KIImageCollectionViewCell *)cell forItemAtIndexPath:indexPath];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KIImageCollectionViewCell *cell = (KIImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"KIImageCollectionViewCell" forIndexPath:indexPath];
    KIZoomImageView *zv = cell.imageZoomView;
    __weak KIImageCollectionViewCell *weakCell = cell;
    __weak KIImageCollectionView *weakSelf = self;
    [zv setDidClickBlock:^(KIZoomImageView *view) {
        if (weakSelf.imageDelegate != nil && [weakSelf.imageDelegate respondsToSelector:@selector(collectionView:didClickedItem:)]) {
            [weakSelf.imageDelegate collectionView:weakSelf didClickedItem:weakCell];
        }
    }];
    
    [zv setLongPressBlock:^(KIZoomImageView *view) {
        if (weakSelf.imageDelegate != nil && [weakSelf.imageDelegate respondsToSelector:@selector(collectionView:didLongPressItem:)]) {
            [weakSelf.imageDelegate collectionView:weakSelf didLongPressItem:weakCell];
        }
    }];
    
    if (self.imageDelegate != nil && [self.imageDelegate respondsToSelector:@selector(collectionView:configCell:atIndexPath:)]) {
        [self.imageDelegate collectionView:self configCell:cell atIndexPath:indexPath];
    }
    return cell;
}

@end

@implementation KIImageCollectionViewCell


- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self.imageZoomView setFrame:self.bounds];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self addSubview:self.imageZoomView];
}

- (KIZoomImageView *)imageZoomView {
    if (_imageZoomView == nil) {
        _imageZoomView = [[KIZoomImageView alloc] init];
    }
    return _imageZoomView;
}

@end

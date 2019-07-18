//
//  UIImage+KIImageViewer.m
//  ImageViewerDemo
//
//  Created by xinyu on 2016/10/25.
//  Copyright © 2016年 xinyu. All rights reserved.
//

#import "UIImage+KIImageViewer.h"

@implementation UIImage (KIImageViewer)

- (CGRect)centerFrameToFrame:(CGRect)frame {
    CGFloat fw = frame.size.width;
    CGFloat fh = frame.size.height;
    
    CGFloat iw = self.size.width;
    CGFloat ih = self.size.height;
    
    CGFloat sw = fw / iw;
    CGFloat sh = fh / ih;
    
    CGFloat nw = fw;
    CGFloat nh = fh;
    
    nh = ih * sw;
    nw = iw * sh;
    
    nh = MIN(fh, nh);
    nw = MIN(fw, nw);
    
    CGRect nf = CGRectMake((frame.size.width - nw) * 0.5, (frame.size.height - nh) * 0.5, nw, nh);
    return nf;
}

@end

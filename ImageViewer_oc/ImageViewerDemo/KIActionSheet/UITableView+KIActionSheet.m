//
//  UITableView+KIActionSheet.m
//  KIActionSheet
//
//  Created by apple on 16/8/15.
//  Copyright © 2016年 SmartWalle. All rights reserved.
//

#import "UITableView+KIActionSheet.h"

@implementation UITableView (KIActionSheet)

- (CGFloat)height {
    CGFloat h = MIN(self.contentSize.height, CGRectGetHeight(self.superview.bounds)-88);
    if (self.contentSize.height > h) {
        [self setScrollEnabled:YES];
    } else {
        [self setScrollEnabled:NO];
    }
    return h;
}

@end

//
//  ViewController.m
//  ImageViewerDemo
//
//  Created by xinyu on 2016/10/25.
//  Copyright © 2016年 xinyu. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+KIImageViewer.h"

@interface ViewController ()<KIImageViewerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;
@property (nonatomic, strong) NSArray *imageList;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.imageView1  setupImageViewerWithDelegate:self initialIndex:0];
    [self.imageView2 setupImageViewerWithDelegate:self initialIndex:1];
    [self.imageView3 setupImageViewerWithDelegate:self initialIndex:2];
    self.imageList = @[@"http://img.redocn.com/sheying/20160928/hongsexianhuameiguihuahuahuifengjingtupian_7170715.jpg",@"http://imgsrc.baidu.com/imgad/pic/item/8cb1cb134954092379eba4479958d109b3de490d.jpg",@"http://imgsrc.baidu.com/imgad/pic/item/0bd162d9f2d3572c3a3f58e58113632762d0c32e.jpg"];
    
    [self.imageView1 sd_setImageWithURL:[NSURL URLWithString:self.imageList[0]]];
    [self.imageView2 sd_setImageWithURL:[NSURL URLWithString:self.imageList[1]]];
    [self.imageView3 sd_setImageWithURL:[NSURL URLWithString:self.imageList[2]]];
}


#pragma mark - KIImageViewerDelegate
- (NSInteger)numberOfImages:(KIImageViewer *)imageViewer {
    return self.imageList.count;
}

- (NSURL *)imageViewer:(KIImageViewer *)imageViewer imageURLAtIndex:(NSInteger)index {
    NSURL *url = [NSURL URLWithString:self.imageList[index]];
    return url;
}

- (UIImage *)imageViewer:(KIImageViewer *)imageViewer placeholderImageAtIndex:(NSInteger)index {
    UIImageView *iv = (UIImageView *)[self.view viewWithTag:1006+index];
    iv.alpha = 1;
    return iv.image;
}

- (UIView *)imageViewer:(KIImageViewer *)imageViewer targetViewAtIndex:(NSInteger)index {
    return [self.view viewWithTag:1006+index];
}

@end

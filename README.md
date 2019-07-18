# ImageViewerDemo
图片浏览，支持图片放大缩小、保存到本地

* 支持多张图片浏览
* 支付点击放大缩小图片
* 支持长按保存图片到本地

## 使用方法
****注意, 如使用保存图片到本地功能，在iOS 10系统下必须在info.plist文件中配置访问相册的权限声明****

1.在需要的地方导入：**#import "UIImageView+KIImageViewer.h"**

2.指定代理和图片的顺序

```objc
    [self.imageView1  setupImageViewerWithDelegate:self initialIndex:0];
    [self.imageView2 setupImageViewerWithDelegate:self initialIndex:1];
    [self.imageView3 setupImageViewerWithDelegate:self initialIndex:2];
```

3.实现代理方法

```objc
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
```

![image](https://github.com/xinyuly/ImageViewerDemo/blob/master/animation.gif)

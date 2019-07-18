//
//  KIImageViewer.swift
//  KKSelect-iOS
//
//  Created by lixinyu on 2019/6/12.
//  Copyright © 2019 hxhg. All rights reserved.
//

import UIKit
import Kingfisher

class GoodsImage: UIScrollView {
    
    let iv = UIImageView()
    var imageNormalWidth: CGFloat = 0 {
        didSet {
            iv.frame = CGRect(x: (frame.width-imageNormalWidth)*0.5, y: (frame.height-imageNormalHeight)*0.5, width: imageNormalWidth, height: imageNormalHeight)
        }
    }
    var imageNormalHeight: CGFloat = 0 {
        didSet {
            iv.frame = CGRect(x: (frame.width-imageNormalWidth)*0.5, y: (frame.height-imageNormalHeight)*0.5, width: imageNormalWidth, height: imageNormalHeight)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        addSubview(iv)
        iv.frame = CGRect(x: 0, y:(frame.height - frame.width)*0.5, width: frame.width, height: frame.width)
        iv.isUserInteractionEnabled = true
        self.delegate = self
        minimumZoomScale = 1.0
        maximumZoomScale = 2.0
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
        imageNormalWidth = frame.width
        imageNormalHeight = frame.width
    }
    
    func bindData(_ url: String) {
        KingfisherManager.shared.retrieveImage(with: URL(string: url)!, options: nil, progressBlock: nil) { (image, err, cache, url) in
            if let image = image {
                self.iv.image = image
                var iWidth = self.frame.width
                var iHeight = (iWidth*image.size.height)/image.size.width
                if iHeight > self.frame.height {
                    iHeight = self.frame.height
                    iWidth = (image.size.width*iHeight)/image.size.height
                    self.maximumZoomScale = self.frame.width/iWidth
                }
                self.imageNormalWidth = iWidth
                self.imageNormalHeight = iHeight
            }
        }
    }
    
    func imageViewZoom(_ zoomScale: CGFloat) {
        let imageScaleWidth = zoomScale * imageNormalWidth
        let imageScaleHeight = zoomScale * imageNormalHeight
        
        var imageX: CGFloat = 0
        var imageY: CGFloat = 0
        if (imageScaleWidth < frame.width) {
            imageX = CGFloat(((self.frame.size.width - imageScaleWidth) / 2.0))
        }
        if (imageScaleHeight < self.frame.size.height) {
            imageY = CGFloat(((self.frame.size.height - imageScaleHeight) / 2.0))
        }
        iv.frame = CGRect(x: imageX, y: imageY, width: imageScaleWidth, height: imageScaleHeight)
        contentSize = CGSize(width: imageScaleWidth, height: imageScaleHeight)
    }
}

extension GoodsImage: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return iv
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageViewZoom(scrollView.zoomScale)
    }
}

class KIImageViewer: UIView {

    var didScrollCallBack:((_ index: Int)->())?
    private var imgsUrl = [String]()
    private var svBack = UIScrollView()
    private var lIndex: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()

    private var currentIndex = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     private func layout() {
        backgroundColor = .black
        addSubview(svBack)
        addSubview(lIndex)
        frame = UIScreen.main.bounds
        svBack.frame = CGRect(x: 0, y: 0, width: frame.width+20, height: frame.height)
        lIndex.frame = CGRect(x: frame.width-130, y: frame.height-100, width: 100, height: 30)
        svBack.delegate = self
        svBack.isPagingEnabled = true
        svBack.showsHorizontalScrollIndicator = false
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
    }
    
    func bindData(_ imgsUrl: [String], index: Int) {
        self.imgsUrl = imgsUrl
        self.currentIndex = index
        for (i, imgsUrl) in imgsUrl.enumerated() {
            let iv = GoodsImage(frame: CGRect(x: (frame.width+20)*CGFloat(i), y: 0, width: frame.width, height: frame.height))
            iv.bindData(imgsUrl)
            svBack.addSubview(iv)
            iv.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(showSaveSheet(gesture:))))
            iv.isUserInteractionEnabled = true
        }
        svBack.contentSize = CGSize(width: (frame.width+20)*CGFloat(imgsUrl.count), height: 0)
        svBack.contentOffset = CGPoint(x: CGFloat(index)*frame.width, y: 0)
        lIndex.text = "\(index + 1)/\(self.imgsUrl.count)"
    }
    
    func show() {
        let view = UIApplication.shared.keyWindow?.rootViewController?.view
        view!.addSubview(self)
    }
    
    @objc func dismiss() {
        self.backgroundColor = UIColor.clear
        UIView.animate(withDuration: 0.3, animations: {
        }) { (finish) in
            self.removeFromSuperview()
        }
    }
    
    @objc func showSaveSheet(gesture:UILongPressGestureRecognizer) {
        if gesture.state == .began, let svBack:GoodsImage = gesture.view as? GoodsImage {
            if let image = svBack.iv.image {
                self.showSheet(image)
            }
        }
    }
    
    func showSheet(_ image: UIImage) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "保存图片到相册", style: .default) { (action) in
            self.saveToAlbum(image)
        }
        sheet.addAction(action)
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        sheet.addAction(cancel)
        if let vc = UIApplication.shared.keyWindow?.rootViewController {
            vc.present(sheet, animated: true, completion: nil)
        }
    }
    
    @objc private func saveToAlbum(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer){
        if error == nil {
//            Utilities.showProgress(view: self, message: "保存成功")
        } else {
//            Utilities.showProgress(view: self, message: "保存失败，请重试")
        }
    }
}

extension KIImageViewer: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / (scrollView.bounds.size.width))
        lIndex.text = "\(currentPage + 1)/\(self.imgsUrl.count)"
        if currentPage != currentIndex {
            if let iv = svBack.subviews[currentIndex] as? GoodsImage {
                iv.imageViewZoom(1.0)
            }
            currentIndex = currentPage
        }
        if let callBack = didScrollCallBack {
            callBack(currentPage)
        }
    }
}

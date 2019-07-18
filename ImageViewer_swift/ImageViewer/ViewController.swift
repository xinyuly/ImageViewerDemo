//
//  ViewController.swift
//  ImageViewer
//
//  Created by lixinyu on 2019/7/17.
//  Copyright © 2019 lxy. All rights reserved.
//

import UIKit
import Kingfisher

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imageView.isUserInteractionEnabled = true
        imageView.kf.setImage(with: URL(string: "https://img.alicdn.com/imgextra/i1/2217415238/O1CN013DBeLw1oZ37LwXEI2_!!2217415238.jpg"))
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(test)))
    }

    @objc func test() {
        let imgs = ["https://img.alicdn.com/imgextra/i1/2217415238/O1CN013DBeLw1oZ37LwXEI2_!!2217415238.jpg", "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1562319098546&di=fff0e23f26058e71ebf72f50fde5274b&imgtype=0&src=http%3A%2F%2Fimgup04.iefans.net%2Fiefans%2F2019-02%2F11%2F11%2F15498570716693_1.jpg", "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1562319098544&di=04d9c80ad7e03bddcd92e2143b3c8560&imgtype=0&src=http%3A%2F%2Fhbimg.b0.upaiyun.com%2F9d0e2ea8f6c55592b94fe527d24a4f377708b45ec9cb-qwv7zF_fw658", "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1562319192258&di=01a42a47603eb8d4cf3a7314ab80de87&imgtype=0&src=http%3A%2F%2Fimage.zzd.sm.cn%2F15460437926098203691.jpg%3Fid%3D0", "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1562319306315&di=57ca1c6e9b4053c05d50534b65b6bcea&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fblog%2F201501%2F13%2F20150113193010_KwnaG.thumb.700_0.jpeg"]
        let viewer = KIImageViewer()
        viewer.bindData(imgs, index: 0)
        viewer.show()
    }

}


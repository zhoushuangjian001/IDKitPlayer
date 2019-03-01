//
//  ClassExtension.swift
//  IDKitPlayer
//
//  Created by Mac on 2019/3/1.
//  Copyright © 2019 Network小贱. All rights reserved.
//

import Foundation
import UIKit



// MARK: - 图像扩展
extension UIImage {
    
    /// 从静态库中获取图像
    ///
    /// - Parameter name: 图像的名字
    /// - Returns: 图像对象
    static func initBundle(name:String) -> UIImage? {
        var imagePath = "Player.bundle/" + name
        var image = UIImage.init(named: imagePath)
        if image == nil {
            imagePath = "Frameworks/IDKitPlayer.framework/Player.bundle/" + name
            image = UIImage.init(named: imagePath)
        }
        return image
    }
}


// MARK: - 视图扩展
extension UIView {
    
    /// 视图 Layer 层添加图像
    ///
    /// - Parameter name: 图像的名字
    func layerImage(name:String) {
        let img = UIImage.initBundle(name: name)
        guard img != nil else {return}
        self.layer.contents = img!.cgImage
    }
    
    
}





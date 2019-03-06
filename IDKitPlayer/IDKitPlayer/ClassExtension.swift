//
//  ClassExtension.swift
//  IDKitPlayer
//
//  Created by Mac on 2019/3/1.
//  Copyright © 2019 Network小贱. All rights reserved.
//

import Foundation
import UIKit
import CoreMedia



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


// MARK: - 时间转化扩展
extension CMTime {
    
    /// CMTime 转化为视频格式时间
    var videoTime:String {
        guard self.isValid else {
            return "00:00"
        }
        let value = self.seconds
        let minutesPart = Int(value) / 60
        let secondsPart = Int(value) % 60
        return String.init(format: "%02d:%02d", minutesPart,secondsPart)
    }
    
    /// CMTime 转化为 Float 类型数值
    var floatValue:Float {
        guard self.isValid else {
            return 0
        }
        let value = self.seconds
        return Float(value)
    }
}


// MARK: - 字符串的扩展
extension String {
    
    /// String 转 CMTime
    var toCMTime: CMTime {
        guard self.count != 0  else {
            return CMTime.zero
        }
        let componentsArray = self.components(separatedBy: ":")
        let minutesPart = componentsArray.first!
        let secondPart = componentsArray.last!
        let value = CMTimeValue(minutesPart)! * 60 + CMTimeValue(secondPart)!
        return CMTime.init(value: value, timescale: CMTimeScale(1.0))
    }
}


// MARK: - Float 类型扩展
extension Float {
    
    /// Float 转 CMTime
    var toCMTime : CMTime {
        return CMTime.init(value: CMTimeValue(self), timescale: 1)
    }
}




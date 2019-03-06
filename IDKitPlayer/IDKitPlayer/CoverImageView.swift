//
//  CoverImageView.swift
//  IDKitPlayer
//
//  Created by Mac on 2019/3/6.
//  Copyright © 2019 Network小贱. All rights reserved.
//

import UIKit

/// 图像手势类型
///
/// - single: 单击手势
enum GesturesType {
    case single
    
}

class CoverImageView: UIImageView {
    
    /// 图像手势回调函数
    var gestureBlack:((_ type:GesturesType)->())?

    
    /// 类初始化方法
    ///
    /// - Parameter frame: 视图大小
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        self.registerGestures()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



// MARK: - 内部方法扩展
extension CoverImageView {
    
    /// 注册手势
    fileprivate func registerGestures(){
        
        // 单点手势
        let singleGestures = UITapGestureRecognizer.init(target: self, action: #selector(singleGesturesMethod))
        self.addGestureRecognizer(singleGestures)
    }
    
    /// 点击手势触发函数
    @objc fileprivate func singleGesturesMethod(){
        self.gestureBlack!(.single)
    }
}

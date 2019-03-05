//
//  LoadAnimationView.swift
//  IDKitPlayer
//
//  Created by Mac on 2019/3/1.
//  Copyright © 2019 Network小贱. All rights reserved.
//

import UIKit

enum AnimationType {
    case none
    case title
    case tiaotitle
    case network
}

class LoadAnimationView: UIView {
    
    /// 动画类型
    var animationType:AnimationType = .none
    
    fileprivate lazy var activityIndicatorView : UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView.init(style: .whiteLarge)
        return activity
    }()
    
    convenience  init(frame: CGRect,type:AnimationType = .none) {
        self.init(frame: frame)
        self.backgroundColor = UIColor.black
        self.animationType = type
        self.addSubclassElement(type: type)
    }
    
    
   
    
    
    
    
}


// MARK: - 内部方法扩展
extension LoadAnimationView {
    
    /// 添加子类元素
    fileprivate func addSubclassElement(type:AnimationType){
        if type == .none {
            self.addSubview(self.activityIndicatorView)
        }
    }
    
    /// 子类元素布局
    override func layoutSubviews() {
        
        if self.animationType == .none {
            self.activityIndicatorView.frame = CGRect.init(x: 0, y: 0, width: 70, height: 70)
            self.activityIndicatorView.center = CGPoint.init(x: self.center.x - self.frame.origin.x, y: self.center.y - self.frame.origin.y)
        }
    }
}



extension LoadAnimationView {
    
    
    func startAnimation(){
        if self.animationType == .none {
            self.isHidden = false
            self.activityIndicatorView.startAnimating()
        }
    }
    
    
    func stopAnimation() {
        if self.animationType == .none {
            self.isHidden = true
            self.activityIndicatorView.stopAnimating()
        }
    }
}

//
//  HeadToolbarView.swift
//  IDKitPlayer
//
//  Created by Mac on 2019/2/28.
//  Copyright © 2019 Network小贱. All rights reserved.
//

import UIKit

@objc protocol HeadToolbarViewDelegate {
    
    /// 视频全屏导航返回按钮事件
    func navigationBackButtonMethod()->Void
}

class HeadToolbarView: UIView {
    
    /// 头部工具栏代理
    weak var delegate:HeadToolbarViewDelegate?

    /// 是否全屏状态
    var fullScreenStatus : Bool {
        get{
            return !self.backButton.isHidden
        }
        set{
            self.backButton.isHidden = !newValue
        }
    }

    /// 视频标题
    var title : String {
        get {
            return self.titleLable.text!
        }
        set{
            self.titleLable.text = newValue
        }
    }

    /// 视频标题的载体
    fileprivate lazy var titleLable : UILabel = {
        let lable = UILabel.init()
        lable.text = ""
        lable.font = UIFont.systemFont(ofSize: 18)
        lable.textColor = UIColor.white
        return lable
    }()

    /// 全屏返回按钮
    fileprivate lazy var backButton : UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.isHidden = true
        button.setImage(UIImage.initBundle(name: "back"), for: .normal)
        button.addTarget(self, action: #selector(popViewMethod), for: .touchUpInside)
        return button
    }()
    

    /// 类初始化
    ///
    /// - Parameter frame: 视图大小
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layerImage(name: "h_toolbar")
        self.addSubclassElement()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Xib 类初始化方法
    override func awakeFromNib() {
        self.addSubclassElement()
    }
}


// MARK: - 内部方法
extension HeadToolbarView {

    /// 添加子类元素
    fileprivate func addSubclassElement(){
        self.addSubview(self.backButton)
        self.addSubview(self.titleLable)
    }

    /// 子类视图布局
    override func layoutSubviews() {
        let width = self.bounds.width
        let height = self.bounds.height > 40 ? self.bounds.height : 40
        let interval : CGFloat = 5.0
        let origin_y :CGFloat = (height - 30) * 0.5
        var origin_x : CGFloat = 15
        if fullScreenStatus {
            self.backButton.frame = CGRect.init(x: origin_x, y: (height - 40) * 0.5, width: 40, height: 40)
            origin_x = interval + self.backButton.frame.maxX
            self.titleLable.frame = CGRect.init(x: origin_x, y: origin_y, width: width - origin_x - 15, height: 30)
        }else{
            origin_x = 15
            self.titleLable.frame = CGRect.init(x: origin_x, y: origin_y, width: width - 30, height: 30)
        }
    }
    
    
    /// 导航返回按钮触发事件
    @objc func popViewMethod(){
        guard self.delegate != nil else {return}
        fullScreenStatus = false
        self.delegate!.navigationBackButtonMethod()
    }
}

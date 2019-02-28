//
//  FootToolbarView.swift
//  IDKitPlayer
//
//  Created by Mac on 2019/2/28.
//  Copyright © 2019 Network小贱. All rights reserved.
//

import UIKit

class FootToolbarView: UIView {

    // 当前播放时间
    var currentTime : String {
        get{
            return self.currentTimeLable.text!
        }
        set{
            self.currentTimeLable.text = newValue
        }
    }
    
    // 当前播放时间显示载体
    fileprivate lazy var currentTimeLable : UILabel = {
        let lable = UILabel.init()
        lable.text = "00:00"
        lable.font = UIFont.systemFont(ofSize: 16)
        lable.textColor = UIColor.white
        lable.textAlignment = .center
        return lable
    }()
    
    // 视频总的播放时间
    var totalTime : String {
        get{
            return self.totalTimeLable.text!
        }
        set{
            self.totalTimeLable.text = newValue
        }
    }
    
    // 视频总的播放时间显示载体
    fileprivate lazy var totalTimeLable : UILabel = {
        let lable = UILabel.init()
        lable.text = "00:00"
        lable.font = UIFont.systemFont(ofSize: 16)
        lable.textColor = UIColor.white
        lable.textAlignment = .center
        return lable
    }()
    
    // 视频全屏按钮
    fileprivate lazy var fullScreenButton : UIButton = {
        let button = UIButton.init(type: .custom)
        // TODO: 图像设置
        return button
    }()

    // 视频轨道载体
    fileprivate lazy var trackView : TrackView = {
        let view = TrackView.init()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    /// 重写类初始化方法
    ///
    /// - Parameter frame: 初始化视图大小
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubclassElement()
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Xib 初始化方法
    override func awakeFromNib() {
        self.addSubclassElement()
    }
    
}

// MARK: - 对内方法
extension FootToolbarView {
    
    /// 添加子类元素
    fileprivate func addSubclassElement(){
        self.addSubview(self.currentTimeLable)
        self.addSubview(self.trackView)
        self.addSubview(self.totalTimeLable)
        self.addSubview(self.fullScreenButton)
    }
    
    /// 子类视图布局
    override func layoutSubviews() {
        
        // 设置默认数值
        let lableWidth : CGFloat = 60.0
        let subElementHeight : CGFloat = 30.0
        let interval : CGFloat = 5.0
        let width = self.bounds.width
        let height = self.bounds.height > subElementHeight ? self.bounds.height : 40.0
        var origin_x : CGFloat = 15.0
        let origin_y : CGFloat = ( height - subElementHeight ) * 0.5
        
        // 当前时间
        self.currentTimeLable.frame = CGRect.init(x: origin_x, y: origin_y, width: lableWidth, height: subElementHeight)
        
        // 轨道视图
        origin_x = interval + self.currentTimeLable.frame.maxX
        self.trackView.frame = CGRect.init(x: origin_x, y: origin_y, width: width - 205, height: subElementHeight)
        
        // 总时间
        origin_x = interval + self.trackView.frame.maxX
        self.totalTimeLable.frame = CGRect.init(x: origin_x, y: origin_y, width: lableWidth, height: subElementHeight)
        
        // 全品按钮
        origin_x = interval + self.totalTimeLable.frame.maxX
        self.fullScreenButton.frame = CGRect.init(x: origin_x, y: ( height - 40 ) * 0.5, width: 40, height: 40)
    }
}


// MARK: - 对外开放的方法
extension FootToolbarView {
    
}

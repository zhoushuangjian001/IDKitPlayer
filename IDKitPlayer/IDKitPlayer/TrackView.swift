//
//  TrackView.swift
//  IDKitPlayer
//
//  Created by Mac on 2019/2/28.
//  Copyright © 2019 Network小贱. All rights reserved.
//

import UIKit

class TrackView: UIView {
    
    /// 滑动轨道手动滑动回调事件
    var sliderValueBlock:((_ value:Float)->())?
    
    /// 底层轨道
    fileprivate lazy var bottomTrackView : UIView  = {
        let view = UIView.init()
        view.backgroundColor = UIColor.init(white: 0.5, alpha: 0.9)
        return view
    }()

    /// 缓冲进度轨道
    fileprivate lazy var bufferProgressTrackView : UIProgressView = {
        let progressview = UIProgressView.init()
        progressview.progressTintColor = UIColor.init(white: 0.7, alpha: 1.0)
        progressview.trackTintColor = UIColor.clear
        return progressview
    }()
    
    /// 当前播放滑动轨道
    fileprivate lazy var playSlidTrackView : UISlider = {
        let slider = UISlider.init()
        slider.minimumTrackTintColor = UIColor.white
        slider.maximumTrackTintColor = UIColor.clear
        slider.addTarget(self, action: #selector(slidValueChangeAction(_ :)), for: .valueChanged)
        return slider
    }()

    
    /// 类初始化方法
    ///
    /// - Parameter frame: 视图大小
    override init(frame: CGRect) {
        super.init(frame: frame)
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


// MARK: - 内部方法扩展
extension TrackView {
    
    /// 添加子类元素
    fileprivate func addSubclassElement(){
        self.addSubview(self.bottomTrackView)
        self.addSubview(self.bufferProgressTrackView)
        self.addSubview(self.playSlidTrackView)
    }
    
    /// 子类视图布局
    override func layoutSubviews() {
        
        let width = self.bounds.width
        let height = self.bounds.height
        let padding : CGFloat = 5
        
        /// 底部轨道
        self.bottomTrackView.frame = CGRect.init(x: padding, y: (height - 2) * 0.5, width: width - 2 * padding, height: 2)
        
        /// 缓冲进度轨道
        self.bufferProgressTrackView.frame = self.bottomTrackView.frame
        
        /// 当前播放滑动轨道
        self.playSlidTrackView.frame = CGRect.init(x: padding - 2, y: (height - 30) * 0.5, width: width - 2 * (padding - 2), height: 30)
    }
    
    
    /// 当前滑动轨道触发事件
    ///
    /// - Parameter slider: 滑动轨道对象
    @objc func slidValueChangeAction(_ slider:UISlider) {
        sliderValueBlock!(slider.value)
    }
}

// MARK: - 对外方法扩展
extension TrackView {
    
    /// 重置轨道视图
    func reset(){
        self.bufferProgressTrackView.progress = 0
        self.playSlidTrackView.value = 0
    }
    
    /// 设置缓冲进度
    ///
    /// - Parameter value: 进度值,默认为 0
    func setBufferProgress(value: Float = 0) {
        self.bufferProgressTrackView.setProgress(value, animated: true)
    }
    
    /// 设置当前播放滑动值
    ///
    /// - Parameter value: 滑动值,默认为 0
    func setPlaySlid(value:Float = 0) {
        self.playSlidTrackView.setValue(value, animated: true)
    }
}








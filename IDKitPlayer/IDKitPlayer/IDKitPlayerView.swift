//
//  IDKitPlayerView.swift
//  IDKitPlayer
//
//  Created by Mac on 2019/2/28.
//  Copyright © 2019 Network小贱. All rights reserved.
//

import UIKit
import AVKit

class IDKitPlayerView: UIView,FootToolbarViewDelegate {

    /// 头部工具栏
    lazy var headToolbarView : HeadToolbarView = {
        let view = HeadToolbarView.init()
        return view
    }()

    /// 底部工具栏
    lazy var footToolbarView : FootToolbarView = {
        let view = FootToolbarView.init()
        view.delegate = self
        return view
    }()
    
    /// 播放和暂停按钮
    lazy var playOrPauseButton : UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setImage(UIImage.initBundle(name: "pause"), for: .normal)
        button.setImage(UIImage.initBundle(name: "play"), for: .selected)
        button.addTarget(self, action: #selector(playOrPauseButtonAction(_ :)), for: .touchUpInside)
        return button
    }()
    
    /// 加载动画视图
    lazy var loadAnimationView : LoadAnimationView = {
        let view = LoadAnimationView.init(frame:CGRect.init(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height), type: .none)
        return view
    }()
    
    
    /// 视频封面图像
    var coverImage:UIImage {
        get{ return self.coverImageView.image!}
        set{
            self.coverImageView.image = newValue
        }
    }
    
    /// 视频封面视图
    fileprivate lazy var coverImageView : UIImageView = {
        let imageView = UIImageView.init()
        return imageView
    }()
    
    
    /// 视频播放器的载体
    fileprivate lazy var playerLayer : AVPlayerLayer = {
        let layer = AVPlayerLayer.init()
        return layer
    }()
    
    
    /// 播放器
    fileprivate var player : AVPlayer?
    
    /// 视频资源对象
    fileprivate var playItem : AVPlayerItem?
    
    /// 视频地址
    var url : String?
    
    /// 类初始化方法
    ///
    /// - Parameter frame: 视图大小
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubclassElecment()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


// MARK: - 内部方法扩展
extension IDKitPlayerView {
    
    /// 添加子类元素
    fileprivate func addSubclassElecment(){
        self.addSubview(self.coverImageView)
        self.addSubview(self.headToolbarView)
        self.addSubview(self.playOrPauseButton)
        self.addSubview(self.footToolbarView)
        
    }
    
    /// 子类视图布局
    override func layoutSubviews() {
        let width = self.bounds.width
        let height = self.bounds.height
        
        /// 视频封面视图
        self.coverImageView.frame = CGRect.init(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        
        /// 头部工具栏
        self.headToolbarView.frame = CGRect.init(x: 0, y: 0, width: width, height: 40)
        
        // 底部工具栏
        self.footToolbarView.frame = CGRect.init(x: 0, y: height - 40, width: width, height: 40)
        
        // 播放和暂停按钮
        self.playOrPauseButton.frame = CGRect.init(x: 0, y: 0, width: 45, height: 45)
        self.playOrPauseButton.center = CGPoint.init(x: self.center.x - self.frame.origin.x, y: self.center.y - self.frame.origin.y)
    }
    
    
    /// 播放和暂停按钮事件
    ///
    /// - Parameter btn: 按钮对象
    @objc func playOrPauseButtonAction(_ btn:UIButton) {
        self.playOrPauseButton.isSelected = !btn.isSelected
        self.preparePlay()
    }
    
    
    /// 视频准备播放
    fileprivate func preparePlay(){
        guard self.url != nil, self.url?.count != 0 else {return}
        self.playItem = AVPlayerItem.init(url: URL.init(string: self.url!)!)
        self.player = AVPlayer.init(playerItem: self.playItem!)
        self.registerObserves()
    }
    
    
    /// 注册观察者
    fileprivate func registerObserves(){
        
        // 观察播放区缓存是否为空，为空加载 self.loadAnimationView
        self.playItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: NSKeyValueObservingOptions.new, context: nil)
        
        // 播放区缓存可以支持播放观察
        self.playItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: NSKeyValueObservingOptions.new, context: nil)

        // 视频加载进度观察
        self.playItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
        
        // 视频状态的观察
        self.playItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)

    }
    
    /// 观察者方法方法的处理函数
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if self.playItem!.isKind(of: AVPlayerItem.self) , keyPath == "playbackBufferEmpty" {
            print("缓冲区为空")
        }
        
        if self.playItem!.isKind(of: AVPlayerItem.self) , keyPath == "playbackLikelyToKeepUp" {
            print("缓冲区可以播放")
        }
        
        if self.playItem!.isKind(of: AVPlayerItem.self) , keyPath == "loadedTimeRanges" {
            let loadedTimeRanges = self.playItem!.loadedTimeRanges
            let timeRange = loadedTimeRanges.first as! CMTimeRange
            guard timeRange.isValid else {return}
            let loadingTime = timeRange.start + timeRange.duration
            let percentage = loadingTime.seconds / self.playItem!.duration.seconds
            weak var weakself = self
            DispatchQueue.main.async {
                weakself?.setBufferProgressTrack(value: Float(percentage))
            }
            print("缓冲区中..... %f",percentage)
        }
        
        if self.playItem!.isKind(of: AVPlayerItem.self) , keyPath == "status" {
            let status = change![.newKey] as! Int
            if status == 1 {
                print("准备播放")
            }else{
                print("暂停播放")
            }
        }

    }
}



// MARK: - 代理方法处理扩展
extension IDKitPlayerView {
    
    /// 全屏按钮触发事件
    func fullScreenMethod(_ btn: UIButton) {
        print("全屏按钮触发")
    }
    
    /// 底部当前轨道滑动触发事件
    func slidValueChangeMethod(_ value: Float) {
        print("改变视频播放位置")
    }
}


// MARK: - 对外方法的扩展
extension IDKitPlayerView {

    /// 设置视频缓冲轨道的数值
    ///
    /// - Parameter value: 进度值
    func setBufferProgressTrack(value:Float) {
        self.footToolbarView.setBufferProgressTrack(value: value)
    }
}

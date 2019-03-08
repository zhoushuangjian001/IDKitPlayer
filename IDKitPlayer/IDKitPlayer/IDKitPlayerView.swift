//
//  IDKitPlayerView.swift
//  IDKitPlayer
//
//  Created by Mac on 2019/2/28.
//  Copyright © 2019 Network小贱. All rights reserved.
//

import UIKit
import AVKit


/// 视频的播放状态
///
/// - noPlay: 视频从未播放
/// - playing: 视频播放中
/// - pause: 视频暂停
/// - playEnd: 视频播放完毕
/// - replay: 视频重新播放
/// - loadFail: 视频加载失败
/// - playFail: 视频播放失败
enum VideoPlayStatus {
    case noPlay
    case playing
    case pause
    case playEnd
    case replay
    case loadFail
    case playFail
}


class IDKitPlayerView: UIView,HeadToolbarViewDelegate,FootToolbarViewDelegate {

    /// 头部工具栏
    lazy var headToolbarView : HeadToolbarView = {
        let view = HeadToolbarView.init()
        view.delegate = self
        view.isHidden = true
        return view
    }()

    /// 底部工具栏
    lazy var footToolbarView : FootToolbarView = {
        let view = FootToolbarView.init()
        view.delegate = self
        view.isHidden = true
        return view
    }()
    
    /// 播放和暂停按钮
    lazy var playOrPauseButton : UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setImage(UIImage.initBundle(name: "play"), for: .normal)
        button.addTarget(self, action: #selector(playOrPauseButtonAction(_ :)), for: .touchUpInside)
        return button
    }()
    
    /// 加载动画视图
    lazy var loadAnimationView : LoadAnimationView = {
        let view = LoadAnimationView.init(frame:CGRect.init(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height), type: .none)
        view.isHidden = true
        return view
    }()
    
    /// 视频封面图像
    var coverImage:UIImage? {
        get{ return self.coverImageView.image}
        set{
            self.coverImageView.image = newValue
        }
    }
    
    /// 视频封面视图
    fileprivate lazy var coverImageView : CoverImageView = {
        let imageView = CoverImageView.init(frame: CGRect.zero)
        return imageView
    }()
    
    
    /// 视频播放器的载体
    fileprivate lazy var playerLayer : AVPlayerLayer = {
        let layer = AVPlayerLayer.init()
        layer.backgroundColor = UIColor.black.cgColor
        return layer
    }()
    
    
    /// 播放器
    fileprivate var player : AVPlayer?
    
    /// 视频资源对象
    fileprivate var playItem : AVPlayerItem?
    
    /// 视频地址
    var url : String?
    
    /// 视频界面是否锁定
    var lockStatus:Bool = false
    
    /// 视频的播放状态
    var videoPlayStatus:VideoPlayStatus = .noPlay
    
    /// 视频播放时间的观察对象
    var playTimeObserve : Any?
    
    /// 视频窗口锁屏按钮
    fileprivate lazy var lockPlayInterfaceButton:UIButton = {
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage.initBundle(name: "unlockbtn"), for: .normal)
        button.setImage(UIImage.initBundle(name: "lockbtn"), for: .selected)
        button.addTarget(self, action: #selector(lockPlayInterfaceMethod(_ :)), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    /// 全屏视图
    fileprivate lazy var fullWindow: UIWindow = {
        let window = UIWindow.init(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor.black
        return window
    }()
    
    /// 视图的父视图（用于视频还原）
    fileprivate var parentView: Any?
    
    /// 视图初始大小（用于视频还原）
    fileprivate var initialFrame:CGRect = .zero
    
    
    /// 视频标题设置
    var title : String = "" {
        willSet{
            self.headToolbarView.title = newValue
        }
    }
    
    /// 类初始化方法
    ///
    /// - Parameter frame: 视图大小
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
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
        self.addSubview(self.footToolbarView)
        self.addSubview(self.headToolbarView)
        self.addSubview(self.lockPlayInterfaceButton)
        self.addSubview(self.loadAnimationView)
        self.addSubview(self.playOrPauseButton)
        self.coverGestures()
    }
    
    /// 子类视图布局
    override func layoutSubviews() {
        
        /// 设置父视图的宽高
        let width = self.bounds.width
        let height = self.bounds.height
        
        /// 视频封面视图
        self.coverImageView.frame = CGRect.init(x: 0, y: 0, width: width, height: height)
        
        /// 播放器的窗口大小设置
        self.playerLayer.frame = self.coverImageView.frame;
        
        /// 头部工具栏
        self.headToolbarView.frame = CGRect.init(x: 0, y: 0, width: width, height: 40)
        
        // 底部工具栏
        self.footToolbarView.frame = CGRect.init(x: 0, y: height - 40, width: width, height: 40)

        // 播放和暂停按钮
        self.playOrPauseButton.frame = CGRect.init(x: width * 0.5 - 22.5, y: height * 0.5 - 22.5, width: 45, height: 45)
        
        // 锁屏按钮
        self.lockPlayInterfaceButton.frame = CGRect.init(x: 15, y: self.bounds.height * 0.5 - 25, width: 50, height: 50);
    }
    
    
    /// 播放和暂停按钮事件
    ///
    /// - Parameter btn: 按钮对象
    @objc func playOrPauseButtonAction(_ btn:UIButton) {
        if videoPlayStatus == .noPlay || videoPlayStatus == .playEnd {
            self.playOrPauseButton.isHidden = true
            self.playOrPauseButton.setImage(UIImage.initBundle(name: "playing"), for: .normal)
            self.preparePlay()
        }else if videoPlayStatus == .playing {
            self.playOrPauseButton.setImage(UIImage.initBundle(name: "pause"), for: .normal)
            self.player!.pause()
            videoPlayStatus = .pause
        }else if videoPlayStatus == .pause {
            self.playOrPauseButton.setImage(UIImage.initBundle(name: "playing"), for: .normal)
            self.player!.play()
            videoPlayStatus = .playing
        }
    }
    

    
    /// 视频准备播放
    fileprivate func preparePlay(){
        self.loadAnimationView.startAnimation()
        guard self.url != nil, self.url?.count != 0 else {return}
        self.playItem = AVPlayerItem.init(url: URL.init(string: self.url!)!)
        self.player = AVPlayer.init(playerItem: self.playItem!)
        self.registerObserves()
        self.playerLayer.player = self.player!
        self.coverImageView.layer.addSublayer(self.playerLayer)
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
        
        // 播放停止状态观察
        NotificationCenter.default.addObserver(self, selector: #selector(videoPlayEnd(_ :)), name: .AVPlayerItemDidPlayToEndTime, object: self.playItem!)

    }
    
    /// 注册视频播放时间的刷新频率
    fileprivate func registerPalyTimeRefreshFate(){
        if playTimeObserve == nil {
            self.setVideoTotalTime(time: self.playItem!.duration)
            weak var weakself = self
            playTimeObserve = self.player!.addPeriodicTimeObserver(forInterval: CMTime.init(value: CMTimeValue(1.0), timescale: 10), queue: DispatchQueue.main, using: { (cmTime) in
                DispatchQueue.main.async {
                    weakself!.setVideoPalyTime(time: cmTime)
                }
            })
        }
    }
    
    
    /// 观察者方法方法的处理函数
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if self.playItem!.isKind(of: AVPlayerItem.self) , keyPath == "playbackBufferEmpty" {
            print("缓冲区为空")
        }
        
        if self.playItem!.isKind(of: AVPlayerItem.self) , keyPath == "playbackLikelyToKeepUp" {
            print("缓冲区可以播放")
        }
        
        // 视频缓冲进度
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
        }
        
        // 视频的状态
        if self.playItem!.isKind(of: AVPlayerItem.self) , keyPath == "status" {
            let status = change![.newKey] as! Int
            if status == 1 {
                self.player!.play()
                self.videoPlayStatus = .playing
                self.registerPalyTimeRefreshFate()
                self.loadAnimationView.stopAnimation()
                self.initalizePlayerControls()
            }else{
                self.videoPlayStatus = .pause
                print("暂停播放")
            }
        }
    }
    
    
    /// 设置视频播放时间
    ///
    /// - Parameter time: 时间值
    fileprivate func setVideoPalyTime(time:CMTime ){
        self.footToolbarView.setCurrentTime(time:time)
    }
    
    
    /// 设置视频的总时间
    ///
    /// - Parameter time: 时间值
    fileprivate func setVideoTotalTime(time:CMTime) {
        self.footToolbarView.setTotalTime(time: time)
    }
    
    
    
    /// 视频播放完毕回调
    ///
    /// - Parameter notification: 通知对象
    @objc fileprivate func videoPlayEnd(_ notification: Notification){
        self.videoPlayStatus = .playEnd
        self.playerLayer.removeFromSuperlayer()
        self.removeObservers()
        self.playEndControls()
    }
    
    /// 移除所有观察
    fileprivate func removeObservers(){
        self.playItem!.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        self.playItem!.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        self.playItem!.removeObserver(self, forKeyPath: "loadedTimeRanges")
        self.playItem!.removeObserver(self, forKeyPath: "status")
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 封面图像手势处理
    fileprivate func coverGestures(){
        weak var weakself = self
        self.coverImageView.gestureBlack = { (type:GesturesType) in
            if type == .single {
                // 先判断
                if self.videoPlayStatus != .noPlay , self.videoPlayStatus != .playEnd {
                    // 是否锁屏
                    if self.lockStatus {
                        // 只显示锁屏按钮
                        
                    }else{
                        // TODO:- 展示头部和底部工具栏和锁屏按钮
                        weakself!.palyerControls(status: !self.footToolbarView.isHidden, target: self)
                    }
                }
            }
        }
    }
    
    /// 视频锁屏按钮触发事件函数
    ///
    /// - Parameter btn: 按钮对象
    @objc func lockPlayInterfaceMethod(_ btn:UIButton) {
        self.lockPlayInterfaceButton.isSelected = !btn.isSelected
        self.palyerControls(status: self.lockPlayInterfaceButton.isSelected, target: btn)
        self.coverImageView.isUserInteractionEnabled = !self.lockPlayInterfaceButton.isSelected
    }
    
    /// 设置视频缓冲轨道的数值
    ///
    /// - Parameter value: 进度值
    fileprivate func setBufferProgressTrack(value:Float) {
        self.footToolbarView.setBufferProgressTrack(value: value)
    }
}



// MARK: - 代理方法处理扩展
extension IDKitPlayerView {
    
    /// 全屏按钮触发事件
    func fullScreenMethod(_ btn: UIButton) {
        // 判断按钮是否被选中
        if !btn.isSelected {
            self.videoEnterFullScreenMethod()
        }else{
            self.videoExitFullScreenMethod()
        }
        btn.isSelected = !btn.isSelected
    }
    
    /// 底部当前轨道滑动触发事件
    func slidValueChangeMethod(_ value: Float) {
        // 获取当前滑动时间点
        let playTime = value * self.playItem!.duration.floatValue
        self.playItem!.seek(to: playTime.toCMTime) { (isFinish) in
             print("拖动--",isFinish)
        }
    }
    
    /// 导航返回按钮触发代理
    func navigationBackButtonMethod() {
        // 退出全屏
        self.videoExitFullScreenMethod()
    }
}


// MARK: - 视频控件显示隐藏方法
extension IDKitPlayerView {
    
    /// 显示或者隐藏视频控件
    ///
    /// - Parameter status: 是否显示状态值
    fileprivate func palyerControls(status:Bool , target:Any) {
        if (target as? UIButton) != self.lockPlayInterfaceButton {
            self.lockPlayInterfaceButton.isHidden = status
        }
        self.playOrPauseButton.isHidden = status
        self.headToolbarView.isHidden = status
        self.footToolbarView.isHidden = status
        UIView.animate(withDuration: 1.0) {
            self.headToolbarView.alpha = status ? 0:1
            self.footToolbarView.alpha = status ? 0:1
            let offset_y:CGFloat = status ? -40:40
            self.headToolbarView.center = CGPoint.init(x: self.headToolbarView.center.x, y: self.headToolbarView.center.y + offset_y)
            self.footToolbarView.center = CGPoint.init(x: self.footToolbarView.center.x, y: self.footToolbarView.center.y - offset_y)
        }
    }
    
    
    /// 播放完毕控件的状态
    fileprivate func playEndControls(){
        self.playTimeObserve = nil
        self.playOrPauseButton.setImage(UIImage.initBundle(name: "play"), for: .normal)
        self.playOrPauseButton.isHidden = false
        self.lockPlayInterfaceButton.isSelected = false
        self.coverImageView.isUserInteractionEnabled = true
        self.lockPlayInterfaceButton.isHidden = true
        self.footToolbarView.reset()
        // 判断是否显示状态
        if self.footToolbarView.isHidden {
            UIView.animate(withDuration: 1.0) {
                let offset_y:CGFloat = 40
                self.headToolbarView.center = CGPoint.init(x: self.headToolbarView.center.x, y: self.headToolbarView.center.y + offset_y)
                self.footToolbarView.center = CGPoint.init(x: self.footToolbarView.center.x, y: self.footToolbarView.center.y - offset_y)
            }
        }
        self.headToolbarView.isHidden = true
        self.footToolbarView.isHidden = true
    }
    
    
    /// 视频播放前控件的初始化设置
    fileprivate func initalizePlayerControls(){
        self.lockPlayInterfaceButton.isHidden = false
        self.playOrPauseButton.isHidden = false
        self.headToolbarView.isHidden = false
        self.footToolbarView.isHidden = false
    }
    
    /// 视频进入全屏
    fileprivate func videoEnterFullScreenMethod(){
        
        // 记录初始视图大小
        initialFrame = self.frame
        parentView = self.superview
        self.headToolbarView.fullScreenStatus = true
        self.footToolbarView.fullScreenStatus = true
        UIView.animate(withDuration: 0.25) {
            self.transform = CGAffineTransform.init(rotationAngle: -.pi/2)
        }
        self.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.window!.addSubview(self)
    }
    
    /// 视频退出全屏函数
    fileprivate func videoExitFullScreenMethod(){
        
        // 用于安全显示（刘海型手机）
        self.headToolbarView.fullScreenStatus = false
        self.footToolbarView.fullScreenStatus = false
        UIView.animate(withDuration: 0.25) {
            self.transform = CGAffineTransform.init(rotationAngle: .pi*2)
        }
        self.frame = initialFrame
        // 视图还原到父视图上
        (parentView! as AnyObject).addSubview(self)
    }
}

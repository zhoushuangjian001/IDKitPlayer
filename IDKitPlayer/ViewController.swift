//
//  ViewController.swift
//  IDKitPlayer
//
//  Created by Mac on 2019/2/28.
//  Copyright © 2019 Network小贱. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let view = IDKitPlayerView.init(frame: CGRect.init(x: 0, y: 100, width: self.view.bounds.width, height: 300))
        view.coverImage = UIImage.init(named: "test.jpg")!
        view.url = "http://220.249.115.46:18080/wav/day_by_day.mp4"
        self.view.addSubview(view)
    }


}


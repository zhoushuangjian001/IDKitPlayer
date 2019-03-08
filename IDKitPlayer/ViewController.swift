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
        let view = IDKitPlayerView.init(frame: CGRect.init(x: 0, y: 100, width: self.view.bounds.width, height: 250))
        view.url = "https://media.w3.org/2010/05/sintel/trailer.mp4"
        view.coverImage = UIImage.init(named: "test.jpeg")
        view.title = "驯龙高手--女汉子"
        self.view.addSubview(view)
    }


}


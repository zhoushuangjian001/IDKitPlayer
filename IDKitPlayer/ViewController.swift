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
        let view = HeadToolbarView.init(frame: CGRect.init(x: 0, y: 100, width: self.view.bounds.width, height: 40))
        view.backgroundColor = UIColor.black

        self.view.addSubview(view)

        view.isFullScreen = true
    }


}


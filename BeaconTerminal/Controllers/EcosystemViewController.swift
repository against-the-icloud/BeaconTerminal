//
// Created by Anthony Perritano on 5/17/16.
// Copyright (c) 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import RAMAnimatedTabBarController

class EcosystemViewController : UIViewController {
    
    var ecosystemName : String = ""
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTab()
    }
    
    init(ecosystemName: String) {
        super.init(nibName: nil, bundle: nil)
        self.ecosystemName =  ecosystemName
        setupTab()
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.redColor()
    }

    func setupTab() {
        let tabItem = RAMAnimatedTabBarItem(title: "ECO 1", image: UIImage(named: "ic_wifi"), tag:0)
        self.tabBarItem = tabItem
    }
    
}

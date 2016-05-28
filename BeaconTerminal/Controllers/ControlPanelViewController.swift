//
//  ControlPanelViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 5/22/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework

class ControlPanelViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStatusBarStyle(UIStatusBarStyleContrast)      
    }
    
    @IBAction func onBurger() {
        sideNavigationController?.toggleLeftView()
    }

}

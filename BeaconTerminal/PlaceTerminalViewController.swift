//
//  PlaceTerminalViewController.swift
//  CustomStuff
//
//  Created by Evan Dekhayser on 7/9/14.
//  Copyright (c) 2014 Evan Dekhayser. All rights reserved.
//

import UIKit
import ChameleonFramework
import Material

class PlaceTerminalViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
        self.setStatusBarStyle(UIStatusBarStyleContrast)
	}
	
	@IBAction func onBurger() {
		sideNavigationController?.toggleLeftView()
	}
}


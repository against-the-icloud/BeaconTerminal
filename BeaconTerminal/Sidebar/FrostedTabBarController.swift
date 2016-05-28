//
//  FrostedTabBarController.swift
//  FrostedSidebar
//
//  Created by Evan Dekhayser on 8/28/14.
//  Copyright (c) 2014 Evan Dekhayser. All rights reserved.
//

import UIKit

class FrostedTabBarController: UITabBarController, UITabBarControllerDelegate {
	
	var sidebar: FrostedSidebar!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		delegate = self
		tabBar.hidden = true
		
		moreNavigationController.navigationBar.hidden = true
        
        
		
		sidebar = FrostedSidebar(itemImages: [
			UIImage(named: "profile")!,
			UIImage(named: "gear")!,
            UIImage(named: "profile")!,
            ],
			colors: [
				UIColor(red: 240/255, green: 159/255, blue: 254/255, alpha: 1),
                UIColor(red: 240/255, green: 159/255, blue: 254/255, alpha: 1),
				UIColor(red: 119/255, green: 152/255, blue: 255/255, alpha: 1)
            ],
			selectionStyle: .Single)
		sidebar.actionForIndex = [
			0: {self.sidebar.dismissAnimated(true, completion: { finished in self.selectedIndex = 0}) },
			1: {self.sidebar.dismissAnimated(true, completion: { finished in self.selectedIndex = 1}) },
			2: {self.sidebar.dismissAnimated(true, completion: { finished in self.selectedIndex = 2}) }
        ]
	}
	
}

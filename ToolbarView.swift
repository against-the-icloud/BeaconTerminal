//
// Created by Anthony Perritano on 5/14/16.
// Copyright (c) 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Spring
import IBAnimatable
import RAMAnimatedTabBarController


class ToolbarView: UIView {

    @IBOutlet weak var mainTitleLabel: UILabel!
    
    
    @IBOutlet var profileView: SpringImageView!
    
    
       @IBOutlet weak var classLabel: UILabel!
       @IBOutlet weak var groupLabel: UILabel!
       @IBOutlet weak var titleLabel: UILabel!


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func updateToolbarColors(newColor: UIColor) {
        
        let newTextColor = UIColor(contrastingBlackOrWhiteColorOn:
            newColor, isFlat: true);
        LOG.debug(newTextColor.debugDescription)
        
        self.classLabel.textColor = newTextColor
        self.groupLabel.textColor = newTextColor
        self.titleLabel.textColor = newTextColor
//        self.profileView.backgroundColor = newTextColor
        self.backgroundColor = newColor

        getAppDelegate().tabController!.tabBar.barTintColor = newColor
        getAppDelegate().tabController!.tabBar.tintColor = UIColor.blackColor()
        
        getAppDelegate().tabController!.changeSelectedColor(UIColor.redColor(), iconSelectedColor: UIColor.redColor())
        let items = getAppDelegate().tabController!.tabBar.items as! [RAMAnimatedTabBarItem]
        for index in 0..<items.count {
            let item = items[index]
            
//            item.animation.textSelectedColor = UIColor.redColor()
//            item.animation.iconSelectedColor = UIColor.redColor()
            item.textColor = UIColor.blackColor()
            
            if item == getAppDelegate().tabController!.tabBar.selectedItem {
                item.selectedState()
            }
        }
//
//        for tab in tabItems {
//            let t = tab
//            t.textColor = UIColor.redColor()
//
//        }
//        
        
        
        


    }
    
    func updateProfileImage(index: Int) {
        
        var fileIndex = ""
        if index < 10 {
            fileIndex = "0\(index)"
        } else {
            fileIndex = "\(index)"
        }
        
        LOG.debug("INDEX \(fileIndex)")

        self.profileView.contentMode = .ScaleAspectFit
        self.profileView.image = UIImage(named: "species_\(fileIndex).png")
        
    }
}

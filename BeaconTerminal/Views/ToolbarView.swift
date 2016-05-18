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
    @IBOutlet weak var addButton: UIButton!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }


    func resetToolbarView() {
        self.addButton.tintColor = UIColor.whiteColor()
        self.classLabel.textColor = UIColor.whiteColor()
        self.groupLabel.textColor = UIColor.whiteColor()
        self.titleLabel.textColor = UIColor.whiteColor()
        self.backgroundColor = UIColor.blackColor()

        getAppDelegate().tabController!.tabBar.barTintColor = UIColor.blackColor()
        getAppDelegate().tabController!.tabBar.tintColor = UIColor.whiteColor()

        //        getAppDelegate().tabController!.changeSelectedColor(UIColor.redColor(), iconSelectedColor: UIColor.redColor())
        let items = getAppDelegate().tabController!.tabBar.items as! [RAMAnimatedTabBarItem]
        for index in 0..<items.count {
            let item = items[index]

            //            item.animation.textSelectedColor = UIColor.redColor()
            //            item.animation.iconSelectedColor = UIColor.redColor()
            item.iconColor = UIColor.whiteColor()
            item.textColor = UIColor.whiteColor()
            item.setTitleColor(UIColor.whiteColor(), forState: .Normal)

            if item == getAppDelegate().tabController!.tabBar.selectedItem {
                item.selectedState()
            } else {
                item.deselectAnimation()
            }
        }

    }

    func updateToolbarColors(baseColor: UIColor, newTextColor: UIColor) {

//        UIApplication.sharedApplication().st

        self.addButton.tintColor = newTextColor
        
        LOG.debug(newTextColor.debugDescription)
        
        self.classLabel.textColor = newTextColor
        self.groupLabel.textColor = newTextColor
        self.titleLabel.textColor = newTextColor
        //        self.profileView.backgroundColor = newTextColor
        self.backgroundColor = baseColor
        
        getAppDelegate().tabController!.tabBar.barTintColor = baseColor
        getAppDelegate().tabController!.tabBar.tintColor = UIColor.blackColor()
        
        //        getAppDelegate().tabController!.changeSelectedColor(UIColor.redColor(), iconSelectedColor: UIColor.redColor())
        let items = getAppDelegate().tabController!.tabBar.items as! [RAMAnimatedTabBarItem]
        for index in 0..<items.count {
            let item = items[index]
            
            //            item.animation.textSelectedColor = UIColor.redColor()
            //            item.animation.iconSelectedColor = UIColor.redColor()
            item.iconColor = newTextColor
            item.textColor = newTextColor
            item.setTitleColor(newTextColor, forState: .Normal)

            if item == getAppDelegate().tabController!.tabBar.selectedItem {
                item.selectedState()
            } else {
                item.deselectAnimation()
            }
        }
    }

    func promoteProfileView() {
        UIApplication.sharedApplication().keyWindow!.bringSubviewToFront(self)

        UIApplication.sharedApplication().keyWindow!.bringSubviewToFront(self.profileView)

    }
    
    func updateProfileImage(index: Int) {
        
        var fileIndex = ""
        var imageName = ""

        if index == -1 {
            imageName = "ic_question_mark"
            self.profileView.contentMode = .ScaleAspectFit

        } else {
            if index < 10 {
                fileIndex = "0\(index)"
                imageName = "species_\(fileIndex).png"
            } else {
                fileIndex = "\(index)"
                imageName = "species_\(fileIndex).png"
            }
            self.profileView.contentMode = .ScaleAspectFit
        }

        
        LOG.debug("INDEX \(fileIndex)")
        
        
        self.profileView.curve = Spring.AnimationCurve.EaseInOutCirc.rawValue
        
        self.profileView.animation = Spring.AnimationPreset.FlipY.rawValue
        self.profileView.duration = 0.3
        self.profileView.force = 3.8
        self.profileView.damping = 0.9
        self.profileView.velocity = 1.0
        self.profileView.animateToNext({

            self.profileView.image = UIImage(named: imageName)
        })
        
    }
}

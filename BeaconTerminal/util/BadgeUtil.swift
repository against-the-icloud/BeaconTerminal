//
//  BadgeUtil.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/12/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Material

enum BadgeTypes: String {
    case objectBadge, mapBadge, terminalBadge
}

class BadgeUtil {
    
    static let badgeTag = 99
    
    class func removeBadge() {
        for subView in (UIApplication.shared.keyWindow?.subviews)! {
            if subView.tag == badgeTag {
                subView.removeFromSuperview()
            }
        }
    }
    
    class func addGesture(gesture: UITapGestureRecognizer) {
        for subView in (UIApplication.shared.keyWindow?.subviews)! {
            if subView.tag == badgeTag {
                subView.addGestureRecognizer(gesture)
            }
        }

    }
    
    class func showBadge(withType type: BadgeTypes) {
        //remove the badgeSize
        BadgeUtil.removeBadge()
        
        let navHeight: CGFloat = 44.0
        let screenWidth = CGFloat(UIScreen.main.bounds.width)
        var cornerRadius: CGFloat = 10.0
        var badgeWidth: CGFloat = 75.0
        var badgeHeight: CGFloat = 75.0
        var badgeView: UIView?
        var imageName = ""
        var shouldPad = false
        
        var contentMode: UIViewContentMode?
        
        switch type {
        case .objectBadge:
            badgeWidth = 75.0
            badgeHeight = 75.0
            cornerRadius = badgeWidth / 2.0
            imageName = "tb_3d_object"
            contentMode = .scaleAspectFit
            shouldPad = false
            break
        case .mapBadge:
            //3:2 = 200:133
            badgeWidth = 150.0
            badgeHeight = 100.0
            cornerRadius = 0.0
            contentMode = .scaleAspectFit
            imageName = "floor_plan_science_lab"
            shouldPad = true
            break
        default:
            badgeWidth = 75.0
            badgeHeight = 75.0
            imageName = "tb_terminal"
            contentMode = .scaleAspectFit
            cornerRadius = badgeWidth / 2.0
            shouldPad = false
            break
        }
        
        
        let badgeCenter = CGPoint(x: (screenWidth - badgeWidth - 5.0), y: (navHeight + 20.0))
       
        badgeView = UIView(frame: CGRect(x: badgeCenter.x, y: badgeCenter.y, width: badgeWidth, height: badgeHeight))
        
        badgeView?.center = badgeCenter
        badgeView?.backgroundColor = Color.blue.base
        badgeView?.tag = badgeTag
        
        //round
        
        badgeView?.cornerRadius = Double(cornerRadius)
      
       // adjustedRect.origin.x = 0
        //adjustedRect.origin.y = 0
        
        if shouldPad {
            
            
            let borderView = UIView(frame: (badgeView?.bounds.insetBy(dx: 2.0, dy: 2.0))!)
            borderView.backgroundColor = UIColor.white
            
            badgeView?.addSubview(borderView)
            
            let imageView = UIImageView(frame: borderView.bounds.insetBy(dx: 2.0, dy: 2.0))
            
            imageView.backgroundColor = UIColor.white
            imageView.cornerRadius = Double(cornerRadius)
            imageView.image = UIImage(named: imageName)
            imageView.contentMode = contentMode!
            
            borderView.addSubview(imageView)
        } else {
            let imageCenter = CGPoint(x: badgeWidth/2.0, y: badgeHeight/2.0)
            let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: badgeWidth-5, height: badgeHeight-5))
            
            imageView.center = imageCenter
            imageView.backgroundColor = UIColor.white
            imageView.cornerRadius = Double(cornerRadius)
            imageView.image = UIImage(named: imageName)
            imageView.contentMode = contentMode!
            
            badgeView?.addSubview(imageView)
        }
     
        
        UIApplication.shared.keyWindow!.addSubview(badgeView!)
    }
}

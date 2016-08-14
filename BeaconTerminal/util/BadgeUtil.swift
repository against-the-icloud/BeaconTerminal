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
    
    class func showBadge(withType type: BadgeTypes) {
        //remove the badgeSize
        BadgeUtil.removeBadge()
        
        var imageName = ""
        
        switch type {
            
            
        case .objectBadge:
            imageName = "tb_3d_object"
            break
        case .mapBadge:
            imageName = "tb_map"
            break
        default:
            imageName = "tb_terminal"
            break
        }
        
        let badgeSize: CGFloat = 75.0
        let navHeight: CGFloat = 44.0
        
        let screenWidth = CGFloat(UIScreen.main.bounds.width)
        
        //plus status bar height
        let badgeCenter = CGPoint(x: (screenWidth - badgeSize - 5.0), y: (navHeight + 20.0))
        //
        let badgeView = UIView(frame: CGRect(x: badgeCenter.x, y: badgeCenter.y, width: badgeSize, height: badgeSize))
        badgeView.center = badgeCenter
        badgeView.backgroundColor = Color.blue.base
        badgeView.tag = badgeTag
        
        //round
        
        badgeView.cornerRadius = Double(badgeSize) / 2.0
        let insets = UIEdgeInsetsMake(5, 5, 5, 5);
        var adjustedRect = UIEdgeInsetsInsetRect(badgeView.frame, insets);
        adjustedRect.origin.x = 0
        adjustedRect.origin.y = 0
        
        let imageCenter = CGPoint(x: badgeSize/2.0, y: badgeSize/2.0)
        let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: badgeSize-10, height: badgeSize-10))
        
        imageView.center = imageCenter
        imageView.backgroundColor = UIColor.white
        imageView.cornerRadius = Double(badgeSize - 10) / 2.0
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFit
        
        badgeView.addSubview(imageView)
        
        UIApplication.shared.keyWindow!.addSubview(badgeView)
    }
}

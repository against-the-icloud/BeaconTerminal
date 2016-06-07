//
//  UINavigationBar+Height.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 5/22/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit

//private var AssociatedObjectHandle: UInt8 = 0
//
//extension UINavigationBar {
//    
//    var height: CGFloat {
//        get {
//            if let h = objc_getAssociatedObject(self, &AssociatedObjectHandle) as? CGFloat {
//                return h
//            }
//            return 0
//        }
//        set {
//            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
//    
//    override public func sizeThatFits(size: CGSize) -> CGSize {
//        if self.height > 0 {
//            return CGSizeMake(self.superview!.bounds.size.width, self.height);
//        }
//        return super.sizeThatFits(size)
//    }
//    
//}
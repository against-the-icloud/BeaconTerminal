//
//  GradientView.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/7/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class GradientView: UIView {
    @IBInspectable var startColor: UIColor = UIColor.white
    @IBInspectable var endColor: UIColor = UIColor.white
    
    override public class var layerClass: Swift.AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    override func layoutSubviews() {
        (layer as! CAGradientLayer).colors = [startColor.cgColor, endColor.cgColor]
    }
}


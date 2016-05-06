//
//  UIViewExtensions.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 4/27/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func makeCircular() {
        let cntr:CGPoint = self.center
        self.layer.cornerRadius = min(self.frame.size.height, self.frame.size.width) / 2.0
        self.center = cntr
        
        self.clipsToBounds = true
    }
}
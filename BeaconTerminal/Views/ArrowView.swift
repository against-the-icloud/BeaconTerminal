//
//  ArrowView.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/2/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit

class ArrowView: UIView {
    
    override func draw(_ rect: CGRect) {
        ArrowStyleKitName.drawArrow()
    }
}

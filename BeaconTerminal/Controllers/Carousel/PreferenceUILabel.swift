//
//  PreferenceUILabel.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/7/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class PreferenceUILabel: UILabel {
    
    @IBInspectable var preferenceType: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}

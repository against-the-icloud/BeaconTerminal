//
//  PreferenceTableCell.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/7/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class PreferenceTableViewCell: UITableViewCell {
    
    @IBInspectable var preferenceType: String?
    @IBOutlet var tickButton: UIButton!
    @IBOutlet var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

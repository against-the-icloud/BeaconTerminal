//
//  LoginConditionCell.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 9/16/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit

class LoginConditionCell : UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
}

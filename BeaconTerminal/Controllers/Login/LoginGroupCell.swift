//
//  LoginGroupCell.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/18/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit

class LoginGroupCell: UICollectionViewCell {
    

    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var groupMemberLabel: UILabel!
    
    static let reuseIdentifier = "loginGroupCell"
    
    var speciesIndex = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        prepareView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareView() {
        self.contentView.layer.cornerRadius = 10.0;
        self.contentView.layer.borderWidth = 1.0;
        self.contentView.layer.borderColor = UIColor.white.cgColor
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.9
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect:self.bounds, cornerRadius:self.contentView.layer.cornerRadius).cgPath
    }
}

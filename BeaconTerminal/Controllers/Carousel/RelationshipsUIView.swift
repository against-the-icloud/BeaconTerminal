//
//  RelationshipsUIView.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 7/10/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit

class RelationshipsUIView: UIView {
    
    @IBOutlet weak var dropView: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var anchorView: UIView!
    
    var fromSpecies : Species? {
        didSet {
            prepareAnchorView()
        }
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //prepareAnchorView()
    }
    
    func prepareAnchorView() {
        //rounded corners
        let cornerRadius = anchorView.frame.width / 2.0
        anchorView.layer.borderColor = self.backgroundColor?.CGColor
        anchorView.layer.borderWidth = 2.5
        anchorView.layer.masksToBounds = true
        anchorView.clipsToBounds = true
        anchorView.layer.cornerRadius = cornerRadius
        
        let newRect =  CGRectMake(0, 0, CGRectGetWidth(self.anchorView.frame), CGRectGetHeight(self.anchorView.frame))
        let path = UIBezierPath(roundedRect: CGRectInset(anchorView.bounds, 0.5, 0.5), cornerRadius: cornerRadius)
        let mask = CAShapeLayer()
        mask.frame = newRect
        mask.path = path.CGPath
        anchorView.layer.mask = mask
        
        
        //background color
        if let species = fromSpecies {
            anchorView.backgroundColor = UIColor(rgba: species.color)
        }
        
    }
}
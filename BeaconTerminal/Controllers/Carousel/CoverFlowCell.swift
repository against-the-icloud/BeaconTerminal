//
//  CoverFlowCell.swift
//  
//
//  Created by Anthony Perritano on 7/7/16.
//
//

import Foundation
import UIKit

class CoverFlowCell: UICollectionViewCell {
    
    @IBOutlet weak var testLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}


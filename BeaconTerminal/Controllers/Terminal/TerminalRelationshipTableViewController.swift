//
//  TerminalRelationshipTableViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/26/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit

class TerminalRelationshipTableViewController: UITableViewController {
    
    
    @IBOutlet weak var relationshipHeaderLabel: UILabel!
    @IBOutlet weak var relationshipReportLabel: UILabel!
    
    var relationshipType: RelationshipType?
    var relationshipResults: [RelationshipResult]? {
        didSet {
            //updateUI()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
    
    func prepareView() {
        //update title
        if let relationshipType = self.relationshipType {
            relationshipHeaderLabel.text = StringUtil.relationshipString(with: relationshipType)
        }
        
    
            for (index, cc) in self.childViewControllers.enumerated() {
                if let cc = cc as? TerminalCellController {
                    let disabledImage = RealmDataController.generateImageForSpecies(index, isHighlighted: false)
                    
                    cc.profileImageView.image = disabledImage
                    cc.view.alpha = 0.5
                }
                
                
                
                
            }
    
        
        
    }
}

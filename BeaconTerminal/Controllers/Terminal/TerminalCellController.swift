//
//  TerminalCellController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/26/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

struct CellItem {
    var group: Group?
    var relationship: Relationship?
}

class TerminalCellController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet var imageViewCells: [UIImageView]!
    
    var species: Species?
    var cellItems = [CellItem]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func prepareView(withSpecies species: Species) {
        self.species = species
        let disabledImage = RealmDataController.generateImageForSpecies(species.index, isHighlighted: false)
        
        profileImageView.image = disabledImage
        self.view.fadeIn(toAlpha: 0.3)
    }
    
    func updateCell(withGroup group: Group, andRelationship relationship: Relationship) {
        var cellItem = CellItem()
        cellItem.group = group
        cellItem.relationship = relationship
        cellItems.append(cellItem)
        
        if let species = self.species {
            let enabledImage = RealmDataController.generateImageForSpecies(species.index, isHighlighted: true)
            
            profileImageView.image = enabledImage
            
            if let attachment = relationship.attachments {
                let evidenceImage = UIImage(named: attachment)
                imageViewCells[group.index].image = evidenceImage
            } else {
                imageViewCells[group.index].backgroundColor = UIColor.red
            }
        }
        
        if self.view.alpha < 1.0 {
            self.view.fadeIn(toAlpha: 1.0)
        }
    }
    
    
}

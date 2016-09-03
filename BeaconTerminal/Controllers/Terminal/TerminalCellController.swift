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
    var relationshipType: RelationshipType?
}

class TerminalCellController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet var imageViewCells: [UIImageView]!
    @IBOutlet var tapCollection: [UITapGestureRecognizer]!
    
    var species: Species?
    var fromSpecies: Species?
    var cellItems = [CellItem]()
    var groups: List<Group>?
    var relationshipType: RelationshipType?
    
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
        for tap in tapCollection {
            tap.isEnabled = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "comparsionSegue":
            if let uinc = segue.destination as? UINavigationController, let tcvc = uinc.viewControllers.first as? TerminalComparsionController, let species = self.species, let fromSpecies = self.fromSpecies {
                
                //find all the relationships that have
                if !cellItems.isEmpty {
                    if (cellItems.first?.relationship?.relationshipType) != nil {
                        tcvc.cellItems = cellItems
                        tcvc.fromSpecies = fromSpecies
                        tcvc.species = species
                        tcvc.groups = groups
                        tcvc.relationshipType = relationshipType
                        
                        //tcvc.title = title
                        tcvc.navigationController?.navigationBar.tintColor = Util.flatBlack
                        tcvc.navigationItem.backBarButtonItem?.tintColor = UIColor.white
                        tcvc.doneButton.tintColor = UIColor.white
                        tcvc.navigationController?.toolbar.tintColor =  Util.flatBlack
                        
                    }
                    
                }
                
                
               
            }

            break
        default:
            print("you know nothing jon snow")
        }
    }
    
    func updateCell(withGroup group: Group, andRelationship relationship: Relationship, relationshipType: RelationshipType) {
        
        for tap in tapCollection {
            tap.isEnabled = true
        }
        
        var cellItem = CellItem()
        cellItem.group = group
        cellItem.relationship = relationship
        cellItem.relationshipType = relationshipType
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

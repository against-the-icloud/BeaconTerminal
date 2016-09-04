//
//  TerminalRelationshipTableViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/26/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class TerminalRelationshipTableViewController: UITableViewController {
    
    
    @IBOutlet weak var relationshipHeaderLabel: UILabel!
    @IBOutlet weak var relationshipReportLabel: UILabel!
    
    var relationshipType: RelationshipType?
    
    var groupReportCounts = [Int]()
    var relationshipCount = 0
    
    var speciesObservationResults: Results<SpeciesObservation>?
    
    var notificationToken: NotificationToken? = nil
    deinit {
        if notificationToken != nil {
            notificationToken?.stop()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNotifications()
    }
    
    func prepareNotifications() {
        speciesObservationResults = realm?.allObjects(ofType: SpeciesObservation.self)
        
        notificationToken = speciesObservationResults?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            
            guard let controller = self else { return }
            switch changes {
            case .Initial(let speciesObservationResults):
                controller.updateCells(withSpeciesObservationResults: speciesObservationResults)
                break
            case .Update(let speciesObservationResults, _, _, _):
                controller.updateCells(withSpeciesObservationResults: speciesObservationResults)
                break
            case .Error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
        
    }
    
    func updateCells(withSpeciesObservationResults speciesObservationResults: Results<SpeciesObservation>) {
        guard let type = relationshipType else {
            return
        }
        for so in speciesObservationResults {
            if let foundRelationships = realm?.relationships(withSpeciesObservation: so, withRelationshipType: type.rawValue) {
                
                if !groupReportCounts.contains(so.groupIndex) {
                    groupReportCounts.append(so.groupIndex)
                }
                
                relationshipCount += foundRelationships.count
                
                for r in foundRelationships {
                    updateCell(withRelationship: r, groupIndex: so.groupIndex)
                }
                
                updateReportLabel()
            }
        }
    }
    
    func updateCell(withRelationship relationship: Relationship, groupIndex: Int) {
        //find the controller with that species
   
        
        if let cells = self.childViewControllers as? [TerminalCellController] {
            
            //find the controller
            if let cell = cells.filter( { (c: TerminalCellController) -> Bool in
                if relationship.toSpecies != nil {
                    
                    guard let species = c.species else {
                        return false
                    }
                    
                    return species.index == relationship.toSpecies!.index
                }
                
                return false
                
            }).first {
                //update
                cell.updateCell(withGroupIndex: groupIndex, andRelationship: relationship)
            }
        }
    }
    
    // Mark: updates
    
    func updateHeader() {
        if let speciesIndex = realm?.runtimeSpeciesIndex() {
            relationshipHeaderLabel.backgroundColor = UIColor.speciesColor(forIndex: speciesIndex, isLight: false)
            relationshipHeaderLabel.borderColor = UIColor.speciesColor(forIndex: speciesIndex, isLight: true)
            prepareView()
        } else {
            relationshipHeaderLabel.backgroundColor = UIColor.black
            relationshipHeaderLabel.borderColor = UIColor.black
        }
    }
    
    func updateReportLabel() {
        if let groups = realm?.currentGroups() {
            
            if relationshipCount == 0 && groupReportCounts.count == 0 {
                relationshipReportLabel.text = "Nothing to report."
            } else {
                  relationshipReportLabel.text = "Reporting \(relationshipCount) relationships from \(groupReportCounts.count) of \(groups.count) groups"
            }
        }
    }
    
    // Mark: Prepare
    func prepareView() {
        
        if let currentSpeciesIndex = realm?.runtimeSpeciesIndex() {
            //update title
            if let relationshipType = self.relationshipType {
                relationshipHeaderLabel.text = StringUtil.relationshipString(withType: relationshipType)
            }
            
            guard let allSpecies = realm?.species else {
                return
            }
            
            var adder = 0
            for (index, cc) in self.childViewControllers.enumerated() {
                if let tcc = cc as? TerminalCellController {
                    
                    if index == currentSpeciesIndex {
                        adder = 1
                    } else {
                        adder = 0
                    }
                    
                    tcc.prepareView(withSpecies: allSpecies[index+adder])
                    
                }
            }
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier {
            switch segueId {
            case "embedCell":
                
                if let cellController = segue.destination as? TerminalCellController {
                    cellController.relationshipType = relationshipType
                }
                
                break
            default:
                break
            }
        }
    }
    
       

    
}

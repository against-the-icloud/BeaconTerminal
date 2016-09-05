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
    
    var groupsReported:[Int:Int] = [:]
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
        updateReportLabel(shouldReset: true)
        for so in speciesObservationResults {
            if let foundRelationships = realm?.relationships(withSpeciesObservation: so, withRelationshipType: type.rawValue) {
                
                
                relationshipCount += foundRelationships.count
                
                for r in foundRelationships {
                    groupsReported[so.groupIndex] = so.groupIndex

                    updateCell(withRelationship: r, groupIndex: so.groupIndex)
                }
                
            }
        }
        updateReportLabel(shouldReset: false)
    }
    
    func updateCell(withRelationship relationship: Relationship, groupIndex: Int) {
        //find the controller with that species            
        if let cells = self.childViewControllers as? [TerminalCellController] {
            
            //find the controller
            if let cell = cells.filter( { (terminalCell: TerminalCellController) -> Bool in
                
                    guard let relationshipToSpeciesIndex = relationship.toSpecies?.index else {
                        return false
                    }
                    
                    guard let cellSpeciesIndex = terminalCell.toSpeciesIndex else {
                        return false
                    }
                    
                    return cellSpeciesIndex == relationshipToSpeciesIndex                
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
    
    func updateReportLabel(shouldReset reset: Bool) {
        
        if reset {
            groupsReported = [:]
            relationshipCount = 0
            relationshipReportLabel.text = "Nothing to report."
            return
        }
        
        if let groups = realm?.currentGroups() {
            
            if relationshipCount == 0 && groupsReported.keys.count == 0 {
                relationshipReportLabel.text = "Nothing to report."
            } else {
              
                relationshipReportLabel.text = "Reporting \(relationshipCount) relationships from \(groupsReported.keys.count) of \(groups.count) groups"
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
            
            //make all the cells
            
            //create array with int 0...10
            var array = (0...allSpecies.count-1).map { $0 }
            
            array.remove(at: currentSpeciesIndex)
            
            for (index,speciesIndex) in array.enumerated() {
                if let cell = childViewControllers[index] as? TerminalCellController {
                    cell.toSpeciesIndex = speciesIndex
                }
            }
            
            
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier {
            switch segueId {
            case "embedCell":
                
//                if let cellController = segue.destination as? TerminalCellController {
//                    cellController.relationshipType = relationshipType
//                }
                
                break
            default:
                break
            }
        }
    }
    
    
    
    
}

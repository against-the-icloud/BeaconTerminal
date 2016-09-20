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
    var runtimeResults: Results<Runtime>?
    var runtimeNotificationToken: NotificationToken? = nil
    var speciesObsNotificationToken: NotificationToken? = nil
    
    var notificationTokens = [NotificationToken]()

    deinit {
        for notificationToken in notificationTokens {
            notificationToken.stop()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNotifications()
        
        //set up toast
        
        //dark grey
        UIView.hr_setToastThemeColor(UIColor.white)
    }
    
    func prepareNotifications() {
        
        runtimeResults = realmDataController.getRealm(withRealmType: RealmType.terminalDB).objects(Runtime.self)
        
        
        // Observe Notifications
        runtimeNotificationToken = runtimeResults?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            
            guard let tableController = self else { return }
            switch changes {
            case .initial(let runtimeResults):
                if let runtime = runtimeResults.first, let speciesIndex = runtime.currentSpeciesIndex.value {
                    tableController.updateHeader(withSpeciesIndex: speciesIndex)
                    tableController.updateReportLabel()
                }
                break
            case .update(let runtimeResults, _, _, _):
                if let runtime = runtimeResults.first, let speciesIndex = runtime.currentSpeciesIndex.value {
                    tableController.updateHeader(withSpeciesIndex: speciesIndex)
                    tableController.updateReportLabel()
                }
                break
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                LOG.error("\(error)")
                break
            }
        }
        
        if let n = runtimeNotificationToken {
            notificationTokens.append(n)
        }
        
        
        speciesObservationResults = realmDataController.getRealm(withRealmType: RealmType.terminalDB).objects(SpeciesObservation.self)
        
        speciesObsNotificationToken = speciesObservationResults?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            
            guard let controller = self else { return }
            switch changes {
            case .initial(let speciesObservationResults):
                controller.updateCells(withSpeciesObservationResults: speciesObservationResults)
                break
            case .update(let speciesObservationResults, _, _, _):
                controller.updateCells(withSpeciesObservationResults: speciesObservationResults)
                break
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
        
        
        if let s = speciesObsNotificationToken {
            notificationTokens.append(s)
        }

    }
    
    func updateCells(withSpeciesObservationResults speciesObservationResults: Results<SpeciesObservation>) {
        
        guard let type = relationshipType else {
            return
        }
        
        updateReportLabel(shouldReset: true)
        
        for so in speciesObservationResults {
            
          
            
            if let foundRelationships = realmDataController.getRealm(withRealmType: RealmType.terminalDB).relationships(withSpeciesObservation: so, withRelationshipType: type.rawValue) {
                
                
                relationshipCount += foundRelationships.count
                
                for r in foundRelationships {
                    groupsReported[so.groupIndex] = so.groupIndex

                    updateCell(withRelationship: r, groupIndex: so.groupIndex)
                }
                
            }
        }
        updateReportLabel(shouldReset: false)
    }
    
    func makeToast(relationship: Relationship, groupIndex: Int) {
        if let speciesName = relationship.toSpecies?.name, let speciesIndex = relationship.toSpecies?.index, let si = RealmDataController.generateImageForSpecies(speciesIndex, isHighlighted: true){
        
            
            Util.makeToast("Species Observation \(speciesName) from Group \(groupIndex)", title: "Update for Species Observation", image: si)
         
        }
    }
    
    func updateCell(withRelationship relationship: Relationship, groupIndex: Int) {
        
        
        makeToast(relationship: relationship, groupIndex: groupIndex)
        
        
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
    
    func updateHeader(withSpeciesIndex speciesIndex: Int) {
        if let speciesIndex = realmDataController.getRealm(withRealmType: RealmType.terminalDB).runtimeSpeciesIndex() {
            relationshipHeaderLabel.backgroundColor = UIColor.speciesColor(forIndex: speciesIndex, isLight: false)
            relationshipHeaderLabel.borderColor = UIColor.speciesColor(forIndex: speciesIndex, isLight: true)
            prepareView()
        } else {
            relationshipHeaderLabel.backgroundColor = UIColor.black
            relationshipHeaderLabel.borderColor = UIColor.black
        }
    }
    
    func updateReportLabel(shouldReset reset: Bool = true) {
        
        if reset {
            groupsReported = [:]
            relationshipCount = 0
            relationshipReportLabel.text = "Nothing to report."
            return
        }
        
        if let groups = realmDataController.getRealm(withRealmType: RealmType.terminalDB).currentGroups() {
            
            if relationshipCount == 0 && groupsReported.keys.count == 0 {
                relationshipReportLabel.text = "Nothing to report."
            } else {
              
                relationshipReportLabel.text = "Reporting \(relationshipCount) relationships from \(groupsReported.keys.count) of \(groups.count) groups"
            }
        }
    }
    
    // Mark: Prepare
    func prepareView() {
        
        if let currentSpeciesIndex = realmDataController.getRealm(withRealmType: RealmType.terminalDB).runtimeSpeciesIndex() {
            //update title
            if let relationshipType = self.relationshipType {
                relationshipHeaderLabel.text = StringUtil.relationshipString(withType: relationshipType)
            }
            
            let allSpecies = realmDataController.getRealm(withRealmType: RealmType.terminalDB).species            
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

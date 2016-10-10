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
        
        if needsTerminal {
        prepareNotifications()
        }
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
                    //tableController.updateReportLabel()
                }
                break
            case .update(let runtimeResults, _, _, _):
                if let runtime = runtimeResults.first, let speciesIndex = runtime.currentSpeciesIndex.value {
                    tableController.updateHeader(withSpeciesIndex: speciesIndex)
                    //tableController.updateReportLabel()
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
                self?.speciesObservationResults = speciesObservationResults                
                //clear all the cells
                controller.reloadCells()
                controller.updateCells(withSpeciesObservationResults: speciesObservationResults)
                break
            case .update(let speciesObservationResults, _, _, _):
                self?.speciesObservationResults = speciesObservationResults
                controller.reloadCells()
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
    
     @IBAction func reloadCells() {

        guard let type = relationshipType else {
            return
        }
        switch type {
        case .sPreference:
            
            for controller in (self.childViewControllers as? [TerminalCellController])!{
                controller.prepareView()
            }
            break
        default:
            
            for controller in (self.childViewControllers as? [TerminalCellController])!{
                controller.prepareView()
            }
            
        }
        //updateReportLabel(shouldReset: true)
    }
    
    func updateCells(withSpeciesObservationResults speciesObservationResults: Results<SpeciesObservation>) {
        
        self.speciesObservationResults = speciesObservationResults
        
        guard let type = relationshipType else {
            return
        }
        
        switch type {
        case .sPreference:
            
            for so in speciesObservationResults {
             
                
                    for sp in so.speciesPreferences {
                        groupsReported[so.groupIndex] = so.groupIndex
                        updateCell(withSpeciesPreference: sp, groupIndex: so.groupIndex)
                    }
                    
                }
        
            
            break
        default:
         
            
            for so in speciesObservationResults {
                if let foundRelationships = realmDataController.getRealm(withRealmType: RealmType.terminalDB).relationships(withSpeciesObservation: so, withRelationshipType: type.rawValue) {
                    relationshipCount += foundRelationships.count
                    for r in foundRelationships {
                        groupsReported[so.groupIndex] = so.groupIndex
                        updateCell(withRelationship: r, groupIndex: so.groupIndex)
                    }
                    
                }
            }
        }
        
        
  
        //updateReportLabel(shouldReset: false)
    }
    
    func makeToast(relationship: Relationship, groupIndex: Int) {
        if let speciesName = relationship.toSpecies?.name, let speciesIndex = relationship.toSpecies?.index, let si = RealmDataController.generateImageForSpecies(speciesIndex, isHighlighted: true){
        
            
            Util.makeToast("Species Observation \(speciesName) from Group \(groupIndex)", title: "Update for Species Observation", image: si)
         
        }
    }
    
    func makeToast(speciesPreference: SpeciesPreference, groupIndex: Int) {
        if let habitatName = speciesPreference.habitat?.name, let speciesIndex = speciesPreference.habitat?.name, let si = UIImage(named: habitatName) {
            
            
            Util.makeToast("Species Observation \(habitatName) from Group \(groupIndex)", title: "Update for Species Observation", image: si)
            
        }
    }
    
    func resetAllCells() {
        if let cells = self.childViewControllers as? [TerminalCellController] {
            for cell in cells {
                cell.prepareView()
            }
        }
    }
    
    
    func updateCell(withSpeciesPreference speciesPreference: SpeciesPreference, groupIndex: Int) {
        
        makeToast(speciesPreference: speciesPreference, groupIndex: groupIndex)
        
        
        //find the controller with that species
        if let cells = self.childViewControllers as? [TerminalCellController] {
            
            //find the controller
            if let cell = cells.filter( { (terminalCell: TerminalCellController) -> Bool in
                
                guard let habitatIndex = speciesPreference.habitat?.index else {
                    return false
                }
                
                guard let cellHabitatIndex = terminalCell.toHabitatIndex else {
                    return false
                }
                
                return cellHabitatIndex == habitatIndex
            }).first {
                //update
                cell.updateCell(withGroupIndex: groupIndex, andSpeciesPreference: speciesPreference)
                //cell.updateCell(withSpeciesPreference: speciesPreference, groupIndex: groupIndex)
            }
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
                cell.relationshipType = relationship.relationshipType
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
    
    // Mark: Prepare
    func prepareView() {
        
        guard let type = relationshipType else {
            return
        }
        
        switch type {
        case .sPreference:
            if let currentSpeciesIndex = realmDataController.getRealm(withRealmType: RealmType.terminalDB).runtimeSpeciesIndex() {
                //update title
                if let relationshipType = self.relationshipType {
                    relationshipHeaderLabel.text = StringUtil.relationshipString(withType: relationshipType)
                }
                
                let allHabitats = realmDataController.getRealm(withRealmType: RealmType.terminalDB).habitats
                //make all the cells
                
                for (index,_) in allHabitats.enumerated() {
                    if let cell = childViewControllers[index] as? TerminalCellController {
                        cell.toHabitatIndex = index
                    }
                }
                
                
            }
            
            
            break
        default:
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
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier {
            switch segueId {
            case "embedCell":
                
                if let cellController = segue.destination as? TerminalCellController {
                    cellController.view.setNeedsLayout()
                }
                
                break
            default:
                break
            }
        }
    }
}

//extension TerminalRelationshipTableViewController {
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        return nil
//    }
//}

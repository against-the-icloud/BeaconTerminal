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

enum UpdateType: String {
    case insert
    case update
    case delete
}


class SpeciesRelationshipTableController: UITableViewController {
    
    @IBOutlet weak var relationshipHeaderLabel: UILabel!
    @IBOutlet weak var addRelationshipButton: UIButton!
    
    var speciesIndex: Int?
    var relationshipType: RelationshipType?
    var speciesObservation: SpeciesObservation?
    var relationshipResults: Results<Relationship>?
    var relationshipNotification: NotificationToken? = nil
    
    var notificationTokens = [NotificationToken]()
    
    deinit {
        relationshipNotification?.stop()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateHeader()
        prepareNotifications()
    }
    
    func prepareNotifications() {
        
        if let speciesIndex = self.speciesIndex, let speciesObs = realm?.allSpeciesObservationsForCurrentSectionAndGroup(), let rType = self.relationshipType?.rawValue {
            
            if let so = speciesObs.filter(using: "fromSpecies.index = \(speciesIndex)").first {
                
                
                relationshipResults = so.relationships.filter(using: "relationshipType = '\(rType)'")
                relationshipNotification = relationshipResults?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
                    
                    guard let controller = self else { return }
                    switch changes {
                    case .Initial(let relationshipResults):
                        controller.updateCell(relationshipResults: relationshipResults)
                        break
                    case .Update(let relationshipResults, let deletions, let insertions, let modifications):
                        
                        controller.updateCell(relationshipResults: relationshipResults, type: .insert, indexes: insertions)
                        
                        controller.updateCell(relationshipResults: relationshipResults, type: .update, indexes: modifications)
                        
                        controller.updateCell(relationshipResults: relationshipResults, type: .delete, indexes: deletions)


                        break
                    case .Error(let error):
                        // An error occurred while opening the Realm file on the background worker thread
                        fatalError("\(error)")
                        break
                    }
                }

            } 
        }
    }
    
    func  updateCell(relationshipResults: Results<Relationship>) {
        for (index, relationship) in relationshipResults.enumerated() {
            for cell in (self.childViewControllers as? [SpeciesCellDetailController])! {
                if !cell.used {
                    cell.updateCell(withRelationship: relationship)
                    break
                }
            }
        }
    }
    
    func updateCell(relationshipResults: Results<Relationship>, type: UpdateType, indexes: [Int]) {
        switch type {
        case .insert:
            for index in indexes {
                
                //find the relationship
                let relationship = relationshipResults[index]
                
                for cell in (self.childViewControllers as? [SpeciesCellDetailController])! {
                    if !cell.used {
                        cell.updateCell(withRelationship: relationship)
                        break
                    }
                }
            }
            break
        case .update:
            for index in indexes {
                
                //find the relationship 
                let relationship = relationshipResults[index]
                
                //find that cell
                if let cell = self.childViewControllers[index] as? SpeciesCellDetailController {
                    cell.updateCell(withRelationship: relationship)
                }
            }
            break
        case .delete:
            if indexes.count > 0 {
                for cell in (self.childViewControllers as? [SpeciesCellDetailController])! {
                    cell.delete()
                }
                
                updateCell(relationshipResults: relationshipResults)
            }
            break
        default:
            break
        }
    }
    
    // Mark: updates
    func updateHeader() {
        if let speciesIndex = self.speciesIndex {
            relationshipHeaderLabel.backgroundColor = UIColor.speciesColor(forIndex: speciesIndex, isLight: false)
            relationshipHeaderLabel.borderColor = UIColor.speciesColor(forIndex: speciesIndex, isLight: false)
            self.tableView.borderColor = UIColor.speciesColor(forIndex: speciesIndex, isLight: false)
            prepareView()
        } else {
            relationshipHeaderLabel.backgroundColor = UIColor.black
            relationshipHeaderLabel.borderColor = UIColor.black
        }
    }
    
    // Mark: Prepare
    func prepareView() {
        guard let relationshipType = self.relationshipType else {
            return
        }
        
        
        let relationship = StringUtil.relationshipString(withType: relationshipType)
        
        
        relationshipHeaderLabel.text = relationship
        addRelationshipButton.setTitle("ADD \(relationshipType.rawValue.uppercased()) RELATIONSHIP",  for: [])
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier {
            switch segueId {
            case "editSpeciesSegue":
                
                if let uinav = segue.destination as? UINavigationController, let ev = uinav.viewControllers.first as? EvidenceSpeciesViewController, let speciesIndex = self.speciesIndex, let relationshipType = self.relationshipType, let cell = sender as? SpeciesCellDetailController, let foundRelationship = cell.relationship {
                    
                    ev.relationshipType = relationshipType
                    ev.fromSpeciesIndex = speciesIndex
                    ev.toSpeciesIndex = foundRelationship.toSpecies?.index
                    ev.relationship = foundRelationship
                    ev.title = "EDIT EVIDENCE"
                    ev.navigationItem.prompt = "SUPPORT THE '\(StringUtil.relationshipString(withType: relationshipType).uppercased()) RELATIONSHIP'"
                }
                
                
                
//                if let ev = segue.destination as? EvidenceSpeciesViewController, let speciesIndex = self.speciesIndex, let relationshipType = self.relationshipType, let speciesCell = sender as? LoginSpeciesCell {
//                    
//                    ev.relationshipType = relationshipType
//                    ev.fromSpeciesIndex = speciesIndex
//                    ev.toSpeciesIndex = speciesCell.speciesIndex
//                    
//                    ev.title = "2. ADD EVIDENCE"
//                    ev.navigationItem.prompt = "SUPPORT THE '\(StringUtil.relationshipString(withType: relationshipType).uppercased()) RELATIONSHIP'"
//                }

                break
            case "chooseSpeciesSegue":
                
                if let uinav = segue.destination as? UINavigationController, let csvc = uinav.viewControllers.first as? ChooseSpeciesViewController, let speciesIndex = self.speciesIndex, let relationshipType = self.relationshipType {
                    
                    csvc.relationshipType = relationshipType
                    csvc.speciesIndex = speciesIndex
                    csvc.title = "1. CHOOSE A SPECIES"
                    csvc.navigationItem.prompt = "CREATE '\(StringUtil.relationshipString(withType: relationshipType).uppercased()) RELATIONSHIP'"
                }
                break
            default:
                break
            }
        }
    }
}

extension SpeciesRelationshipTableController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = self.childViewControllers[indexPath.item] as? SpeciesCellDetailController {
            
            guard let r = cell.relationship else {
                return
            }
            
            performSegue(withIdentifier: "editSpeciesSegue", sender: cell)
        }
    }
    
}


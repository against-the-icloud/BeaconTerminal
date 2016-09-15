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
            if let cell = self.childViewControllers[index] as? SpeciesCellDetailController {
                cell.updateCell(withRelationship: relationship)
            }
        }
    }
    
    func updateCell(relationshipResults: Results<Relationship>, type: UpdateType, indexes: [Int]) {
        switch type {
        case .insert:
            for index in indexes {
                
                //find the relationship
                let relationship = relationshipResults[index]
                
                if let cell = self.childViewControllers[index] as? SpeciesCellDetailController {
                    cell.updateCell(withRelationship: relationship)
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
            for index in indexes {
                if let cell = self.childViewControllers[index] as? SpeciesCellDetailController {
                    let relationship = relationshipResults[index]
                    cell.delete()
                }
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
            case "embedCell":
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

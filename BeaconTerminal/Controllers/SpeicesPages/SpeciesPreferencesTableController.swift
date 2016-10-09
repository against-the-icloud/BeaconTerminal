//
//  SpeciesPreferencesTableController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 10/7/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class SpeciesPreferencesTableController: UITableViewController {
    
    @IBOutlet weak var relationshipHeaderLabel: UILabel!
    @IBOutlet weak var addRelationshipButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    
    var speciesIndex: Int?
    var speciesObservation: SpeciesObservation?
    var speciesPreferenceResults: List<SpeciesPreference>?
    var speciesPreferenceNotification: NotificationToken? = nil
    
    var notificationTokens = [NotificationToken]()
    
    deinit {
        speciesPreferenceNotification?.stop()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateHeader()
        prepareNotifications()
        
        tableView.estimatedRowHeight = 87
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let rowheight = (tableView.height - 80.0)/9
        
        return rowheight;
    }
    
    func prepareNotifications() {
        
        if let speciesIndex = self.speciesIndex, let speciesObs = realm?.allSpeciesObservationsForCurrentSectionAndGroup() {
            
            if let so = speciesObs.filter("fromSpecies.index = \(speciesIndex)").first {
                
                speciesPreferenceNotification = so.speciesPreferences.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
                    
                    guard let controller = self else { return }
                    switch changes {
                    case .initial(let speciesPreferenceResults):
                        controller.updateCell(speciesPreferenceResults: speciesPreferenceResults)
                        break
                    case .update(let speciesPreferenceResults, let deletions, let insertions, let modifications):
                        
                        controller.updateCell(speciesPreferenceResults: speciesPreferenceResults, type: .insert, indexes: insertions)
                        
                        controller.updateCell(speciesPreferenceResults: speciesPreferenceResults, type: .update, indexes: modifications)
                        controller.updateCell(speciesPreferenceResults: speciesPreferenceResults, type: .delete, indexes: deletions)
                        break
                    case .error(let error):
                        // An error occurred while opening the Realm file on the background worker thread
                        fatalError("\(error)")
                        break
                    }
                }
                
            }
        }
    }
    
    func  updateCell(speciesPreferenceResults: List<SpeciesPreference>) {
        for (_, relationship) in speciesPreferenceResults.enumerated() {
            for cell in (self.childViewControllers as? [SpeciesCellDetailController])! {
                if !cell.used {
                    //cell.updateCell(withRelationship: relationship)
                    break
                }
            }
        }
    }
    
    func updateCell(speciesPreferenceResults: List<SpeciesPreference>, type: UpdateType, indexes: [Int]) {
        switch type {
        case .insert:
            for index in indexes {
                
                //find the relationship
                let speciesPreference = speciesPreferenceResults[index]
                
                for cell in (self.childViewControllers as? [SpeciesCellDetailController])! {
                    if !cell.used {
                        //cell.updateCell(withRelationship: relationship)
                        break
                    }
                }
            }
            break
        case .update:
            for index in indexes {
                
                //find the relationship
                let speciesPreference = speciesPreferenceResults[index]
                
                //find that cell
                if let cell = self.childViewControllers[index] as? SpeciesCellDetailController {
                    //cell.updateCell(withRelationship: relationship)
                }
            }
            break
        case .delete:
            if indexes.count > 0 {
                for cell in (self.childViewControllers as? [SpeciesCellDetailController])! {
                    cell.delete()
                }
                
                updateCell(speciesPreferenceResults: speciesPreferenceResults)
            }
            break
        }
    }
    
    // Mark: updates
    func updateHeader() {
        if let speciesIndex = self.speciesIndex {
            headerView.backgroundColor = UIColor.speciesColor(forIndex: speciesIndex, isLight: false)
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
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier {
            switch segueId {
            case "editPreferenceSegue":
                
                if let uinav = segue.destination as? UINavigationController, let ev = uinav.viewControllers.first as? ChoosePreferencesViewController, let speciesIndex = self.speciesIndex, let cell = sender as? SpeciesCellDetailController {
                    
                    //                        ev.fromSpeciesIndex = speciesIndex
                    //                        ev.toSpeciesIndex = foundRelationship.toSpecies?.index
                    //                        ev.relationship = foundRelationship
                    //                        ev.deleteButton.isEnabled = true
                    //                        ev.title = "EDIT EVIDENCE"
                    //                        ev.preferredContentSize = CGSize(width: 1000, height: 675)
                    //                        //  ev.navigationItem.prompt = "SUPPORT THE '\(StringUtil.relationshipString(withType: relationshipType).uppercased())' RELATIONSHIP"
                }
                break
            case "choosePreferenceSegue":
                
                if let uinav = segue.destination as? UINavigationController {
                    
                    if let csvc = uinav.viewControllers.first as? ChoosePreferencesViewController {
                        
                        if let speciesIndex = self.speciesIndex {
                            
                            csvc.speciesIndex = speciesIndex
                            csvc.title = "CREATE A PREFERENCE"
                        }
                    }
                }
                break
            default:
                break
            }
        }
    }
}

extension SpeciesPreferencesTableController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = self.childViewControllers[indexPath.item] as? SpeciesCellDetailController {
            
            guard cell.relationship != nil else {
                return
            }
            
            performSegue(withIdentifier: "editSpeciesSegue", sender: cell)
        }
    }
    
}


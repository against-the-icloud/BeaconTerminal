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
        for (_, speciesPreference) in speciesPreferenceResults.enumerated() {
            for cell in (self.childViewControllers as? [SpeciesCellDetailController])! {
                if !cell.used {
                    cell.updateCell(withSpeciesPreference: speciesPreference)
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
                        cell.updateCell(withSpeciesPreference: speciesPreference)
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
                    cell.updateCell(withSpeciesPreference: speciesPreference)

                }
            }
            break
        case .delete:
            if indexes.count > 0 {
                for cell in (self.childViewControllers as? [SpeciesCellDetailController])! {
                    cell.deleteSpeciesPreference()
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
                
                if let uinav = segue.destination as? UINavigationController, let ev = uinav.viewControllers.first as? EvidencePreferenceViewController, let speciesIndex = self.speciesIndex, let cell = sender as? SpeciesCellDetailController, let foundSpeciesPreference = cell.speciesPreference {
                    
                    ev.fromSpeciesIndex = speciesIndex
                    ev.speciesPreference = foundSpeciesPreference
                    ev.habitatIndex = foundSpeciesPreference.habitat?.index
                    ev.deleteButton.isEnabled = true
                    ev.title = "EDIT PREFERENCE"
                    ev.preferredContentSize = CGSize(width: 1000, height: 675)
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
            
            guard cell.speciesPreference != nil else {
                return
            }
            
            performSegue(withIdentifier: "editPreferenceSegue", sender: cell)
        }
    }
    
}



//
//  SpeciesPageViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 9/9/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class SpeciesPageContentController: UIViewController {
    
    var speciesIndex: Int?
    var speciesObservation: SpeciesObservation?
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tabSegmentedControl: UISegmentedControl!
    @IBOutlet weak var speciesLabel: UILabel!
    @IBOutlet weak var speciesProfileImageView: UIImageView!
    @IBOutlet weak var cloudSyncButton: UIButton!
    
    var speciesObservationResults: Results<SpeciesObservation>?
    var shouldSync: Results<SpeciesObservation>?
    
    var speciesObsNotificationToken: NotificationToken? = nil
    var syncNotificationToken: NotificationToken? = nil
    
    deinit {
        speciesObsNotificationToken?.stop()
        syncNotificationToken?.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateHeader()
        prepareNotifications()
        
        switch getAppDelegate().checkApplicationState() {
        case .cloudGroup:
            cloudSyncButton.isHidden = false
        case .objectGroup:
            cloudSyncButton.setImage(nil, for: .normal)
            //cloudSyncButton.removeTarget(nil, action: nil, for: .allEvents)
            prepareHeaderActions()
        case .placeGroup:
            cloudSyncButton.setImage(nil, for: .normal)
            cloudSyncButton.removeTarget(nil, action: nil, for: .allEvents)
            prepareManualSyncActions()
        default:
            break
        }
        
        
    }
    
    
    
    func prepareNotifications() {
        if let allSO = realm?.allSpeciesObservationsForCurrentSectionAndGroup(), let speciesIndex = speciesIndex{
            shouldSync = allSO.filter("fromSpecies.index = \(speciesIndex) AND isSynced = false")
            
            if let shouldSync = shouldSync {
                syncNotificationToken = shouldSync.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
                    
                    guard let controller = self else { return }
                    switch changes {
                    case .initial(let speciesObservationResults):
                        controller.updateHeader()
                        
                        if !speciesObservationResults.isEmpty {
                            controller.colors(forSynced: false)
                        } else {
                            controller.colors(forSynced: true)
                        }
                        break
                    case .update( _, let deletions, _, _):
                        controller.updateHeader()
                        
                        if deletions.count > 0 {
                            controller.colors(forSynced: true)
                        } else {
                            controller.colors(forSynced: false)
                        }
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
    
    func colors(forSynced synced: Bool) {
        if synced {
            contentView.borderColor = #colorLiteral(red: 0.3035082817, green: 0.3933896124, blue: 0.4837856293, alpha: 1)
            contentView.backgroundColor = UIColor.white
            speciesLabel.textColor = UIColor.black
        } else {
            contentView.borderColor = #colorLiteral(red: 0.996078372, green: 0.9137254953, blue: 0.3058823943, alpha: 1)
            contentView.backgroundColor = #colorLiteral(red: 0.996078372, green: 0.9674537485, blue: 0.7561766128, alpha: 1)
            speciesLabel.textColor = UIColor.black
            
            //force synce in place condition
            switch getAppDelegate().checkApplicationState() {
            case .placeGroup:
                if let speciesIndex = self.speciesIndex {
                    if entered.contains(speciesIndex) {
                        realmDataController.syncSpeciesObservations(withSpeciesIndex: speciesIndex, withCondition: getAppDelegate().checkApplicationState().rawValue, withActionType: "enter", withPlace: "species:\(speciesIndex)")
                    }
                }
            default:
                break
            }
        }
        
  
        
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let id = segue.identifier else {
            return
        }
        
        switch id {
        case "relationshipsViewSegue":
            if let srv = segue.destination as? SpeciesRelationshipContainerController {
                srv.speciesIndex = speciesIndex
            }
            break
        default:
            break
        }
    }
    
    // Mark: Views
    
    func updateHeader() {
        if let speciesIndex = self.speciesIndex {
            speciesProfileImageView.image = RealmDataController.generateImageForSpecies(speciesIndex, isHighlighted: true)
            
            if let species = realm?.speciesWithIndex(withIndex: speciesIndex) {
                speciesLabel.text = species.name
            }
            contentView.borderColor = #colorLiteral(red: 0.01405510586, green: 0.6088837981, blue: 0.6111404896, alpha: 1)
        } else {
            //no species image
        }
        
        //updateTimestamp()
    }
    
    func prepareManualSyncActions() {
        speciesProfileImageView.isUserInteractionEnabled = true
        //now you need a tap gesture recognizer
        //note that target and action point to what happens when the action is recognized.
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doManualSyncAction))
        //Add the recognizer to your view.
        speciesProfileImageView.addGestureRecognizer(tapRecognizer)
    }
    
    func prepareHeaderActions() {
        speciesProfileImageView.isUserInteractionEnabled = true
        //now you need a tap gesture recognizer
        //note that target and action point to what happens when the action is recognized.
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doTerminalForCurrentSpeciesAction))
        //Add the recognizer to your view.
        speciesProfileImageView.addGestureRecognizer(tapRecognizer)
    }
    
    func doManualSyncAction(_ sender: UITapGestureRecognizer) {
        if let speciesIndex = self.speciesIndex {
            
            realmDataController.syncSpeciesObservations(withSpeciesIndex: speciesIndex, withCondition: getAppDelegate().checkApplicationState().rawValue, withActionType: "enter", withPlace: "species:\(speciesIndex)")
        }
    }
    
    @IBAction func doCloudSync(_ sender: Any) {
        doTerminalForCurrentSpeciesAction(sender)
    }
    
    func doTerminalForCurrentSpeciesAction(_ sender: Any) {
        
        if let speciesIndex = self.speciesIndex {
            
            let condition = getAppDelegate().checkApplicationState().rawValue
            
            
            realmDataController.syncSpeciesObservations(withSpeciesIndex: speciesIndex, withCondition: condition, withActionType: "enter", withPlace: "species:\(speciesIndex)")
            
            
            realmDataController.clearInViewTerminal(withCondition: condition)
            realmDataController.updateInViewTerminal(withSpeciesIndex: speciesIndex, withCondition: condition, withPlace: "species:\(speciesIndex)")
            
        }
        
    }
    
    // Mark: Actions
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}


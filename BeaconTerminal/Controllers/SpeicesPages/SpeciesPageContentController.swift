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
    @IBOutlet var subpageContainerViews: [UIView]!

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
    }
    
    func prepareNotifications() {
        if let allSO = realm?.allSpeciesObservationsForCurrentSectionAndGroup(), let speciesIndex = speciesIndex{
            shouldSync = allSO.filter(using: "fromSpecies.index = \(speciesIndex) AND isSynced = false")
            
            if let shouldSync = shouldSync {
                    syncNotificationToken = shouldSync.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
                
                    guard let controller = self else { return }
                    switch changes {
                    case .Initial(let speciesObservationResults):
                        if !speciesObservationResults.isEmpty {
                            controller.colors(forSynced: false)
                        } else {
                            controller.colors(forSynced: true)
                        }
                        break
                    case .Update(let speciesObservationResults, let deletions, let insertions, let modifications):
                        
                        if deletions.count > 0 {
                            controller.colors(forSynced: true)
                        } else {
                            controller.colors(forSynced: false)
                        }
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
    
    func colors(forSynced synced: Bool) {
        if synced {
            contentView.borderColor = UIColor.speciesColor(forIndex: speciesIndex!, isLight: false)
            contentView.backgroundColor = UIColor.white
            tabSegmentedControl.tintColor = UIColor.black
            speciesLabel.textColor = UIColor.black
        } else {
            contentView.borderColor = UIColor.red
            contentView.backgroundColor = #colorLiteral(red: 0.9994968772, green: 0.8941870332, blue: 0.962585628, alpha: 1)
            tabSegmentedControl.tintColor = UIColor.black
            speciesLabel.textColor = UIColor.black
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
        case "preferencesViewSegue":
            break
        case "experimentsViewSegue":
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
            contentView.borderColor = UIColor.speciesColor(forIndex: speciesIndex, isLight: false)
        } else {
            //no species image
        }
    
        //updateTimestamp()
    }
    
    @IBAction func subpageSelection(_ sender: UISegmentedControl) {
        
        let showView = subpageContainerViews[sender.selectedSegmentIndex]
        
        for (index,containerView) in subpageContainerViews.enumerated() {
            if index == sender.selectedSegmentIndex {
                containerView.isHidden = false
                containerView.fadeIn(toAlpha: 1.0) {_ in
                    
                }
                
            } else {
                containerView.isHidden = true
                containerView.fadeOut(0.0) {_ in
                    
                }
            }
        }
        
        
        showView.fadeIn(toAlpha: 1.0) {_ in

        }
    }
    
}


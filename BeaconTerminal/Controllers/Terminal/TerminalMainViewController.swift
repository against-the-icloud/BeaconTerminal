//
//  TerminalViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/18/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Photos
import MobileCoreServices
import Nutella

class TerminalMainViewController: UIViewController {
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    @IBOutlet weak var viewSegmentedControl: UISegmentedControl!
    
    @IBOutlet var containerViews: [UIView]!
    
    var notificationTokens = [NotificationToken]()
    
    var runtimeResults: Results<Runtime>?
    var runtimeNotificationToken: NotificationToken? = nil
    var speciesObsNotificationToken: NotificationToken? = nil
    var speciesObservationResults: Results<SpeciesObservation>?
    
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
    }
    
    // Mark: Prepare
    
    func prepareNotifications() {
        runtimeResults = realmDataController.getRealm(withRealmType: RealmType.terminalDB).objects(Runtime.self)
        
        
        // Observe Notifications
        runtimeNotificationToken = runtimeResults?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            
            guard let terminalController = self else { return }
            switch changes {
            case .initial(let runtimeResults):
                //we have nothing
                if runtimeResults.isEmpty {
                    //terminalController.showLogin()
                } else {
                    terminalController.updateHeader()
                }
                break
            case .update( _, _, _, _):
                LOG.debug("UPDATE Runtime -- TERMINAL")
                terminalController.updateHeader()
                //terminalController.updateUI(withRuntimeResults: runtimeResults)
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
            case .initial( _):
                controller.updateTimestamp()
                break
            case .update( _, _, _, _):
                controller.updateTimestamp()
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
    
    // Mark: Update UI
    
    func updateHeader() {
        if let speciesIndex = realmDataController.getRealm(withRealmType: RealmType.terminalDB).runtimeSpeciesIndex() {
            profileImageView.image = RealmDataController.generateImageForSpecies(speciesIndex, isHighlighted: true)
            
            if let species = realmDataController.getRealm(withRealmType: RealmType.terminalDB).speciesWithIndex(withIndex: speciesIndex) {
                profileLabel.text = species.name
            }
            
            viewSegmentedControl.tintColor = UIColor.speciesColor(forIndex: speciesIndex, isLight: false)
        } else {
            //no species image
        }
        
        if let sectionName = realmDataController.getRealm(withRealmType: RealmType.terminalDB).runtimeSectionName() {
            sectionLabel.text = sectionName
        } else {
            sectionLabel.text = "XYZ"
        }
        updateTimestamp()
    }
    
    func updateTimestamp(withDate date: Date = Date()) {
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = DateFormatter.Style.short
        dateformatter.timeStyle = DateFormatter.Style.short
        
        timestampLabel.text = dateformatter.string(from: date)
    }
    
    
    func showLogin() {
        let storyboard = UIStoryboard(name: "Popover", bundle: nil)
        let loginNavigationController = storyboard.instantiateViewController(withIdentifier: "loginNavigationController") as! UINavigationController
        
        if let loginSectionViewController = loginNavigationController.viewControllers[0] as? LoginSectionViewController {
            loginSectionViewController.loginType = groupType.species
        }
        
        self.present(loginNavigationController, animated: true, completion: {})
    }
    
    //Mark: Segment Switch
    
    @IBAction func switchSegment(_ sender: UISegmentedControl) {
        
        let showView = containerViews[sender.selectedSegmentIndex]
        
        for (index,containerView) in containerViews.enumerated() {
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
        
        //var filtered = myList.filter { $0 != sender.selectedSegmentIndex }
        
        showView.fadeIn(toAlpha: 1.0) {_ in
            //            for tap in self.tapCollection {
            //                tap.isEnabled = false
           
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let id = segue.identifier else {
            return
        }
        
        switch id {
        case "terminalPreferencesViewSegue":
            if let srv = segue.destination as? TerminalPreferenceComparsionController, let speciesIndex = realmDataController.getRealm().runtimeSpeciesIndex() {
                srv.speciesIndex = speciesIndex
            }
            break
        default:
            break
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

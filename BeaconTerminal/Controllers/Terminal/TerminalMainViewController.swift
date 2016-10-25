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
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var topTabbar: TabSegmentedControl!
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
        topTabbar.initUI()
        if needsTerminal {
            prepareNotifications()
        }
    }
    
    // MARK: Prepare
    
    func prepareNotifications() {
        runtimeResults = realmDataController.getRealm(withRealmType: RealmType.terminalDB).objects(Runtime.self)
        
        
        // Observe Notifications
        runtimeNotificationToken = runtimeResults?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            
            guard let terminalController = self else { return }
            switch changes {
            case .initial(let runtimeResults):
                //we have nothing
                terminalController.updateHeader()

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
    
    // MARK: Update UI
    
    func updateHeader() {
        if let speciesIndex = realmDataController.getRealm(withRealmType: RealmType.terminalDB).runtimeSpeciesIndex() {
            profileImageView.image = RealmDataController.generateImageForSpecies(speciesIndex, isHighlighted: true)
            
            if let species = realmDataController.getRealm(withRealmType: RealmType.terminalDB).speciesWithIndex(withIndex: speciesIndex) {
                profileLabel.text = species.name
            }
        } else {
            //no species image
        }
        
        switch getAppDelegate().checkApplicationState() {
        case .objectGroup, .cloudGroup:
            if let sectionName = realmDataController.getRealm(withRealmType: RealmType.terminalDB).runtimeSectionName() {
                sectionLabel.text = ""
            } else {
                sectionLabel.text = ""
            }
            bannerView.backgroundColor = UIColor.clear
        default:
            if let sectionName = realmDataController.getRealm(withRealmType: RealmType.terminalDB).runtimeSectionName() {
                sectionLabel.text = sectionName.uppercased()
            } else {
                sectionLabel.text = "XYZ"
            }
        }
        
        
        colorizeSelectedSegment()        
        updateTimestamp()
    }
    
    func updateTimestamp(withDate date: Date = Date()) {
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = DateFormatter.Style.short
        dateformatter.timeStyle = DateFormatter.Style.short
        
        timestampLabel.text = dateformatter.string(from: date)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let id = segue.identifier else {
            return
        }
        
        switch id {
        case "terminalPreferencesViewSegue":           
            break
        default:
            break
        }
    }
    
    // MARK: Tab
    
    func colorizeSelectedSegment() {
        let sortedViews = topTabbar.subviews.sorted( by: { $0.frame.origin.x < $1.frame.origin.x } )
        
        for (index, view) in sortedViews.enumerated() {
            if index == topTabbar.selectedSegmentIndex {
                
                view.backgroundColor = UIColor.black
                
                
            } else {
                
                view.backgroundColor = #colorLiteral(red: 0.01405510586, green: 0.6088837981, blue: 0.6111404896, alpha: 1)
                
            }
        }
    }

    
    func changeTab(withControl tabbar: UISegmentedControl) {
        
            let selected =  tabbar.selectedSegmentIndex
        
            for (index,containerView) in containerViews.enumerated() {
                
                switch selected {
                case index:
                    containerView.alpha = 0.0
                    containerView.isHidden = false
                    containerView.fadeIn(toAlpha: 1.0) {_ in
                        containerView.isHidden = false
                    }
                default:
                    containerView.fadeOut(0.0) {_ in
                        containerView.isHidden = true
                    }
                }
            }
        
    }

    
    // MARK: actions

    
    @IBAction func tabChanged(_ sender: UISegmentedControl) {
        colorizeSelectedSegment()
        changeTab(withControl: sender)
    }
    
    @IBAction func refreshAction(_ sender: Any) {
        
        getAppDelegate().refreshTerminalConnection()

        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

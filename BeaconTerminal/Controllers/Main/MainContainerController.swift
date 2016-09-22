//
//  MainContainerController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 9/8/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

@objc protocol TopToolbarDelegate {
    func changeAppearance(withColor color: UIColor)
}

class MainContainerController: UIViewController{
    @IBOutlet var containerViews: [UIView]!
    
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var topTabbar: TabSegmentedControl!
    @IBOutlet weak var topPanel: UIView!
    @IBOutlet weak var badgeImageView: UIImageView!
    
    var notificationTokens = [NotificationToken]()
    var runtimeResults: Results<Runtime>?
    var terminalRuntimeResults: Results<Runtime>?
    var runtimeNotificationToken: NotificationToken? = nil
    var terminalRuntimeNotificationToken: NotificationToken? = nil

    
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
        prepareNotifications()
        prepareTerminalNotifications()
    }
    
    func prepareNotifications() {
        runtimeResults = realmDataController.getRealm().objects(Runtime.self)
        
        
        // Observe Notifications
        runtimeNotificationToken = runtimeResults?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            
            guard let mainController = self else { return }
            switch changes {
            case .initial(let runtimeResults):
                //we have nothing
                if runtimeResults.isEmpty {
                    //mainController.showLogin()
                } else {
                    mainController.updateHeader()
                    //mainController.showLogin()
                }
                break
            case .update( _, _, _, _):
                LOG.debug("UPDATE Runtime -- TERMINAL")
                mainController.updateHeader()
                //terminalController.updateUI(withRuntimeResults: runtimeResults)
                break
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                LOG.error("\(error)")
                break
            }
        }
    }
    
    func prepareTerminalNotifications() {
        terminalRuntimeResults = realmDataController.getRealm(withRealmType: RealmType.terminalDB).objects(Runtime.self)
        
        
        // Observe Notifications
        terminalRuntimeNotificationToken = terminalRuntimeResults?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            
            guard let mainController = self else { return }
            switch changes {
            case .initial(let terminalRuntimeResults):
                //we have nothing
                if terminalRuntimeResults.isEmpty {
                    //mainController.showLogin()
                } else {
                    mainController.updateTabs(terminalRuntimeResults: terminalRuntimeResults)
                }
                break
            case .update(let terminalRuntimeResults, _, _, _):
                LOG.debug("UPDATE terminal Runtime -- TERMINAL RESULTS")
                mainController.updateTabs(terminalRuntimeResults: terminalRuntimeResults)
                //terminalController.updateUI(withRuntimeResults: runtimeResults)
                break
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                LOG.error("\(error)")
                break
            }
        }
    }
    
    func updateHeader() {
        if let sectionName = realmDataController.getRealm().runtimeSectionName() {
            sectionLabel.text = "\(sectionName)"
        }
        
        if let groupIndex = realmDataController.getRealm().runtimeGroupIndex(), let sectionName = realmDataController.getRealm().runtimeSectionName(), let group = realmDataController.getRealm().group(withSectionName: sectionName, withGroupIndex: groupIndex), let groupName = group.name {
            topTabbar.setTitle("\(groupName.uppercased()) SPECIES ACCOUNTS", forSegmentAt: 0)
        }
        
        switch getAppDelegate().checkApplicationState() {
        case .objectGroup:
            badgeImageView.image = UIImage(named: "objectGroup")
        default:
            badgeImageView.image = UIImage(named: "placeGroup")
        }
        
    }
    
    func updateTabs(terminalRuntimeResults: Results<Runtime>) {
        
        
        
        if let terminalRuntime = terminalRuntimeResults.first, let speciesIndex = terminalRuntime.currentSpeciesIndex.value, let sectionName = terminalRuntime.currentSectionName, let action = terminalRuntime.currentAction {
            
            if let atype = ActionType(rawValue: action) {
                
                switch atype {
                case ActionType.entered:
                    topTabbar.insertSegment(withTitle: "\(sectionName) Species \(speciesIndex)", at: 2, animated: true)
                    realmDataController.queryNutellaAllNotes(withType: "species", withRealmType: RealmType.terminalDB)
                default:
                    topTabbar.removeSegment(at: 2, animated: true)
                }
                
            }
            
        }
    }
    
    func showLogin() {
        let storyboard = UIStoryboard(name: "Popover", bundle: nil)
        let loginNavigationController = storyboard.instantiateViewController(withIdentifier: "loginNavigationController") as! UINavigationController
        
        self.present(loginNavigationController, animated: true, completion: {})
    }
    @IBAction func tabChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex < containerViews.count {
        
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
        

        showView.fadeIn(toAlpha: 1.0) {_ in
            //            for tap in self.tapCollection {
            //                tap.isEnabled = false
            
        }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let id = segue.identifier else {
            return
        }
        
            switch id {
            case "speciesPageContainerController":
                if let svc = segue.destination as? SpeciePageContainerController {
                    svc.topToolbarDelegate = self
                }
                break
            default:
                break
            }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension MainContainerController: TopToolbarDelegate {
    func changeAppearance(withColor color: UIColor) {        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.topTabbar.backgroundColor = color
            self.topPanel.backgroundColor = color
            }, completion: nil)
    }
}

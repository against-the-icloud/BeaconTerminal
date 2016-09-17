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
    
    @IBOutlet weak var badgeView: UIView!
    
    
    
    var notificationTokens = [NotificationToken]()
    var runtimeResults: Results<Runtime>?
    var runtimeNotificationToken: NotificationToken? = nil
    
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
        realmDataController.realmDataControllerDelegate = self
        showLogin()
    }
    
    func prepareNotifications() {
        runtimeResults = realm?.allObjects(ofType: Runtime.self)
        
        
        // Observe Notifications
        runtimeNotificationToken = runtimeResults?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            
            guard let mainController = self else { return }
            switch changes {
            case .Initial(let runtimeResults):
                //we have nothing
                if runtimeResults.isEmpty {
                    //mainController.showLogin()
                } else {
                    mainController.updateHeader()
                    //mainController.showLogin()
                }
                break
            case .Update( _, _, _, _):
                LOG.debug("UPDATE Runtime -- TERMINAL")
                mainController.updateHeader()
                //terminalController.updateUI(withRuntimeResults: runtimeResults)
                break
            case .Error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                LOG.error("\(error)")
                break
            }
        }
    }
    
    func updateHeader() {
        if let sectionName = realm?.runtimeSectionName() {
            sectionLabel.text = "\(sectionName)"
        }
        
        if let groupIndex = realm?.runtimeGroupIndex(), let sectionName = realm?.runtimeSectionName(), let group = realm?.group(withSectionName: sectionName, withGroupIndex: groupIndex), let groupName = group.name {
            topTabbar.setTitle("\(groupName.uppercased()) SPECIES ACCOUNTS", forSegmentAt: 0)
        }
        
//        badgeView.layer.cornerRadius = badgeView.frame.width/2.0
        
        for sv in badgeView.subviews {
            sv.layer.cornerRadius = sv.bounds.width / 2.0
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

extension MainContainerController: RealmDataControllerDelegate {
    func doesHaveData() {
        prepareNotifications()
    }
}

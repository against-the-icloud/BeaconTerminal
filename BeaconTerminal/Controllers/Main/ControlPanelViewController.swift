//
//  ControlPanelViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 5/22/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Material

protocol ControlPanelDelegate: class {
    func resetDidFinish(withRecordCount recordCount:Int)
}

class ControlPanelViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    @IBOutlet weak var hostSwitch: UISegmentedControl!
    @IBOutlet weak var dbResetStatusLabel: UILabel!
    @IBOutlet weak var dbResetButton: UIButton!
    @IBOutlet weak var exportSegment: UISegmentedControl!
    @IBOutlet weak var resetSegment: UISegmentedControl!
    @IBOutlet weak var syncSegment: UISegmentedControl!
    @IBOutlet weak var initStatus: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        getAppDelegate().controlPanelDelegate = self
        
        switch CURRENT_HOST {
        case LOCAL_IP:
            hostSwitch.selectedSegmentIndex = 0
            break
        case REMOTE:
            hostSwitch.selectedSegmentIndex = 1
            break
        default:
            hostSwitch.selectedSegmentIndex = 1
        }
        
        let defaults = UserDefaults.standard
        let initStatusB = defaults.bool(forKey: "init")
        
        
        initStatus.text = "\(initStatusB)"
        
        
    }

    
    @IBAction func dbResetAction(_ sender: AnyObject) {
        let groupIndex = resetSegment.selectedSegmentIndex
        getAppDelegate().resetDB(withGroupIndex: groupIndex)
    }
    
    
    @IBAction func doneAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)   
    }
    
    @IBAction func onBurger() {
        navigationDrawerController?.openLeftView()
    }
    @IBAction func deleteUserObjects(_ sender: UIButton) {
        
        realmDataController.deleteRelationships()
    }
    @IBAction func switchHosts(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            CURRENT_HOST = LOCAL_IP
            getAppDelegate().setupConnection()
            break
        case 1:
            CURRENT_HOST = REMOTE
            getAppDelegate().setupConnection()
            break
        default:
            CURRENT_HOST = REMOTE
            getAppDelegate().setupConnection()
        }
    }
    @IBAction func initDB(_ sender: UIButton) {
        
        let defaults = UserDefaults.standard
        let initStatusB = defaults.bool(forKey: "init")
        
        defaults.set(!initStatusB, forKey: "init")
        
        initStatus.text = "\(initStatusB)"
        
    }
    
    @IBAction func reconnectNutella(_ sender: UIButton) {
        
       getAppDelegate().setupConnection()
        
    }
    
    @IBAction func forceSync(_ sender: UIButton) {
        
        let index = syncSegment.selectedSegmentIndex
            
        realmDataController.forceSync(withIndex: index)
        
    }
}

extension ControlPanelViewController: ControlPanelDelegate {
    func resetDidFinish(withRecordCount recordCount:Int) {
        dbResetStatusLabel.text = "\(recordCount) records"
    }
}


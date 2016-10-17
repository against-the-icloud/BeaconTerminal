//
//  LoginTableViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/8/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

enum StartType {
    case manual
    case auto
    case terminal
}

class LoginTypeViewController: UITableViewController {
    
    var notificationToken: NotificationToken? = nil
    let defaults = UserDefaults.standard
    
    // determined at runtime
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // Mark: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        getAppDelegate().initLoginStateMachine()
        getAppDelegate().initStateMachine()
        getAppDelegate().changeLoginStateTo(.startLogin)
        getAppDelegate().changeSystemStateTo(.ready)
        prepareView()
    }
    
    func prepareView() {
        navigationController?.toolbar.barTintColor = Util.flatBlack
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? LoginConditionCell {
            navigationItem.backBarButtonItem?.title = cell.titleLabel.text
        }
        
        if let id = segue.identifier, let loginSectionViewController = segue.destination as? LoginSectionViewController {
            switch id {
            case "terminalLoginSegue":
                loginSectionViewController.startType = .terminal
            case "manualLoginSegue":
                loginSectionViewController.startType = .manual
                getAppDelegate().changeLoginStateTo(.manualLogin)

            default:
                break
            }
        }
        
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {
            getAppDelegate().manualLogin()
        })
    }
}

extension LoginTypeViewController {
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? LoginConditionCell, let startTypeName = cell.titleLabel.text {
            
            if startTypeName == "AUTO" {
              //fire here
                self.dismiss(animated: true, completion: {
                    
                     getAppDelegate().changeLoginStateTo(.autoLogin)
                
                })
            }
            
        }
    }

}

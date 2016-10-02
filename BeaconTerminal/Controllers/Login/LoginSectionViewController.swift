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

enum groupType {
    case group
    case species
}

class LoginSectionViewController: UITableViewController {
    
    var notificationToken: NotificationToken? = nil
    let defaults = UserDefaults.standard
    
    // determined at runtime
    var loginType: groupType = .group
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // Mark: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        if let condition = defaults.string(forKey: "condition") {
            if let appType = ApplicationType(rawValue: condition) {
                switch appType {
                case .placeTerminal:
                    loginType = .species
                    break
                default:
                    loginType = .group
                }
            }
        }
        
    }
    
    func prepareView() {
        navigationController?.toolbar.barTintColor = Util.flatBlack
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let cell = sender as? LoginConditionCell {
            navigationItem.backBarButtonItem?.title = cell.titleLabel.text
        }
    }

    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {})
    }
}

extension LoginSectionViewController {
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionDict = defaults.object(forKey: "sections") as? [String: [String]] ?? [String: [String]]()
        
        let sections = Array(sectionDict.keys)
        return sections.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        if let cell = tableView.cellForRow(at: indexPath) as? LoginConditionCell {
            
            if let sectionName = cell.titleLabel.text {
                defaults.set(sectionName, forKey: "sectionName")
                defaults.synchronize()
                getAppDelegate().setupConnection(withSectionName: sectionName)
            }
            
            
            switch self.loginType {
            case .species:
                self.performSegue(withIdentifier: "speciesSegue", sender: cell)
            default:
                self.performSegue(withIdentifier: "groupSegue", sender: cell)
            }
        
            
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
          let cell:LoginConditionCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! LoginConditionCell
        
        
        let sectionDict = defaults.object(forKey: "sections") as? [String: [String]] ?? [String: [String]]()
        
        let sections = Array(sectionDict.keys)
        
        if !sections.isEmpty {
            cell.titleLabel.text = sections[indexPath.row]
        }
        
        return cell
    }
}

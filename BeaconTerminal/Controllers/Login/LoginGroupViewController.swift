//
//  LoginGroupCollectionViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/18/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class LoginGroupViewController: UITableViewController {
    
    let defaults = UserDefaults.standard
    var groupNames = [String]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    func constructLabel(with group: Group?) -> String? {
        if let g = group {
            
            if g.members.count > 0 {
                var memberNames = ""
                for member in g.members {
                    if memberNames.isEmpty {
                        memberNames = "\(member.name!)"
                    } else {
                        memberNames = "\(memberNames),\(member.name!)"
                    }
                }
                return "\(memberNames)"
            }
        }
        return nil
    }
    
    // Mark: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        let sections = defaults.object(forKey: "sections") as? [String: [String]] ?? [String: [String]]()
        let sectionName = defaults.object(forKey: "sectionName") as! String
        groupNames = sections[sectionName]!
        
        prepareView()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func prepareView() {
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.backItem?.backBarButtonItem?.tintColor = UIColor.white
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {})
    }
}

extension LoginGroupViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupNames.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? LoginConditionCell, let groupIndex = cell.titleLabel.text {
            defaults.set(Int(groupIndex), forKey: "groupIndex")
            defaults.synchronize()
            
            self.dismiss(animated: true, completion: {
                //realm for section $0
                //load configuration
                //contact nutella for section $0
                getAppDelegate().loadCondition()
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:LoginConditionCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! LoginConditionCell
        let groupName = groupNames[indexPath.row]
        cell.titleLabel.text = "\(groupName) (\(indexPath.row))"
        return cell
    }
}

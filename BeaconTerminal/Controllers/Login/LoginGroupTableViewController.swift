//
//  LoginGroupTableViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/11/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class LoginGroupTableViewController: UITableViewController {
    
    var groups: List<Group>?
    var selectedSection: Section?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //unwind segue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let gs = groups {
            return gs.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell")
        
        if groups?[indexPath.row] != nil {
            let group = groups![indexPath.row]
            cell?.textLabel?.text = constructLabel(with: group)
            return cell!
        }
        return cell!
    }
    
    func constructLabel(with group: Group?) -> String? {
        if let g = group, let gt = g.name {
            
            if g.members.count > 0 {
                var memberNames = ""
                for member in g.members {
                    if memberNames.isEmpty {
                        memberNames = "\(member.name!)"
                    } else {
                        memberNames = "\(memberNames),\(member.name!)"
                    }
                }
                return "\(gt): \(memberNames)"
            }
        }
        return nil
    }
    
    // Mark: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
    
    func prepareView() {
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.backItem?.backBarButtonItem?.tintColor = UIColor.white
        navigationController?.toolbar.barTintColor = Util.flatBlack
    }
    
    
    // Mark: Action
    
    @IBAction func selectGroupAction(_ sender: UIBarButtonItem) {
        //nothing is selected
        if tableView.indexPathForSelectedRow != nil {
            if groups?.count > 0 {
                
                if let indexPath = tableView.indexPathForSelectedRow {
                    let group = groups![indexPath.row]
                    realmDataController?.updateUser(withGroup: group, section: selectedSection!)
                    self.performSegue(withIdentifier: "unwindToSideMenu", sender: self)

                    self.dismiss(animated: true, completion: {})

                }
                
                
            }
        }
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {})
        self.performSegue(withIdentifier: "unwindToSideMenu", sender: self)
    }
}

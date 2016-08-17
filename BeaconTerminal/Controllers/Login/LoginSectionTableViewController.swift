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

class LoginSectionTableViewController: UITableViewController {
    
    var sections: Results<Section>?
    var notificationToken: NotificationToken? = nil
    var selectedSectionIndex: Int?
    
    deinit {
        if notificationToken != nil {
            notificationToken?.stop()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // Mark: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNotification()
        prepareView()
    }
    
    func prepareNotification() {
        
        sections = realmDataController?.realm.allObjects(ofType: Section.self)
        
        // Observe Notifications
        notificationToken = sections?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .Initial(let sections):
                
                self?.sections = sections
                // Results are now populated and can be accessed without blocking the UI
                
                break
            case .Update(_, _, _, _):
                
                break
            case .Error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections!.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionCell")
        if let sections = sections {
            cell?.textLabel?.text = sections[indexPath.row].name
        }
        
        return cell!
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "groupSegue" {
            let selectedCell = sender as? UITableViewCell
            let selectedIndexPath = tableView.indexPath(for: selectedCell!)
            let gvc = segue.destination as? LoginGroupTableViewController
            
            let selectedSection = sections![(selectedIndexPath?.row)!]
            gvc?.groups = sections![(selectedIndexPath?.row)!].groups
            gvc?.selectedSection = selectedSection
            if (sections?.count)! > 0 {
                let sectionName = sections?[(selectedIndexPath?.row)!].name
                gvc?.title = "Choose Your Group"
                navigationItem.backBarButtonItem?.tintColor = UIColor.white
                navigationItem.backBarButtonItem?.title = sectionName
            }
            
        }
    }
    
    func prepareView() {
        navigationController?.toolbar.barTintColor = Util.flatBlack
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {})
        self.performSegue(withIdentifier: "unwindToSideMenu", sender: self)
    }
}

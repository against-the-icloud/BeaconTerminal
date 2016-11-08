//
//  InvestigationTableViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 11/6/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class InvestigationViewTableViewController: UITableViewController {

    var selectedExperimentIndex = 0
    var experiment: Experiment?
    var experimentResults: Results<Experiment>?
    var experimentNotification: NotificationToken? = nil
    var notificationTokens = [NotificationToken]()
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    deinit {
        experimentNotification?.stop()
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
        prepareNotifications()
    }
    
    
    func prepareNotifications() {
        experimentResults = realmDataController.getRealm().experiments
        
        experimentNotification = experimentResults?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.endUpdates()
                break
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
        
    }
    @IBAction func refreshAction(_ sender: Any) {
        realmDataController.fetchExperiments()
    }

    @IBAction func doneAction(_ sender: Any) {
        
        self.performSegue(withIdentifier: "unwindToInvestigations", sender: self)
        
        self.dismiss(animated: true, completion: {
            
            
            
        })
    }
}


extension InvestigationViewTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let er = experimentResults {
            return er.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            if let experiment = self.experimentResults?[indexPath.row] {
                self.experiment = experiment
                self.selectedExperimentIndex = indexPath.row
            }
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "investigationCell")!
        
        if let experiment = self.experimentResults?[indexPath.row], let question = experiment.question {
            cell.textLabel?.text = question
        }
        return cell
    }
    
}


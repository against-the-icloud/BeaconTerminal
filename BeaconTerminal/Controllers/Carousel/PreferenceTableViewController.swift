//
//  PreferenceTableViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/6/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit

class PreferencesTableViewController: UITableViewController {
    
    var speciesObservation: SpeciesObservation?
    
    @IBOutlet weak var okButton: UIBarButtonItem!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
    
    func prepareView() {
        
    }
    
    // MARK: table
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = super.tableView(tableView, cellForRowAt: indexPath) as? PreferenceTableViewCell {
            if let preferenceType = cell.preferenceType, let preferences = speciesObservation?.preferences {
                
                let foundPreferences = preferences.filter(using: "type = '\(preferenceType)'")
                
                if !foundPreferences.isEmpty {
                    let preference = foundPreferences[0]
                    
                    if cell.textLabel?.text == preference.value {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                    }
                }
                
                return cell
            }
        }
        
        return PreferenceTableViewCell()
    }
    
    
    /// Select item at row in tableView.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        
        let numberOfRows = tableView.numberOfRows(inSection: section)
        
        for row in 0..<numberOfRows {
            let cell =  tableView.cellForRow(at: IndexPath(row: row, section: section))
            if cell != nil {
                cell?.accessoryType = row == indexPath.row ? .checkmark : .none
            }
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? PreferenceTableViewCell {
            if let preferenceType = cell.preferenceType, let preferences = speciesObservation?.preferences {
                
                let foundPreferences = preferences.filter(using: "type = '\(preferenceType)'")
                
                if foundPreferences.count > 0 {
                    let preference = foundPreferences[0]
                    try! realmDataController!.realm.write {                        
                        preference.type = cell.preferenceType!
                        preference.value = cell.textLabel?.text
                        preference.lastModified = NSDate() as Date
                        realmDataController!.realm.add(preference, update: true)
                    }
                                  }
            }
            
        }
    }

}


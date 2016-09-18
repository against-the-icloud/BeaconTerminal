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

class LoginConditionCollectionViewController: UITableViewController {
    
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
    }
    
    
    func prepareView() {
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.backItem?.backBarButtonItem?.tintColor = UIColor.white
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let id = segue.identifier {
            switch id {
            case "showSectionSegue":
                if segue.destination is LoginSectionViewController {                    
                    if let cell = sender as? LoginConditionCell {
                        navigationItem.backBarButtonItem?.title = cell.titleLabel.text
                    }
                }
                break
            default:
                break
            }
        }
        
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {})
    }
}

extension LoginConditionCollectionViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ApplicationType.allValues.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) != nil {
            let condition: ApplicationType = ApplicationType.allValues[indexPath.row]
            let defaults = UserDefaults.standard
            defaults.set(condition.rawValue, forKey: "condition")
            defaults.synchronize()
            
            getAppDelegate().changeSystemStateTo(condition)

        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:LoginConditionCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! LoginConditionCell
        
        let appType = ApplicationType.allValues[indexPath.row]
        
        cell.titleLabel.text = appType.rawValue
        
        switch appType {
        case .placeGroup:
            cell.badgeImageView.image = UIImage(named: "placeGroup")
        case .objectGroup:
            cell.badgeImageView.image = UIImage(named: "objectGroup")
        case .placeTerminal:
            cell.badgeImageView.image = UIImage(named: "placeTerminal")
        default:
            break
        }
        
        
        
        return cell
    }
    
}

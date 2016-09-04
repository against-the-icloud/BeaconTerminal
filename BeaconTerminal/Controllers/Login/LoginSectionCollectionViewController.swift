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

enum LoginType {
    case group
    case species
}

class LoginSectionCollectionViewController: UICollectionViewController {
    
    var notificationToken: NotificationToken? = nil
    
    // determined at runtime
    var loginType: LoginType = .group
    
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
        
        guard (realm?.runtimeSectionName()) != nil else {
            return
        }
        
        performSegue(withIdentifier: "shortCurcuitSpeciesSegue", sender: self)
    }
    
    func updateNavigatonItems() {
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        navigationItem.backBarButtonItem?.title = realm?.runtimeSectionName()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let id = segue.identifier {
            switch id {
            case "groupSegue":
                if let gvc = segue.destination as? LoginGroupCollectionViewController {
                    gvc.title = "Choose Your Group"
                    updateNavigatonItems()
                }
                break
            case "speciesSegue":
                if let gvc = segue.destination as? LoginSpeciesCollectionViewController {
                    gvc.title = "Choose a Species"
                    updateNavigatonItems()
                }
                break
            case "shortCurcuitSpeciesSegue":
                if let gvc = segue.destination as? LoginSpeciesCollectionViewController {
                    gvc.title = "Choose a Species"
                    updateNavigatonItems()
                }
            default:
                break
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

extension LoginSectionCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = realm?.sections() {
            return sections.count
        } else {
            return 0
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            
            if let sections = realm?.sections() {
                realmDataController?.updateRuntime(withSectionName: sections[indexPath.row].name, withSpeciesIndex: nil, withGroupIndex: nil)
                switch self.loginType {
                case LoginType.species:
                    self.performSegue(withIdentifier: "speciesSegue", sender: cell)
                default:
                    self.performSegue(withIdentifier: "groupSegue", sender: cell)
                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoginGroupCell.reuseIdentifier, for: indexPath) as? LoginGroupCell
        if let sections = realm?.sections() {
            cell?.groupLabel.text = sections[indexPath.row].name
        }
        return cell!
    }
}

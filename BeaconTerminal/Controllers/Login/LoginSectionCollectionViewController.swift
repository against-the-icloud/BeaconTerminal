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
    
    var sections: Results<Section> = realm!.allObjects(ofType: Section.self)
    var notificationToken: NotificationToken? = nil
    var selectedSection: Section?
    
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
        
        if selectedSection != nil {
            performSegue(withIdentifier: "shortCurcuitSpeciesSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let id = segue.identifier {
            switch id {
            case "groupSegue":
                let selectedCell = sender as? LoginGroupCell
                let selectedIndexPath = collectionView?.indexPath(for: selectedCell!)
                if let gvc = segue.destination as? LoginGroupCollectionViewController {
                
                selectedSection = sections[(selectedIndexPath?.row)!]
                gvc.groups = sections[(selectedIndexPath?.row)!].groups
                gvc.selectedSection = selectedSection
                if (sections.count) > 0 {
                    let sectionName = sections[(selectedIndexPath?.row)!].name
                    gvc.title = "Choose Your Group"
                    navigationItem.backBarButtonItem?.tintColor = UIColor.white
                    navigationItem.backBarButtonItem?.title = sectionName
                }
                }
                break
            case "speciesSegue":
                let selectedCell = sender as? LoginGroupCell
                let selectedIndexPath = collectionView?.indexPath(for: selectedCell!)
                if let gvc = segue.destination as? LoginSpeciesCollectionViewController {
                    selectedSection = sections[(selectedIndexPath?.row)!]
                    gvc.selectedSection = selectedSection
                    if (sections.count) > 0 {
                        let sectionName = sections[(selectedIndexPath?.row)!].name
                        gvc.title = "Choose a Species"
                        navigationItem.backBarButtonItem?.tintColor = UIColor.white
                        navigationItem.backBarButtonItem?.title = sectionName
                    }
                }
                break
            case "shortCurcuitSpeciesSegue":
                
                if let gvc = segue.destination as? LoginSpeciesCollectionViewController {
                    gvc.selectedSection = selectedSection
                    if (sections.count) > 0 {
                        let sectionName = selectedSection?.name
                        gvc.title = "Choose a Species"
                        navigationItem.backBarButtonItem?.tintColor = UIColor.white
                        navigationItem.backBarButtonItem?.title = sectionName
                    }
                }
                break
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
        return sections.count
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            
            realmDataController?.updateRuntimeSection(withSection: sections[indexPath.row], andOrSpecies: nil)

            
            switch self.loginType {
            case LoginType.species:
                self.performSegue(withIdentifier: "speciesSegue", sender: cell)
            default:
                self.performSegue(withIdentifier: "groupSegue", sender: cell)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoginGroupCell.reuseIdentifier, for: indexPath) as? LoginGroupCell
   
            cell?.groupLabel.text = sections[indexPath.row].name
      
        
        return cell!
    }
}

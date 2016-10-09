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

class ChoosePreferencesViewController: UICollectionViewController {
    
    var speciesIndex: Int?
    var habitatFiltered: Results<Habitat>?
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
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
    }
    
    func prepareView() {
        
        
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.backItem?.backBarButtonItem?.tintColor = UIColor.white
        
        
        if let speciesIndex = self.speciesIndex, let speciesObs = realm?.allSpeciesObservationsForCurrentSectionAndGroup() {
            
            if let so = speciesObs.filter("fromSpecies.index = \(speciesIndex)").first {
                
                
                if !so.speciesPreferences.isEmpty {
                var query: String?

                    //all the species that have been used
                    for (index,sp) in so.speciesPreferences.enumerated() {
                        
                        if index == 0 {
                          query = "index != \(sp.habitat?.index)"
                        }
                        
                        if let habitat = sp.habitat {
                            query!.append(" AND index != \(habitat.index)")
                        }
                    }
//
                    habitatFiltered = realmDataController.getRealm().habitats.filter(query!)
                } else {
                    habitatFiltered = realmDataController.getRealm().habitats
                }
//
            
                
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier {
            switch segueId {
            case "evidencePreferencesSegue":
                
                if let ev = segue.destination as? EvidencePreferenceViewController, let speciesIndex = self.speciesIndex, let speciesCell = sender as? LoginSpeciesCell {
                    
                    ev.fromSpeciesIndex = speciesIndex
                    ev.habitatIndex = speciesCell.speciesIndex
                    
                    ev.title = "Support"
                }
                break
            default:
                break
            }
        }
    }
    
    // Mark: Action
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {})
    }
}

extension ChoosePreferencesViewController {
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView: ChooseSpeciesHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ChooseSpeciesHeader.chooseSpeciesHeaderIdentifier, for: indexPath) as! ChooseSpeciesHeader
        
        if let fromSpeciesIndex = self.speciesIndex {
            headerView.fromSpeciesImageView.image = RealmDataController.generateImageForSpecies(fromSpeciesIndex, isHighlighted: true)
            headerView.relationshipLabel.text = "PREFERS"
        }
        
        return headerView
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let allHabitats = self.habitatFiltered {
            return allHabitats.count
        } else {
            return 0
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoginSpeciesCell.reuseIdentifier, for: indexPath) as! LoginSpeciesCell
        
        if let filtered = self.habitatFiltered {
            let toHabitat = filtered[indexPath.row]
            
            cell.speciesImageView.image = UIImage(named: toHabitat.name)
            cell.speciesIndex = toHabitat.index
            //cell.speciesLabel.text = "Species \(toSpecies.index)"
            
        }
        return cell
    }
    
}

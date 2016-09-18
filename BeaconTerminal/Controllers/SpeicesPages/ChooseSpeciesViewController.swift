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

class ChooseSpeciesViewController: UICollectionViewController {
    
    var speciesIndex: Int?
    var relationshipType: RelationshipType?
    var speciesFilterd: Results<Species>?
    
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
        
        
        if let speciesIndex = self.speciesIndex, let speciesObs = realm?.allSpeciesObservationsForCurrentSectionAndGroup(), let rType = self.relationshipType?.rawValue {
            
            if let so = speciesObs.filter(using: "fromSpecies.index = \(speciesIndex)").first {
                let relationshipResults = so.relationships.filter(using: "relationshipType = '\(rType)'")
                
                if relationshipResults.isEmpty {
                    speciesFilterd = realm?.species.filter(using: "index != \(speciesIndex)")
                } else {
                    
                    
                    //all the species that have been used
                    var query = "index != \(speciesIndex)"
                    for (_,r) in relationshipResults.enumerated() {
                        if let toSpecies = r.toSpecies {
                            query.append(" AND index != \(toSpecies.index)")
                        }
                    }
                    
                    speciesFilterd = realm?.species.filter(using: query)
                    
                }
                
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier {
            switch segueId {
            case "evidenceSpeciesSegue":
                
                if let ev = segue.destination as? EvidenceSpeciesViewController, let speciesIndex = self.speciesIndex, let relationshipType = self.relationshipType, let speciesCell = sender as? LoginSpeciesCell {
                    
                    ev.relationshipType = relationshipType
                    ev.fromSpeciesIndex = speciesIndex
                    ev.toSpeciesIndex = speciesCell.speciesIndex
                    
                    ev.title = "2. ADD EVIDENCE"
                    ev.navigationItem.prompt = "SUPPORT THE RELATIONSHIP"
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

extension ChooseSpeciesViewController {
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView: ChooseSpeciesHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ChooseSpeciesHeader.chooseSpeciesHeaderIdentifier, for: indexPath) as! ChooseSpeciesHeader
        
        if let fromSpeciesIndex = self.speciesIndex, let rType = self.relationshipType {
            headerView.fromSpeciesImageView.image = RealmDataController.generateImageForSpecies(fromSpeciesIndex, isHighlighted: true)
            headerView.relationshipLabel.text = StringUtil.relationshipString(withType: rType).uppercased()
        }
        
        return headerView
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let allSpecies = speciesFilterd {
            return allSpecies.count
        } else {
            return 0
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoginSpeciesCell.reuseIdentifier, for: indexPath) as! LoginSpeciesCell
        
        if let filtered = speciesFilterd {
            let toSpecies = filtered[indexPath.row]
            
            cell.speciesImageView.image = RealmDataController.generateImageForSpecies(toSpecies.index, isHighlighted: true)
            cell.speciesIndex = toSpecies.index
            cell.speciesLabel.text = "Species \(toSpecies.index)"
            
        }
        return cell
    }
    
}

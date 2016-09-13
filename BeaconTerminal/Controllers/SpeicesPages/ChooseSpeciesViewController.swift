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
                    ev.navigationItem.prompt = "SUPPORT THE '\(StringUtil.relationshipString(withType: relationshipType).uppercased()) RELATIONSHIP'"
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
        if let allSpecies = realm?.species {
            return allSpecies.count
        } else {
            return 0
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        
//        if let allSpecies = realm?.species {
//            if indexPath.row <=  allSpecies.count {
//                realmDataController?.updateRuntime(withSectionName: nil, withSpeciesIndex: indexPath.row, withGroupIndex: nil)
//                performSegue(withIdentifier: "unwindToTerminalView", sender: nil)
//            }
//        }
//        self.dismiss(animated: true, completion: nil)
//    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoginSpeciesCell.reuseIdentifier, for: indexPath) as! LoginSpeciesCell
        
        if let fromSpecies = realm?.speciesWithIndex(withIndex: indexPath.row) {
        
        cell.speciesImageView.image = RealmDataController.generateImageForSpecies(fromSpecies.index, isHighlighted: true)
        cell.speciesIndex = fromSpecies.index
        cell.speciesLabel.text = "Species \(fromSpecies.index)"
        }
        return cell
    }
    
}

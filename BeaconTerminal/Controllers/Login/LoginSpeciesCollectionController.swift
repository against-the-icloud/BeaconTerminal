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

class LoginSpeciesCollectionViewController: UICollectionViewController {
    
    var species: Results<Species> = realmDataController!.realm.allObjects(ofType: Species.self)
    
    var selectedSection: Section?
    
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
        navigationController?.toolbar.barTintColor = Util.flatBlack
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToTerminalView" {
            if let selectedCell = sender as? LoginSpeciesCell {
                let selectedSpecies = species[selectedCell.speciesIndex]
                let tvc = segue.destination as? TerminalViewController
                tvc?.species = selectedSpecies
                tvc?.section = selectedSection
            }
        }
    }
    
    // Mark: Action
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {})
        self.performSegue(withIdentifier: "unwindToSideMenu", sender: self)
    }
}

extension LoginSpeciesCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.species.count
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        
        performSegue(withIdentifier: "unwindToTerminalView", sender: cell)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoginSpeciesCell.reuseIdentifier, for: indexPath) as! LoginSpeciesCell
                
        let foundSpecies = species[indexPath.row]
        
        cell.speciesImageView.image = RealmDataController.generateImageForSpecies(foundSpecies.index, isHighlighted: true)
        cell.speciesIndex = indexPath.row
        return cell
    }

}

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

    let defaults = UserDefaults.standard
    let allSpecies = realmDataController.parseSpeciesConfigurationJson()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Mark: View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
    
    func prepareView() {
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.backItem?.backBarButtonItem?.tintColor = UIColor.white
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToTerminalView" {
            
        }
    }
    
    // Mark: Action
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {
            
            getAppDelegate().manualLogin()
            
        })
    }
}

extension LoginSpeciesCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allSpecies.count
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row <=  allSpecies.count {
            
            if let cell = collectionView.cellForItem(at: indexPath) as? LoginSpeciesCell {
                defaults.set(Int(cell.speciesIndex), forKey: "speciesIndex")
                defaults.synchronize()
                
                self.dismiss(animated: true, completion: {
                    getAppDelegate().changeSystemStateTo(.placeTerminal)
                })
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoginSpeciesCell.reuseIdentifier, for: indexPath) as! LoginSpeciesCell
        
        cell.speciesImageView.image = RealmDataController.generateImageForSpecies(indexPath.row, isHighlighted: true)
        cell.speciesIndex = indexPath.row
        cell.speciesLabel.text = "Species \(indexPath.row)"
        return cell
    }
    
}

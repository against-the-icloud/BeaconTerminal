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

class SyncViewController: UICollectionViewController {
    
    var shouldSync: Results<SpeciesObservation>?
    
    var speciesObsNotificationToken: NotificationToken? = nil
    
    deinit {
        if let sp = self.speciesObsNotificationToken {
            sp.stop()
        }
    }
    
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
        shouldSync = realm?.allSpeciesObservations().filter(using: "isSynced = false")
        
        speciesObsNotificationToken = shouldSync?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            
            guard let cv = self?.collectionView else { return }
            switch changes {
            case .Initial( _):
                cv.reloadData()
                break
            case .Update( _, let deletions, let insertions, let modifications):
                cv.performBatchUpdates({
                    cv.insertItems(at: insertions.map { IndexPath(row: $0, section: 0) })
                    cv.deleteItems(at: deletions.map { IndexPath(row: $0, section: 0) })
                    cv.reloadItems(at: modifications.map { IndexPath(row: $0, section: 0) })
                    }, completion: nil)
                break
            case .Error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }

    }
    
    
    // Mark: Action
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {})
    }
}

extension SyncViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let syncedObservations = self.shouldSync {
            return syncedObservations.count
        } else {
            return 0
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let shouldSync = self.shouldSync else {
            return
        }
        let sync = shouldSync[indexPath.row]
        
        if let fromSpeciesIndex = sync.fromSpecies?.index, let sName = sync.fromSpecies?.name {
            Util.makeToast("PERFORMING SYNC FOR \(fromSpeciesIndex):\(sName)")
        }
        
        realmDataController.exportSpeciesObservation(withNutella: nutella, withSpeciesObservation: sync)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoginSpeciesCell.reuseIdentifier, for: indexPath) as! LoginSpeciesCell
        
        guard let shouldSync = self.shouldSync else {
            return cell
        }
        
        let sync = shouldSync[indexPath.row]
        
        if let fromSpeciesIndex = sync.fromSpecies?.index {
            cell.speciesImageView.image = RealmDataController.generateImageForSpecies(fromSpeciesIndex, isHighlighted: true)
            cell.speciesIndex = fromSpeciesIndex
            cell.speciesLabel.text = "Species \(fromSpeciesIndex)"
        }
   
        return cell
    }
    
}

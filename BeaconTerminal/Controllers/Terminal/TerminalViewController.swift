//
//  TerminalViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/18/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Photos
import MobileCoreServices

struct RelationshipResult {
    var group: Group?
    var speciesObservation: SpeciesObservation?
    var relationships: Results<Relationship>?
    var relationshipType: RelationshipType?
}

class TerminalViewController: UIViewController {
    @IBOutlet var imageViews: [UIImageView]!
    
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    var species: Species?
    var section: Section?
    
    var relationshipResults = [RelationshipResult]()
    var relationshipControllers = [TerminalRelationshipViewController]()
    
    var notificationTokens = [NotificationToken]()
    
    deinit {
        for token in notificationTokens {
            token.stop()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showSpeciesLogin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func showSpeciesLogin() {
        let storyboard = UIStoryboard(name: "Popover", bundle: nil)
        let loginNavigationController = storyboard.instantiateViewController(withIdentifier: "loginNavigationController") as! UINavigationController
        
        if let loginSectionCollectionViewController = loginNavigationController.viewControllers[0] as? LoginSectionCollectionViewController {
            
            loginSectionCollectionViewController.loginType = LoginType.species
            
        }
        
        self.present(loginNavigationController, animated: true, completion: {})
    }
    
    

    
    // Mark: Unwind Actions
    
    @IBAction func unwindToTerminalView(segue: UIStoryboardSegue) {
        self.navigationDrawerController?.closeLeftView()
        updateUI()
        queryDB()
    }
    
    // Mark: updates
    
    func queryDB() {
        if let species = self.species, let section = self.section {
            
            //go through all the groups and grab the speciesObservations
            
            for group in section.groups {
                
                let speciesObservations: Results<SpeciesObservation> = group.speciesObservations.filter(using: "fromSpecies.index = \(species.index)")
                
                //iterate over each relationship type
                for relationshipType in RelationshipType.allRelationships {
                    var relationshipResult = RelationshipResult()
                    relationshipResult.group = group
                    relationshipResult.speciesObservation = speciesObservations.first
                    relationshipResult.relationships = speciesObservations.first?.relationships.filter(using: "relationshipType = '\(relationshipType)'")
                    
                    
                    distributeToImageViews(relationships: relationshipResult.relationships!)
                    relationshipResult.relationshipType = relationshipType
                    relationshipResults.append(relationshipResult)
                }
            }
            
            //distribute the results to the appropriate controllers
            distributeToControllers()
  
       
            
        }
    }
    
    @IBAction func testSpeciesAdd(_ sender: UIButton) {
    }
    
    func distributeToControllers() {
        for rvc in relationshipControllers {
            let results = relationshipResults.filter({ (rr:RelationshipResult) -> Bool in
                return rr.relationshipType == rvc.relationshipType
            })
            
            rvc.relationshipResults = results
            rvc.updateUI()
        }
    }
    
    func distributeToImageViews(relationships: Results<Relationship>) {
        for r in relationships {
            if let attachments = r.attachments {
                for imageView in imageViews {
                    if imageView.image == nil {
                        loadImageAsset(attachment: attachments, imageView: imageView)
                    }
                }
            }
        }
    }
    
    
    func loadImageAsset(attachment: String, imageView: UIImageView) {
        
        
                    if let url = URL(string: attachment) {
                        if let assets : PHAsset = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil).firstObject {
                            let targetSize = CGSize(width: imageView.frame.width,height: imageView.frame.height)
                            let options = PHImageRequestOptions()
                            
                            PHImageManager.default().requestImage(for: assets, targetSize: targetSize, contentMode: PHImageContentMode.aspectFit, options: options, resultHandler: {
                                (result, info) in
                                imageView
                                    .image = result
                            })
                        }
                    }
        
        
    }
    
    
    func updateUI() {
        if let species = species {
            profileImageView.image = RealmDataController.generateImageForSpecies(species.index, isHighlighted: true)
            profileLabel.text = species.name
        }
        
        if let section = self.section {
            sectionLabel.text = section.name
        }
        
    }
    
    // Mark: segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "terminalProducerRelationship" {
            if let tvc = segue.destination as? TerminalRelationshipViewController {
                updateRelationshipViews(with: .producer, rvc: tvc)
            }
        } else if segue.identifier == "terminalCompetesRelationship" {
            if let tvc = segue.destination as? TerminalRelationshipViewController {
                updateRelationshipViews(with: .competes, rvc: tvc)
            }
        } else if segue.identifier == "terminalConsumerRelationship" {
            if let tvc = segue.destination as? TerminalRelationshipViewController {
                updateRelationshipViews(with: .consumer, rvc: tvc)
            }
        }
    }
    
    func updateRelationshipViews(with relationshipType: RelationshipType, rvc: TerminalRelationshipViewController) {
        rvc.relationshipType = relationshipType
        relationshipControllers.append(rvc)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
 
}

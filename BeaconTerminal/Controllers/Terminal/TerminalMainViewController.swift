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
import Nutella

struct RelationshipResult {
    var group: Group?
    var speciesObservation: SpeciesObservation?
    var relationships: Results<Relationship>?
    var relationshipType: RelationshipType?
}

class TerminalMainViewController: UIViewController, NutellaDelegate {
    @IBOutlet var imageViews: [UIImageView]!
    
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    var species: Species?
    var section: Section?
    
    var relationshipResults = [RelationshipResult]()
    var notificationTokens = [NotificationToken]()
    
    var runtimeResults: Results<Runtime>?
    var speciesObservationResults: Results<SpeciesObservation>?

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
        prepareNotifications()
    }
    
    // Mark: Prepare
    
    func prepareView() {
        updateHeader()
        queryDB()
        updateUI()
    }
    
    func prepareNotifications() {
        runtimeResults = realm?.allObjects(ofType: Runtime.self)
        
        
        // Observe Notifications
        let runtimeNotificationToken = runtimeResults?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            
            guard let terminalController = self else { return }
            switch changes {
            case .Initial(let runtimeResults):
                terminalController.updateUI(withRuntimeResults: runtimeResults)
                break
            case .Update(let runtimeResults, _, _, _):
                terminalController.updateUI(withRuntimeResults: runtimeResults)
                break
            case .Error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
        
        if let nt = runtimeNotificationToken {
            notificationTokens.append(nt)
        }
        
        speciesObservationResults = realm?.allObjects(ofType: SpeciesObservation.self)

        let soNotificationToken = speciesObservationResults?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            
            guard let terminalController = self else { return }
            switch changes {
            case .Initial(let speciesObservationResults):
                terminalController.updateUI(withSpeciesObservationResults: speciesObservationResults)
                break
            case .Update(let speciesObservationResults, _, _, _):
                terminalController.updateUI(withSpeciesObservationResults: speciesObservationResults)
                break
            case .Error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
        
        if let nt = soNotificationToken {
            notificationTokens.append(nt)
        }
    }
    
    // Mark: Update UI
    
    func updateHeader() {
        if let species = species {
            profileImageView.image = RealmDataController.generateImageForSpecies(species.index, isHighlighted: true)
            profileLabel.text = species.name
        }
        
        if let section = self.section {
            sectionLabel.text = section.name
        }
    }
    
    
    func updateUI(withRuntimeResults runtimeResults: Results<Runtime>) {
        
        if let rt = runtimeResults.first {
            
            if let section = rt.currentSection, rt.currentSection != nil {
                self.section = section                
                updateHeader()
            } else {
                showSpeciesLogin()
            }
            
            if rt.currentSpecies == nil {
                showSpeciesLogin()
            } else {
                self.species = rt.currentSpecies
                //we are good time to check nutella
                prepareView()
                queryAllSpeciesNutella()
            }
            
        } else {
            showSpeciesLogin()
        }
    }
    
    func updateUI(withSpeciesObservationResults speciesObservationResults: Results<SpeciesObservation>) {
//        for so in speciesObservationResults {
//            
//        }
        
        queryDB()
        updateUI()
    }
    
    func queryAllSpeciesNutella() {
        if let nutella = getAppDelegate().nutella {
            
            let block = DispatchWorkItem {
                
                
                if let species = self.species {
                    var dict = [String:String]()
                    dict["speciesIndex"] = "\(species.index)"
                    
                    let json = JSON(dict)
                    let jsonObject: Any = json.object
                    nutella.net.asyncRequest("all_notes_with_species", message: jsonObject as AnyObject, requestName: "all_notes_with_species")

                }
                
                
                //nutella.net.publish("all_notes", message: dict as AnyObject)
            }
            
            DispatchQueue.main.async(execute: block)
        }
    }
    
    
    func showSpeciesLogin() {
        let storyboard = UIStoryboard(name: "Popover", bundle: nil)
        let loginNavigationController = storyboard.instantiateViewController(withIdentifier: "loginNavigationController") as! UINavigationController
        
        if let loginSectionCollectionViewController = loginNavigationController.viewControllers[0] as? LoginSectionCollectionViewController {
            
            loginSectionCollectionViewController.loginType = LoginType.species
            if let selectedSection = self.section {
                loginSectionCollectionViewController.selectedSection = selectedSection
            }
            
            
        }
        
        self.present(loginNavigationController, animated: true, completion: {})
    }
    
    
    
    
    // Mark: Unwind Actions
    
    @IBAction func unwindToTerminalView(segue: UIStoryboardSegue) {
        self.navigationDrawerController?.closeLeftView()
        prepareView()
        //queryAllSpeciesNutella()
    }
    
    // Mark: updates
    
    func queryDB() {
        if let species = self.species, let section = self.section {
            
            //go through all the groups and grab the speciesObservations
            
            for group in section.groups {
                
                let speciesObservations: Results<SpeciesObservation> = group.speciesObservations.filter(using: "fromSpecies.index = \(species.index)")
                
//                LOG.debug("SPECIESOB \(RealmDataController.exportJson(withSpeciesObservation: speciesObservations.first!, group: group))")
//                
                //iterate over each relationship type
                for relationshipType in RelationshipType.allRelationships {
                    var relationshipResult = RelationshipResult()
                    relationshipResult.group = group
                    relationshipResult.speciesObservation = speciesObservations.first
                    relationshipResult.relationships = speciesObservations.first?.relationships.filter(using: "relationshipType = '\(relationshipType)'")
                    
                    
                    //distributeToImageViews(relationships: relationshipResult.relationships!)
                    relationshipResult.relationshipType = relationshipType
                    relationshipResults.append(relationshipResult)
                }
            }
        }
    }
    
    func updateUI() {
        //setup the columans
        for childController in self.childViewControllers {
            if let rvc = childController as? TerminalRelationshipTableViewController {
                
                if let section = self.section {
                    rvc.groups = section.groups
                    rvc.species = species
                }
                
                let results = relationshipResults.filter({ (rr:RelationshipResult) -> Bool in
                    return rr.relationshipType == rvc.relationshipType
                })
                
                rvc.relationshipResults = results
            }
        }
    }
    
    @IBAction func testSpeciesAdd(_ sender: UIButton) {
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
    
    

    // Mark: segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let tvc = segue.destination as? TerminalRelationshipTableViewController, let segueId = segue.identifier {
            
            switch segueId {
            case "terminalProducerRelationship":
                tvc.relationshipType = .producer
            case "terminalCompetesRelationship":
                tvc.relationshipType = .competes
            case "terminalConsumerRelationship":
                tvc.relationshipType = .consumer
            default:
                print("you know nothing")
            }
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

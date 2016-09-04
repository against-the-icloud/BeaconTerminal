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
    
    var relationshipResults = [RelationshipResult]()
    var notificationTokens = [NotificationToken]()
    
    var runtimeResults: Results<Runtime>?
    var speciesObservationResults: Results<SpeciesObservation>?

    var notificationToken: NotificationToken? = nil
    deinit {
        if notificationToken != nil {
            notificationToken?.stop()
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
    
    func prepareNotifications() {
        runtimeResults = realm?.allObjects(ofType: Runtime.self)
        
        
        // Observe Notifications
        notificationToken = runtimeResults?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            
            guard let terminalController = self else { return }
            switch changes {
            case .Initial(let runtimeResults):
                //we have nothing
                if runtimeResults.isEmpty {
                    terminalController.showLogin()
                } else {
                    terminalController.updateHeader()
                    terminalController.showLogin()
                }
                break
            case .Update( _, _, _, _):
                LOG.debug("UPDATE Runtime -- TERMINAL")
                terminalController.updateHeader()
                //terminalController.updateUI(withRuntimeResults: runtimeResults)
                break
            case .Error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                LOG.error("\(error)")
                break
            }
        }
    }
    
    // Mark: Update UI
    
    func updateHeader() {
        if let speciesIndex = realm?.runtimeSpeciesIndex() {
            profileImageView.image = RealmDataController.generateImageForSpecies(speciesIndex, isHighlighted: true)
            
            if let species = realm?.speciesWithIndex(withIndex: speciesIndex) {
                profileLabel.text = species.name
            }
        } else {
            //no species image
        }
        
        if let sectionName = realm?.runtimeSectionName() {
            sectionLabel.text = sectionName
        } else {
            sectionLabel.text = "XYZ"
        }
        
        for (index, controller) in self.childViewControllers.enumerated() {
            guard let relationshipController = controller as? TerminalRelationshipTableViewController else {
                break
            }
            
            if index < RelationshipType.allRelationships.count {
                relationshipController.relationshipType = RelationshipType.allRelationships[index]
                relationshipController.updateHeader()
            }
        }
        
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = DateFormatter.Style.short
        dateformatter.timeStyle = DateFormatter.Style.short
        
        timestampLabel.text = dateformatter.string(from: Date())
        
    }
    
    func queryAllSpeciesNutella() {
        if let nutella = nutella {
            let block = DispatchWorkItem {
                if let speciesIndex = realm?.runtimeSpeciesIndex() {
                    var dict = [String:String]()
                    dict["speciesIndex"] = "\(speciesIndex)"
                    let json = JSON(dict)
                    let jsonObject: Any = json.object
                    nutella.net.asyncRequest("all_notes_with_species", message: jsonObject as AnyObject, requestName: "all_notes_with_species")
                }
            }
            
            DispatchQueue.main.async(execute: block)
        }
    }
    
    
    func showLogin() {
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
        queryAllSpeciesNutella()
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

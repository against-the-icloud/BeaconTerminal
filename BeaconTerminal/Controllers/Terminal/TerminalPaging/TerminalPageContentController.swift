
//
//  SpeciesPageViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 9/9/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class TerminalPageContentController: UIViewController {
    
    
    var fromSpeciesIndex: Int?
    var toSpeciesIndex: Int?
    var habitatIndex: Int?
    var groupIndex: Int?
    var index: Int?
    var relationship: Relationship?
    
    var relationshipType: RelationshipType?


    var speciesPreference: SpeciesPreference?

    var attachments = [String]()
    var tags = [Int]()
    
    @IBOutlet var images: [UIImageView]!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var fromSpeciesImageView: UIImageView!
    @IBOutlet weak var relationshipTypeLabel: UILabel!
    @IBOutlet weak var toSpeciesImageView: UIImageView!
    @IBOutlet weak var groupIndexLabel: UILabel!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for im in images {
            let tag = Randoms.randomInt()
            im.tag = tag
        }
        
        
        prepareTitlePanel()
    }
    
    func prepareTitlePanel() {
        
        if let groupIndex = self.groupIndex {
            groupIndexLabel.text = "TEAM \(groupIndex + 1)"

        }
        
        if let relationship = self.relationship {
            
            guard let fromSpeciesIndex = self.fromSpeciesIndex else {
                return
            }
            
            guard let toSpeciesIndex = relationship.toSpecies?.index else {
                return
            }
            
            let relationshipType = relationship.relationshipType
            
            fromSpeciesImageView.image = RealmDataController.generateImageForSpecies(fromSpeciesIndex, isHighlighted: true)
            
            toSpeciesImageView.image = RealmDataController.generateImageForSpecies(toSpeciesIndex, isHighlighted: true)
            
            relationshipTypeLabel.text = "\(StringUtil.relationshipString(withString: relationshipType))"
            
            noteTextView.text = relationship.note
            
            if let attachments = relationship.attachments?.components(separatedBy: ",") {
                self.attachments = attachments
                
                for (index, path) in self.attachments.enumerated() {
                    
                    if let url = URL(string: path) {
                        self.images[index].hnk_setImageFromURL(url)
                        self.images[index].isUserInteractionEnabled = true
                        self.images[index].backgroundColor = UIColor.clear
                    }
                }
            }

        } else if let speciesPreference = self.speciesPreference {
            
            guard let fromSpeciesIndex = self.fromSpeciesIndex else {
                return
            }
            
            guard let habitatIndex = speciesPreference.habitat?.index else {
                return
            }
            
            fromSpeciesImageView.image = RealmDataController.generateImageForSpecies(fromSpeciesIndex, isHighlighted: true)
            
            if let habitat = realmDataController.getRealm().habitat(withIndex: habitatIndex) {
                toSpeciesImageView.image = UIImage(named: habitat.name)
                
                if habitat.name.contains("Temp") {
                    relationshipTypeLabel.text = "SURVIVES IN"
                } else {
                    relationshipTypeLabel.text = "INHABITS"
                    
                }
                
            }
            
            noteTextView.text = speciesPreference.note
            
            if let attachments = speciesPreference.attachments?.components(separatedBy: ",") {
                self.attachments = attachments
                
                for (index, path) in self.attachments.enumerated() {
                    
                    if let url = URL(string: path) {
                        self.images[index].hnk_setImageFromURL(url)
                        self.images[index].isUserInteractionEnabled = true
                        self.images[index].backgroundColor = UIColor.clear
                    }
                }
                
            }

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            switch id {
            case "imageSegue":
                if let ivc = segue.destination as? ImageViewController, let tap = sender as? UIGestureRecognizer {
                    if let iv = tap.view as? UIImageView, let image = iv.image {
                        let tag = iv.tag
                        if let index = tags.index(of: tag) {
                            ivc.imageUrl = self.attachments[index]
                            
                            var id = ""
                            var type = ""
                            var toIndex = 0
                            var sectionName = ""
                            if let s = realmDataController.getRealm().runtimeSectionName() {
                                sectionName = s
                            } else {
                                sectionName = "not specified"
                            }
                            
                            if let speciesPreference = self.speciesPreference {
                                id = speciesPreference.id!
                                type = "preference"
                                toIndex = speciesPreference.habitat!.index
                            } else if let relationship = self.relationship {
                                id = relationship.id!
                                type = "relationship"
                                toIndex = relationship.toSpecies!.index
                            }
                            
                              LOG.info( ["condition":"BeaconTerminal.ApplicationType.placeTerminal", "activity":realmDataController.getActivity(),"timestamp": Date(),"event":"tap_image","url":ivc.imageUrl!,"type":type,"groupIndex":self.groupIndex!,"fromSpecies":self.fromSpeciesIndex!,"toIndex":toIndex,"sectionName":sectionName])
                                
                            
                        }
                        ivc.image = image
                        ivc.canDelete = false
                    }
                }
            default:
                break
            }
        }
    }


}


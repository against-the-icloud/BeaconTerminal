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

class EvidenceSpeciesViewController: UIViewController {
    
    var fromSpeciesIndex: Int?
    var toSpeciesIndex: Int?
    var relationshipType: RelationshipType?
    var relationship: Relationship?
    
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var fromSpeciesImageView: UIImageView!
    @IBOutlet weak var relationshipTypeLabel: UILabel!
    @IBOutlet weak var toSpeciesImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // Mark: View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTitlePanel()
    }
    
    func prepareTitlePanel() {
        guard let fromSpeciesIndex = self.fromSpeciesIndex else {
            return
        }
        
        guard let toSpeciesIndex = self.toSpeciesIndex else {
            return
        }
        
        guard let relationshipType = self.relationshipType else {
            return
        }
        
        fromSpeciesImageView.image = RealmDataController.generateImageForSpecies(fromSpeciesIndex, isHighlighted: true)
        
        toSpeciesImageView.image = RealmDataController.generateImageForSpecies(toSpeciesIndex, isHighlighted: true)
        
        relationshipTypeLabel.text = "\(StringUtil.relationshipString(withType: relationshipType))"
    }
    
    
    @IBAction func deleteAction(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: {
            
            guard let fromIndex = self.fromSpeciesIndex else {
                return
            }
            
            
            guard let toSpeciesIndex = self.toSpeciesIndex else {
                return
            }
            
            
            let newRelationship = Relationship()
            
            if let r = self.relationship {
                newRelationship.id = r.id
            } else {
                
            }
            
            
            if let toSpecies = realm?.speciesWithIndex(withIndex: toSpeciesIndex) {
                newRelationship.toSpecies = toSpecies
            }
            
            newRelationship.note = self.noteTextView.text
            
            if let relationshipType = self.relationshipType {
                newRelationship.relationshipType = relationshipType.rawValue
            }
            
            realmDataController?.delete(withRelationship: newRelationship, withSpeciesIndex: fromIndex)

        })
                
    }
    
    
    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: {
            guard let fromIndex = self.fromSpeciesIndex else {
                return
            }
            
            guard let toSpeciesIndex = self.toSpeciesIndex else {
                return
            }
            

            let newRelationship = Relationship()
            
            if let r = self.relationship {
                newRelationship.id = r.id
            } else {
                
            }
            
            
            if let toSpecies = realm?.speciesWithIndex(withIndex: toSpeciesIndex) {
                newRelationship.toSpecies = toSpecies
            }
            
            newRelationship.note = self.noteTextView.text
            
            if let relationshipType = self.relationshipType {
                newRelationship.relationshipType = relationshipType.rawValue
            }
            
            realmDataController?.add(withRelationship: newRelationship, withSpeciesIndex: fromIndex)
        })
        
    }
    
    // Mark: Action
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {})
    }
}

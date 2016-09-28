//
//  LoginGroupTableViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/11/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Material
import RealmSwift

class EvidenceSpeciesViewController: UIViewController {
    
    var fromSpeciesIndex: Int?
    var toSpeciesIndex: Int?
    var relationshipType: RelationshipType?
    var relationship: Relationship?
    
    @IBOutlet var images: [UIImageView]!
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
        
        for iv in images {
            
            let url = URL(string: "http://10.0.1.6:57882/d41d8cd98f00b204e9800998ecf8427e.jpg")
            UIImage.contentsOfURL(url: url!, completion: { found, error in
                if let image = found  {
                    iv.image = image
                }
            })
        }
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
            
            realmDataController.delete(withRelationship: newRelationship, withSpeciesIndex: fromIndex)

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
            
            realmDataController.add(withRelationship: newRelationship, withSpeciesIndex: fromIndex)
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            switch id {
            case "imageSegue":
                if let ivc = segue.destination as? ImageViewController, let tap = sender as? UIGestureRecognizer {
                    if let iv = tap.view as? UIImageView, let image = iv.image {
                        ivc.image = image
                    }
                }
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

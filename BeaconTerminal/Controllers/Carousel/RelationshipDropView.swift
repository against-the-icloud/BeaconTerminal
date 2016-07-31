
//  ObservationDropView.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 6/5/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Material

protocol SpeciesRelationshipDetailDelegate: class {
    func presentRelationshipDetailView(_ sender: DraggableSpeciesImageView, relationship: Relationship, speciesObservation: SpeciesObservation)
}


class RelationshipDropView: DropTargetView {
    
    var fromSpecies: Species?
    var ringColor : UIColor?
    var draggableViews = [DraggableSpeciesImageView]()
    var speciesObservation: SpeciesObservation?
    var relationshipType: String?
    
    //always make delegates weak to avoid retain cycle
    weak var delegate:SpeciesRelationshipDetailDelegate?
    
    var isEditing: Bool = false {
        didSet {
            if isEditing {
                self.clearsContextBeforeDrawing = true
            } else {
                self.clearsContextBeforeDrawing = false
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareView()
    }
    
    func prepareView() {
    }
    
    func addDraggableView(_ speciesImageView: DraggableSpeciesImageView) -> Bool {
        for dView in self.subviews {
            if ((dView as? DraggableSpeciesImageView) != nil) {
                let dView = dView as? DraggableSpeciesImageView
                if dView?.species?.index == speciesImageView.species?.index {
                    return false
                }
            }
        }
        
        self.addSubview(speciesImageView)
        
        dispatch_on_main {
            realmDataController?.updateSpeciesObservation(speciesImageView.species!, speciesObservation: self.speciesObservation!, relationshipType: self.relationshipType!)
        }
        return true
    }
    
    func deleteSpeciesView(_ sender: UITapGestureRecognizer) {
        let speciesView = sender.view as? DraggableSpeciesImageView
        
        if let species = speciesView?.species, let relationshipType = relationshipType, let speciesObservation = speciesObservation {
            
            //filer all relationship with this type
            let foundRelationships = speciesObservation.relationships.filter(using: "relationshipType = '\(relationshipType)'").filter(using: "toSpecies.index = \(species.index)")
            
            //find relationships that have toSpecies equal to species.index
            
            if !foundRelationships.isEmpty {
                
                dispatch_on_main {
                    realmDataController!.delete(foundRelationships.first!)
                    
                    speciesView?.fadeOut(0.4, delay: 0.0, completion: {_ in
                        speciesView?.removeFromSuperview()
                    })
                    
                }
                
                
            }
        }
        
    }
    
    func showRelationshipDetail(_ sender: UITapGestureRecognizer) {
        
        
        let speciesView = sender.view as? DraggableSpeciesImageView
        
        
        if let delegate = self.delegate, let species = speciesView?.species, let relationshipType = relationshipType, let speciesObservation = speciesObservation {
            
            //filer all relationship with this type
            let foundRelationships = speciesObservation.relationships.filter(using: "relationshipType = '\(relationshipType)'").filter(using: "toSpecies.index = \(species.index)")
            
            //find relationships that have toSpecies equal to species.index
            
            if !foundRelationships.isEmpty {
                
                delegate.presentRelationshipDetailView(sender.view as! DraggableSpeciesImageView, relationship: foundRelationships.first!, speciesObservation: speciesObservation)
            }        
        }
    }
    
    func highlight() {
        self.backgroundColor = Color.grey.lighten3
        self.borderColor = Color.blue.base
    }
    
    func unhighlight() {
        self.backgroundColor = UIColor.white()
        self.borderColor = UIColor.black()
    }
    
    // Mark: UIView Methods
    
    override func didAddSubview(_ subview: UIView) {
        if let speciesView = subview as? DraggableSpeciesImageView {
            // remove all the targets
            
            if let gestures = speciesView.gestureRecognizers {
                for recognizer in gestures {
                    subview.removeGestureRecognizer(recognizer)
                }
            }
            
            //            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(RelationshipDropView.deleteSpeciesView(_:)))
            
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(RelationshipDropView.showRelationshipDetail(_:)))
            
            
            
            speciesView.addGestureRecognizer(tapGestureRecognizer)
            
        }
        
    }
}



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
    
    // Mark: UIView Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func didAddSubview(_ subview: UIView) {
        if let speciesView = subview as? DraggableSpeciesImageView {
            // remove all the targets
            if let gestures = speciesView.gestureRecognizers {
                for recognizer in gestures {
                    subview.removeGestureRecognizer(recognizer)
                }
            }
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(RelationshipDropView.showRelationshipDetailTap(_:)))
            speciesView.addGestureRecognizer(tapGestureRecognizer)
            //rearrangeSpeciesViews()
        }
    }

    
    func rearrangeSpeciesViews() {
        let size : CGFloat = 75.0                
        if self.frame.width > 0.0 {
            //LOG.debug("*** frame is \(self.frame)")
            for sv in self.subviews where ((sv as? DraggableSpeciesImageView) != nil) {
                let point = Util.generateRandomPoint(UInt32(self.frame.size.width - CGFloat(size)), maxYValue: UInt32(self.frame.size.height - CGFloat(size)))
                sv.center = point
            }
        } else {
            //LOG.debug("*** ZERO FRAME \(self.frame)")
        }
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
            realmDataController.updateSpeciesObservation(speciesImageView.species!, speciesObservation: self.speciesObservation!, relationshipType: self.relationshipType!)
            self.showRelationshipDetail(sender: speciesImageView)
        }
        return true
    }
    
    // Mark: Actions
    
    func deleteSpeciesView(_ sender: UITapGestureRecognizer) {
        let speciesView = sender.view as? DraggableSpeciesImageView
        
        if let species = speciesView?.species, let relationshipType = relationshipType, let speciesObservation = speciesObservation {
            
            //filer all relationship with this type
            let foundRelationships = speciesObservation.relationships.filter(using: "relationshipType = '\(relationshipType)'").filter(using: "toSpecies.index = \(species.index)")
            
            //find relationships that have toSpecies equal to species.index
            
            if !foundRelationships.isEmpty {
                
                dispatch_on_main {
                    realmDataController.delete(foundRelationships.first!)
                    
                    speciesView?.fadeOut(0.4, delay: 0.0, completion: {_ in
                        speciesView?.removeFromSuperview()
                    })
                    
                }
                
                
            }
        }
        
    }
    
    func showRelationshipDetailTap(_ sender: UITapGestureRecognizer) {
        if (sender.view as? DraggableSpeciesImageView) != nil {
            showRelationshipDetail(sender: sender.view as? DraggableSpeciesImageView)
        }
        
    }
    
    func showRelationshipDetail(sender: DraggableSpeciesImageView?) {
        
        if let speciesView = sender, let delegate = self.delegate, let species = speciesView.species, let relationshipType = relationshipType, let speciesObservation = speciesObservation {
            //filer all relationship with this type
            let foundRelationships = speciesObservation.relationships.filter(using: "relationshipType = '\(relationshipType)'").filter(using: "toSpecies.index = \(species.index)")
            
            //find relationships that have toSpecies equal to species.index
            if !foundRelationships.isEmpty {
                delegate.presentRelationshipDetailView(speciesView , relationship: foundRelationships.first!, speciesObservation: speciesObservation)
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
}


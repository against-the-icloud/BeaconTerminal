
//  ObservationDropView.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 6/5/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Material

class RelationshipDropView: DropTargetView {
    
    var fromSpecies: Species?
    var anchorCenter: CGPoint = CGPoint(x: 0, y: 0)
    var ringColor : UIColor?
    var draggableViews = [DraggableSpeciesImageView]()
    var anchorView : UIView?
    var speciesObservation: SpeciesObservation?
    var relationshipType: String?
    
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
    
    func addDraggableView(speciesImageView: DraggableSpeciesImageView) -> Bool {
        for dView in self.subviews {
            if ((dView as? DraggableSpeciesImageView) != nil) {
                let dView = dView as? DraggableSpeciesImageView
                if dView?.species?.index == speciesImageView.species?.index {
                    return false
                }
            }
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(RelationshipDropView.deleteSpeciesView(_:)))
        speciesImageView.addGestureRecognizer(tapGestureRecognizer)
        self.addSubview(speciesImageView)
        
        dispatch_on_main {
            realmDataController?.updateSpeciesObservation(speciesImageView.species!, speciesObservation: self.speciesObservation!, relationshipType: self.relationshipType!)
        }
        return true
    }
    
    func deleteSpeciesView(sender: UITapGestureRecognizer) {
        let speciesView = sender.view as? DraggableSpeciesImageView
        
        if let species = speciesView?.species, relationshipType = relationshipType, speciesObservation = speciesObservation {
            
            //filer all relationship with this type
            let foundRelationships = speciesObservation.relationships.filter("relationshipType = '\(relationshipType)'").filter("toSpecies.index = \(species.index)")
            
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
    
    
    
    func highlight() {
        self.backgroundColor = MaterialColor.grey.lighten3
        self.borderColor = MaterialColor.blue.base
    }
    
    func unhighlight() {
        self.backgroundColor = UIColor.whiteColor()
        self.borderColor = UIColor.blackColor()
    }
}
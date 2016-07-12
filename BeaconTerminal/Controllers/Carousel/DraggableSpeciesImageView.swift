//
//  DraggableSpeciesImageView.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 7/11/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit

class DraggableSpeciesImageView : DraggableImageView {
    
    var toSpecies: Species?
    var fromSpecies: Species?
    var doubleArrow = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func checkRelationship(draggableSpecies: DraggableSpeciesImageView) -> Bool {
        if ( toSpecies?.index == draggableSpecies.toSpecies?.index && fromSpecies?.index == draggableSpecies.fromSpecies?.index ) {
            return true
        }
        
        return false
    }
    
    
    
}
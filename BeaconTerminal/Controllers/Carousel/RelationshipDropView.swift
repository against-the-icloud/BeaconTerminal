
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

    var isEditing: Bool = false {
        didSet {
            if isEditing {
                self.clearsContextBeforeDrawing = true
            } else {
                self.clearsContextBeforeDrawing = false
            }
        }
    }
    var targetBorderWidth: CGFloat = 0.0
    var targetBorderColor = UIColor.blackColor()
    var lineWidth : CGFloat = 1.0

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
        
        
        self.addSubview(speciesImageView)

        return true
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
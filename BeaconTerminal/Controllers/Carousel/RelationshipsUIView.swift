//
//  RelationshipsUIView.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 7/10/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class RelationshipsUIView: UIView {
    
    @IBOutlet weak var dropView: RelationshipDropView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var anchorView: UIView!
    
    @IBInspectable var relationshipType: String?
    
    var targetPoints = [CGPoint]()
    var targetPaths = [Int: UIBezierPath]()
    var isEditing: Bool = false {
        didSet {
            if isEditing {
                self.clearsContextBeforeDrawing = true
            } else {
                self.clearsContextBeforeDrawing = false
            }
        }
    }
    var originPoint: CGPoint = CGPoint(x: 0, y: 0)
    var targetBorderWidth: CGFloat = 2.0
    var targetBorderColor = UIColor.blackColor()

    var draggableViews = [DraggableImageView]()
    
    
    var fromSpecies : Species?
    
    var speciesObservation : SpeciesObservation? {
        didSet {
            prepareAnchorView()
            prepareRelationships()
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func prepareRelationships() {
        //find the relationships for this 'type' consumer/producer
        //LOG.debug("finding \(self.relationshipType!)")
        let foundRelationships : Results<Relationship> = speciesObservation!.relationships.filter("relationshipType = '\(self.relationshipType!)'")
        
        
        let size : CGFloat = 50.0
       
        dropView.isEditing = true
        dropView.originPoint = makeAnchorCenter()
        if !foundRelationships.isEmpty {
            for (index, r) in foundRelationships.enumerate() {
                
                let point = Util.generateRandomPoint(UInt32(dropView.frame.size.width - CGFloat(size)), maxYValue: UInt32(dropView.frame.size.height - CGFloat(size)))
                
                
                let dView = DraggableImageView(frame: CGRectMake(point.x, point.y, size, size))
                dView.shouldSnapBack = false
                dView.shouldCopy = false
                
                dView.tag = index
            
                
                let speciesImage = RealmDataController.generateImageForSpecies((r.toSpecies?.index)!)
                dView.image = speciesImage
                
                dView.borderColor = UIColor.whiteColor()
                dView.borderWidth = 1.0
             
                draggableViews.append(dView)
                dropView.addSubview(dView)
                
                dropView.updatePath(dView.tag, pathPoint: dView.center)
                
                
                //LOG.debug("r \(r)")
            }
            
            dropView.setNeedsDisplay()
        }
    }
    
    func prepareAnchorView() {
        //rounded corners
        let cornerRadius = anchorView.frame.width / 2.0
//        anchorView.layer.borderColor = self.backgroundColor?.CGColor
        anchorView.layer.borderColor = UIColor.blueColor().CGColor

        anchorView.layer.borderWidth = 1.0
        anchorView.layer.masksToBounds = true
        anchorView.clipsToBounds = true
        anchorView.layer.cornerRadius = cornerRadius
        
        let newRect =  CGRectMake(0, 0, CGRectGetWidth(self.anchorView.frame), CGRectGetHeight(self.anchorView.frame))
        let path = UIBezierPath(roundedRect: CGRectInset(anchorView.bounds, 0.5, 0.5), cornerRadius: cornerRadius)
        let mask = CAShapeLayer()
        mask.frame = newRect
        mask.path = path.CGPath
        //anchorView.layer.mask = mask
        
        
        //background color
        if let species = fromSpecies {
            anchorView.backgroundColor = UIColor(rgba: species.color)
        }
    }
    
    func makeAnchorCenter() -> CGPoint {
        switch relationshipType! {
        case "producer":
            //left side mid
            return CGPointMake(0,dropView.frame.height / 2.0)
        case "consumer":
            //left side mid
            return CGPointMake(dropView.frame.width,dropView.frame.height / 2.0)
        case "mutual":
            //left side mid
            return CGPointMake(dropView.frame.width / 2.0,dropView.frame.height)
        default:
            //nothing
            print()
        }
        return CGPointMake(0,dropView.frame.height / 2.0)
    }
    
}
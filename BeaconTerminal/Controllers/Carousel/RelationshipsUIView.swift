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
        dropView.anchorCenter = makeAnchorCenter()
        dropView.ringColor = ringColor()
        
        LOG.debug("TYPE: \(relationshipType!)")

        if !foundRelationships.isEmpty {
            for (_, r) in foundRelationships.enumerate() {
                
                //no dups
                if r.toSpecies?.index != fromSpecies?.index {
                    
                    LOG.debug("from \(fromSpecies!.name)-\(fromSpecies!.index)   to \((r.toSpecies!.name))-\(r.toSpecies!.index)")
                    let point = Util.generateRandomPoint(UInt32(dropView.frame.size.width - CGFloat(size)), maxYValue: UInt32(dropView.frame.size.height - CGFloat(size)))
                    
                    
                    let dView = DraggableSpeciesImageView(frame: CGRectMake(point.x, point.y, size, size))
                    
                    dView.shouldSnapBack = false
                    dView.shouldCopy = false
                    dView.fromSpecies = fromSpecies
                    dView.toSpecies = r.toSpecies
                    dView.doubleArrow = shouldDoubleArrow()
                    dView.inwardArrow = shouldInwardArrow()
                    dView.tag = (r.toSpecies?.index)!
                    
                    
                    
                    let speciesImage = RealmDataController.generateImageForSpecies((r.toSpecies?.index)!)
                    dView.image = speciesImage
                    dropView.anchorView = anchorView
                    anchorView.hidden = false
                    anchorView.alpha = 0.5

                    dropView.addDraggableView(dView)
                }
                
              
            }            
        }
    }
    
    func prepareAnchorView() {
        //rounded corners
        let cornerRadius = anchorView.frame.width / 2.0
//        anchorView.layer.borderColor = self.backgroundColor?.CGColor
        anchorView.layer.borderColor = UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0 ).CGColor

        anchorView.layer.borderWidth = 3.0
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
            return CGPointMake(dropView.frame.width / 2.0,dropView.frame.height - 10)
        default:
            //nothing
            print()
        }
        return CGPointMake(0,dropView.frame.height / 2.0)
    }
    
    func shouldDoubleArrow() -> Bool {
        switch relationshipType! {
        case "producer":
            //left side mid
            return false
        case "consumer":
            //left side mid
            return true
        case "mutual":
            //left side mid
            return true
        default:
            //nothing
            return false
        }
        
    }
    
    func shouldInwardArrow() -> Bool {
        switch relationshipType! {
        case "producer":
            //left side mid
            return false
        case "consumer":
            //left side mid
            return true
        case "mutual":
            //left side mid
            return false
        default:
            //nothing
            return false
        }
        
    }
    
    
    func ringColor() -> UIColor {
        switch relationshipType! {
        case "producer":
            //left side mid
            return UIColor.redColor()
        case "consumer":
            //left side mid
            return UIColor.blueColor()
        case "mutual":
            //left side mid
            return UIColor.brownColor()
        default:
            //nothing
            print()
        }
        
        return UIColor.yellowColor()
    }
    
}
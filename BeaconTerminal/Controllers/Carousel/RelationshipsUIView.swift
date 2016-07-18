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
    
    @IBInspectable var relationshipType: String?
    
    var targetPoints = [CGPoint]()
    var targetPaths = [Int: UIBezierPath]()
    
    var originPoint: CGPoint = CGPoint(x: 0, y: 0)
    var targetBorderWidth: CGFloat = 2.0
    var targetBorderColor = UIColor.blackColor()
    
    var fromSpecies : Species?
    
    //    var speciesObservation : SpeciesObservation?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func addRelationship(relationships: Results<Relationship>) {
        let size : CGFloat = 75.0
        

        for relationship in relationships {
            let point = Util.generateRandomPoint(UInt32(dropView.frame.size.width - CGFloat(size)), maxYValue: UInt32(dropView.frame.size.height - CGFloat(size)))
            
            let dView = DraggableSpeciesImageView(frame: CGRectMake(point.x, point.y, size, size))
            
            dView.shouldSnapBack = false
            dView.shouldCopy = false
            dView.shouldClipBounds = false
            dView.dragScaleFactor = 1.2
            dView.fromSpecies = fromSpecies
            dView.toSpecies = relationship.toSpecies
            dView.tag = (relationship.toSpecies?.index)!
            
            let speciesImage = RealmDataController.generateImageForSpecies((relationship.toSpecies?.index)!)
            dView.image = speciesImage
            
            dropView.addSubview(dView)
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
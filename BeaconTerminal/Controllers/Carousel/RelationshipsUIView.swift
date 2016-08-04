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
    
    var speciesObservation: SpeciesObservation? {
        didSet {
            dropView.speciesObservation = speciesObservation!
        }
    }
    var targetBorderWidth: CGFloat = 2.0
    var targetBorderColor = UIColor.black()
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareView()
    }
    
    func prepareView() {
        dropView.relationshipType = relationshipType
        dropView.fromSpecies = fromSpecies
    }
    
    func addRelationship(_ relationships: Results<Relationship>) {
        
        for relationship in relationships {
            
            let size : CGFloat = 75.0
            
            if dropView != nil {
                
                let dView = DraggableSpeciesImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
                dView.isUserInteractionEnabled = true
                
                if let species = relationship.toSpecies {
                    let speciesImage = RealmDataController.generateImageForSpecies(species.index)
                    dView.image = speciesImage
                    dView.species = species
                    dropView.addSubview(dView)
                }
                
            }
        
        }
    
    }
    

    func ringColor() -> UIColor {
        switch relationshipType! {
        case "producer":
            //left side mid
            return UIColor.red
        case "consumer":
            //left side mid
            return UIColor.blue
        case "mutual":
            //left side mid
            return UIColor.brown
        default:
            //nothing
            print()
        }
        
        return UIColor.yellow
    }
    
}

//
//  CoverFlowCell.swift
//  
//
//  Created by Anthony Perritano on 7/7/16.
//
//

import Foundation
import RealmSwift
import UIKit

enum RelationshipType: String {
    case producer = "producer"
    case consumer = "consumer"
    case mutual = "mutual"
}


class CoverFlowCell: UICollectionViewCell {
    @IBOutlet weak var profileView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var expandButton: UIButton!
    
    @IBOutlet var relationshipViews: [RelationshipsUIView]!
    
    var fromSpecies : Species?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func prepareCell(speciesObservation: SpeciesObservation, fromSpecies: Species) {
        
        let rounded : CGFloat = profileView.frame.size.width / 2.0
        profileView.layer.cornerRadius = rounded
        
        self.fromSpecies = fromSpecies
        
    
        let speciesImage = RealmDataController.generateImageForSpecies(fromSpecies.index)
        
        
        self.profileView.contentMode = .ScaleAspectFit
        self.profileView.image = speciesImage
        
    
        
        for relationshipView in relationshipViews {
            relationshipView.fromSpecies = fromSpecies
            relationshipView.speciesObservation = speciesObservation
            
        }
        
    }
    
    
    
}


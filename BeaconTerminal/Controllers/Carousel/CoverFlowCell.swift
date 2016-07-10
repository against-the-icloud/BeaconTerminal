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

class CoverFlowCell: UICollectionViewCell {
    @IBOutlet weak var profileView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var expandButton: UIButton!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //LOG.debug(profileView.description)
        
        
        let rounded : CGFloat = profileView.frame.size.width / 2.0
        profileView.layer.cornerRadius = rounded
    }
    
    func prepareCell(speciesObservations: Results<SpeciesObservation>, fromSpecies: Species) {
        
        let speciesObservation = speciesObservations[0]
        
        let speciesImage = RealmDataController.generateImageForSpecies(fromSpecies.index)
        
        
        self.profileView.contentMode = .ScaleAspectFit
        
        
        
        
        self.profileView.image = speciesImage
        
    }
    
    
    
}


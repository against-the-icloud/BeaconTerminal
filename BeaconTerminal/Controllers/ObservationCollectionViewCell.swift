//
//  ObservationCollectionViewCell.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 6/7/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Spring

class ObservationCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var featuredImageView: UIImageView!
    @IBOutlet weak var observationTitleLabel : UILabel!
    @IBOutlet weak var testLabel : UILabel!
    
    
    @IBOutlet var observationViewsCollection: [ObservationView]!
    @IBOutlet weak var profileImageView: SpringImageView!
    
    var species: Species! {
        didSet {
            updateUI()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func updateUI() {

        let speciesImage = RealmDataController.generateImageForSpecies(species.index)

        profileImageView.image = speciesImage
        profileImageView.contentMode = .ScaleAspectFit

        for obView in observationViewsCollection {
            obView.mainSpiecesImage.image = speciesImage
        }

        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
    }
}
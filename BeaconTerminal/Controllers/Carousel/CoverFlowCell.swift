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
import Material

protocol PreferenceEditDelegate {
    func preferenceEdit(_ speciesObservation: SpeciesObservation, sender: UIButton)
}

class CoverFlowCell: UICollectionViewCell {
    @IBOutlet weak var profileView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var expandButton: UIButton!
    
    @IBOutlet var relationshipViews: [RelationshipsUIView]!
    
    @IBOutlet weak var preferenceView: PreferenceUIView!
    
    @IBOutlet weak var preferenceEditButton: UIButton!
    var isFullscreen : Bool = false {
        didSet {
            //previousSize = self.frame
        }
    }
    var previousSize: CGRect?
    var fromSpecies : Species?
    var delegate: PreferenceEditDelegate?
    var speciesObservation: SpeciesObservation?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareView()
    }
    
    @IBAction func editPreferencesAction(_ sender: UIButton) {
        if let so = speciesObservation {
            delegate?.preferenceEdit(so, sender: sender)
        }
    }
    
    func prepareCell(_ speciesObservation: SpeciesObservation, fromSpecies: Species) {
        self.speciesObservation = speciesObservation
        
        let rounded : CGFloat = profileView.frame.size.width / 2.0
        profileView.layer.cornerRadius = rounded
        
        self.fromSpecies = fromSpecies
        
        let speciesImage = RealmDataController.generateImageForSpecies(fromSpecies.index, isHighlighted: true)
        
        self.profileView.contentMode = .scaleAspectFit
        self.profileView.image = speciesImage
        
        //setup PreferenceView
        
        preferenceView.speciesObservation = self.speciesObservation
        
        //setup RelationshipView
        for relationshipView in relationshipViews {
            let foundRelationships : Results<Relationship> = speciesObservation.relationships.filter(using: "relationshipType = '\(relationshipView.relationshipType!)'")
            
            //LOG.debug("found relationships for \(fromSpecies.index) relationships \(foundRelationships)")
            relationshipView.speciesObservation = speciesObservation
            relationshipView.addRelationship(foundRelationships)
        }        
    }
    
    func prepareView() {
        self.contentView.layer.cornerRadius = 10.0;
        self.contentView.layer.borderWidth = 1.0;
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowRadius = 1.0
        self.layer.shadowOpacity = 0.7
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect:self.bounds, cornerRadius:self.contentView.layer.cornerRadius).cgPath
    }
  
}





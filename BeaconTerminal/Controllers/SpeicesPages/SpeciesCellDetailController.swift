
import Foundation
import UIKit
import RealmSwift

class SpeciesCellDetailController: UIViewController {
    
    @IBOutlet weak var toSpeciesImageView: UIImageView!

    var fromSpeciesIndex: Int?
    var relationship: Relationship?
    var speciesPreference: SpeciesPreference?
    var used = false
    
    var toSpeciesIndex: Int? {
        get {
            guard let toSpeciesIndex =  relationship?.toSpecies?.index else {
                return nil
            }
            
            return toSpeciesIndex
        }
    }
    
    var habitatIndex: Int? {
        get {
            guard let habitatIndex =  speciesPreference?.habitat?.index else {
                return nil
            }
            
            return habitatIndex
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func delete() {
        self.relationship = nil
        self.used = false
        self.fromSpeciesIndex = -1
        self.toSpeciesImageView.image = nil
        self.toSpeciesImageView.isHidden = true
    }
    
    func deleteSpeciesPreference() {
        self.speciesPreference = nil
        self.used = false
        self.fromSpeciesIndex = -1
        self.toSpeciesImageView.image = nil
        self.toSpeciesImageView.isHidden = true
    }
    
    func updateCell(withRelationship relationship: Relationship) {
        self.relationship = relationship
        self.used = true
        prepareView()
    }
    
    func updateCell(withSpeciesPreference speciesPreference: SpeciesPreference) {
        self.speciesPreference = speciesPreference
        self.used = true
        prepareSpeciesPreferenceView()
    }
    
    func prepareSpeciesPreferenceView() {
        guard let speciesPreference = self.speciesPreference else {
            return
        }
        
        guard let habitatName = speciesPreference.habitat?.name else {
            return
        }
        
        
        let habitatImage = UIImage(named: habitatName)
        
        toSpeciesImageView.image = habitatImage
        toSpeciesImageView.isHidden = false
    }
    func prepareView() {
        guard let relationship = self.relationship else {
            return
        }
        
        guard let toSpeciesIndex = relationship.toSpecies?.index else {
            return
        }
        
        
        let toSpeciesImage = RealmDataController.generateImageForSpecies(toSpeciesIndex, isHighlighted: true)
        
        toSpeciesImageView.image = toSpeciesImage
        toSpeciesImageView.isHidden = false
    }
    
}

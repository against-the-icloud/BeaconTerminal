
import Foundation
import UIKit
import RealmSwift

class SpeciesCellDetailController: UIViewController {
    
    @IBOutlet weak var toSpeciesImageView: UIImageView!

    var fromSpeciesIndex: Int?
    var relationship: Relationship?
    var used = false
    
    var toSpeciesIndex: Int? {
        get {
            guard let toSpeciesIndex =  relationship?.toSpecies?.index else {
                return nil
            }
            
            return toSpeciesIndex
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateCell(withRelationship relationship: Relationship) {
        self.relationship = relationship
        self.used = true
        prepareView()
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

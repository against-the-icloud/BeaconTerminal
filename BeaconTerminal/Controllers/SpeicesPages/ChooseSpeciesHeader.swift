

import Foundation
import UIKit

class ChooseSpeciesHeader: UICollectionReusableView {
    
    static let chooseSpeciesHeaderIdentifier = "ChooseSpeciesHeader"
    
    @IBOutlet weak var fromSpeciesImageView: UIImageView!
    @IBOutlet weak var relationshipLabel: UILabel!

    @IBOutlet weak var toSpeciesImageView: UIImageView!
}

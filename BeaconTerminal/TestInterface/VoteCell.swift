

import UIKit

class VoteCell: UICollectionViewCell {
    
    

    @IBOutlet weak var versusSpeciesImageView: UIImageView!
    @IBOutlet weak var mainSpeciesImageView: UIImageView!
    
    @IBOutlet weak var votesLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
  
}

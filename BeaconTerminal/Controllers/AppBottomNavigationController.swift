

import UIKit
import Material

class AppBottomNavigationController: BottomNavigationController {

    override func prepareView() {
        super.prepareView()
        prepareNavigationItem()
    }
    
    /// Handles the menuButton.
    internal func handleMenuButton(_ sender: UITapGestureRecognizer) {
        navigationDrawerController?.openLeftView()
    }
    
    /// Prepares the navigationItem.
    private func prepareNavigationItem() {
        

        changeGroupAndSectionTitles("ECOSYSTEM 2", newSectionTitle: "6TV")

        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleMenuButton))
        
        navigationItem.detailLabel.isUserInteractionEnabled = true
        navigationItem.detailLabel.addGestureRecognizer(tap)
    }
    

    func changeGroupAndSectionTitles(_ newGroupTitle: String?, newSectionTitle: String?) {
        
        if let gt = newGroupTitle, let ns = newSectionTitle {
            navigationItem.title = "GROUP: \(gt)"
            navigationItem.titleLabel.textAlignment = .left
            navigationItem.titleLabel.textColor = Color.white
            
            navigationItem.detail = "SECTION: \(ns)"
            navigationItem.detailLabel.textAlignment = .left
            navigationItem.detailLabel.textColor = Color.white
        }

    }

}


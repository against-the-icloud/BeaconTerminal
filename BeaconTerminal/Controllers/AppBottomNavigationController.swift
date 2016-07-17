

import UIKit
import Material

class AppBottomNavigationController: BottomNavigationController {

    override func prepareView() {
        super.prepareView()
        prepareNavigationItem()
        
    }
    
    /// Handles the menuButton.
    internal func handleMenuButton(sender: UITapGestureRecognizer) {
        navigationDrawerController?.openLeftView()
    }
    
    /// Prepares the navigationItem.
    private func prepareNavigationItem() {
        

        changeGroupAndSectionTitles("ECOSYSTEM 2", newSectionTitle: "6TV")

        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleMenuButton))
        
        navigationItem.detailLabel.userInteractionEnabled = true
        navigationItem.detailLabel.addGestureRecognizer(tap)
    }
    

    func changeGroupAndSectionTitles(newGroupTitle: String, newSectionTitle: String) {
        navigationItem.title = "GROUP: \(newGroupTitle)"
        navigationItem.titleLabel.textAlignment = .Left
        navigationItem.titleLabel.textColor = MaterialColor.white
        
        navigationItem.detail = "SECTION: \(newSectionTitle)"
        navigationItem.detailLabel.textAlignment = .Left
        navigationItem.detailLabel.textColor = MaterialColor.white
    }

    /// Prepares the tabBar.
    private func prepareTabBar() {
        tabBar.tintColor = MaterialColor.white
        tabBar.backgroundColor = MaterialColor.grey.darken4
    }
}


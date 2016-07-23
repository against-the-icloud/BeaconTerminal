

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
    

    func changeGroupAndSectionTitles(newGroupTitle: String?, newSectionTitle: String?) {
        
        if let gt = newGroupTitle, ns = newSectionTitle {
            navigationItem.title = "GROUP: \(gt)"
            navigationItem.titleLabel.textAlignment = .Left
            navigationItem.titleLabel.textColor = MaterialColor.white
            
            navigationItem.detail = "SECTION: \(ns)"
            navigationItem.detailLabel.textAlignment = .Left
            navigationItem.detailLabel.textColor = MaterialColor.white
        }

    }

    /// Prepares the tabBar.
    private func prepareTabBar() {
        tabBar.tintColor = MaterialColor.white
        tabBar.backgroundColor = MaterialColor.grey.darken4
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        LOG.debug("\(viewController)")
    }
    
    override func tabBarController(tabBarController: UITabBarController, animationControllerForTransitionFromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        LOG.debug("from \(fromVC)")
        LOG.debug("to \(toVC)")
        return super.tabBarController(tabBarController, animationControllerForTransitionFromViewController: fromVC, toViewController: toVC)
    }
}


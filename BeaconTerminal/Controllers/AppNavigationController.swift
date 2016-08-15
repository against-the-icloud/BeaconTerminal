import UIKit
import Material

class AppNavigationController: NavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    /// Prepares the navigationBar
    private func prepareNavigationBar() {
        navigationBar.tintColor = Color.white
        navigationBar.backgroundColor = Util.flatBlack
        navigationBar.statusBarStyle = .lightContent
        //LOG.debug("navigationbar height \(navigationBar.height)")
    }
}

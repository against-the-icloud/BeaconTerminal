import UIKit
import Material

class AppNavigationController: NavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //navigationBar.statusBarStyle = .lightContent
    }
    
    /// Prepares the navigationBar
    private func prepareNavigationBar() {
        navigationBar.tintColor = Color.white
        //navigationBar.backgroundColor = Util.flatBlack
        navigationBar.backgroundColor = Color.blue.base
    }
    
}

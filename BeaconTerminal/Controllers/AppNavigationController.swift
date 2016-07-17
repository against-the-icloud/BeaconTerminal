import UIKit
import Material

class AppNavigationController: NavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNavigationBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationBar.statusBarStyle = .LightContent
    }
    
    /// Prepares the navigationBar
    private func prepareNavigationBar() {
        navigationBar.tintColor = MaterialColor.white
        navigationBar.backgroundColor = MaterialColor.blue.base
    }
}
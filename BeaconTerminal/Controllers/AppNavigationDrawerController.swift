import UIKit
import Material

class AppNavigationDrawerController: NavigationDrawerController, NavigationDrawerControllerDelegate {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

    }
}

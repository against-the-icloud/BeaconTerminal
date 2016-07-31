import UIKit
import Material

class AppNavigationDrawerController: NavigationDrawerController, NavigationDrawerControllerDelegate {
	override func prepareView() {
		super.prepareView()
		delegate = self
	}	
}

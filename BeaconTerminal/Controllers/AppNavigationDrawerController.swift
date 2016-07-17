import UIKit
import Material

class AppNavigationDrawerController: NavigationDrawerController, NavigationDrawerControllerDelegate {
	override func prepareView() {
		super.prepareView()
		delegate = self
	}
	
	func navigationDrawerPanDidBegin(navigationDrawerController: NavigationDrawerController, point: CGPoint, position: NavigationDrawerPosition) {
		print("NavigationDrawerController - Pan Began");
	}
	
	func navigationDrawerPanDidEnd(navigationDrawerController: NavigationDrawerController, point: CGPoint, position: NavigationDrawerPosition) {
		print("NavigationDrawerController - Pan Ended");
	}
	
	func navigationDrawerWillOpen(navigationDrawerController: NavigationDrawerController, position: NavigationDrawerPosition) {
		print("NavigationDrawerController - Will Open");
	}
	
	func navigationDrawerDidOpen(navigationDrawerController: NavigationDrawerController, position: NavigationDrawerPosition) {
		print("NavigationDrawerController - DId Open");
	}
	
	func navigationDrawerWillClose(navigationDrawerController: NavigationDrawerController, position: NavigationDrawerPosition) {
		print("NavigationDrawerController - Will Close");
	}
	
	func navigationDrawerDidClose(navigationDrawerController: NavigationDrawerController, position: NavigationDrawerPosition) {
		print("NavigationDrawerController - Did Close");
	}
	
	func navigationDrawerStatusBarHiddenState(navigationDrawerController: NavigationDrawerController, hidden: Bool) {
		print("NavigationDrawerController - Status Bar Hidden: ", hidden ? "Yes" : "No");
	}
	
	func navigationDrawerDidTap(navigationDrawerController: NavigationDrawerController, point: CGPoint, position: NavigationDrawerPosition) {
		print("NavigationDrawerController - Did Tap");
	}
	
	func navigationDrawerPanDidChange(navigationDrawerController: NavigationDrawerController, point: CGPoint, position: NavigationDrawerPosition) {
        print("NavigationDrawerController - Did Change");
	}
}

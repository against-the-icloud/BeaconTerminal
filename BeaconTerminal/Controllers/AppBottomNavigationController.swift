

import UIKit
import Material
import RealmSwift

class AppBottomNavigationController: BottomNavigationController {
    
    var notificationToken: NotificationToken? = nil
    
    var runtimeResults: Results<Runtime>?
    
    deinit {
        if notificationToken != nil {
            notificationToken?.stop()
        }
    }
    
    
    override func prepareView() {
        super.prepareView()
        prepareNavigationItem()
        prepareTabBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNotification()
    }
    
    /// Handles the menuButton.
    internal func handleMenuButton(_ sender: UITapGestureRecognizer) {
        navigationDrawerController?.openLeftView()
    }
    
    
    private func prepareTabBar() {
        tabBar.tintColor = UIColor.black()
        tabBar.backgroundColor = UIColor.white()
        tabBar.itemPositioning = UITabBarItemPositioning.automatic
        self.selectedIndex = 0
    }
    
    /// Prepares the navigationItem.
    private func prepareNavigationItem() {
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleMenuButton))
        navigationItem.detailLabel.isUserInteractionEnabled = true
        navigationItem.detailLabel.addGestureRecognizer(tap)
    }
    
    func prepareNotification() {
        runtimeResults = realm!.allObjects(ofType: Runtime.self)
        
        // Observe Notifications
        notificationToken = runtimeResults?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            
            guard let bottomNav = self else { return }
            
            switch changes {
            case .Initial(let runtimeResults):
                
                bottomNav.updateUI(withRuntimeResults: runtimeResults)
                // Results are now populated and can be accessed without blocking the UI
                
                break
            case .Update(let runtimeResults, _, _, _):
                
                bottomNav.updateUI(withRuntimeResults: runtimeResults)
                
                break
            case .Error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
    }
    
    func updateUI(withRuntimeResults runtimeResults: Results<Runtime>) {
        self.runtimeResults = runtimeResults
        
        if runtimeResults[0].currentGroup != nil {
            let group = runtimeResults[0].currentGroup
            let section = runtimeResults[0].currentSection
            changeTitle(with: group, and: section)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func changeTitle(with group: Group?, and section: Section?) {
        if let g = group, let gt = g.name, let ns = section?.name {
            
            if g.members.count > 0 {
                var memberTitle = ""
                for member in g.members {
                    if memberTitle.isEmpty {
                        memberTitle = "\(member.name!)"
                    } else {
                        memberTitle = "\(memberTitle),\(member.name!)"
                    }
                }
                
                navigationItem.title = "\(gt): \(memberTitle)"
                
            } else {
                navigationItem.title = "GROUP: \(gt)"
            }
            navigationItem.titleLabel.textAlignment = .left
            navigationItem.titleLabel.textColor = Color.white
            
            navigationItem.detail = "SECTION: \(ns)"
            navigationItem.detailLabel.textAlignment = .left
            navigationItem.detailLabel.textColor = Color.white
        }
    }
    
    func selectTab(with index: Int) {
        self.selectedIndex = index
        tabBarController?.selectedIndex = index 
        if let item = tabBar.selectedItem {
            checkBadges(with: item.title!)
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.title == Tabs.maps.rawValue {
            getAppDelegate().speciesViewController?.showSpeciesMenu(showHidden: false)
            BadgeUtil.badge(shouldShow: false)
        } else {
            getAppDelegate().speciesViewController?.showSpeciesMenu(showHidden: true)
            BadgeUtil.badge(shouldShow: true)
        }
    }
    
    func checkBadges(with title: String) {
        switch title {
        case Tabs.maps.rawValue:
            getAppDelegate().speciesViewController?.showSpeciesMenu(showHidden: false)
            BadgeUtil.badge(shouldShow: false)
            break
        default:
            getAppDelegate().speciesViewController?.showSpeciesMenu(showHidden: true)
            BadgeUtil.badge(shouldShow: true)
            break
        }
    }
}


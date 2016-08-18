
import Foundation
import UIKit
import RealmSwift
import Material

class MapViewController: UIViewController {
    
    // MARK: IBOutlets
    var notificationToken: NotificationToken? = nil
    
    var currentGroup: Group?
    let groupId = 0
    var allSpecies: Results<Species>?
    var selectedCell: CoverFlowCell?
    var previousSize: CGRect?
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        if notificationToken != nil {
            notificationToken?.stop()
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        prepareTabBarItem()

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareTabBarItem()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()        
    }
    
    func prepareView() {
        
    }
    
    
    // MARK: View Life Cycle
    private func prepareTabBarItem() {
        tabBarItem.title = Tabs.maps.rawValue
        let iconImage = UIImage(named: "tb_map")!
        tabBarItem.image = iconImage
        Util.prepareTabBar(with: tabBarItem)
    }
}

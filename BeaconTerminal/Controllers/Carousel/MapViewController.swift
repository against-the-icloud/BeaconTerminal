
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
    
    
    deinit {
        if notificationToken != nil {
            notificationToken?.stop()
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
    
    func prepareView() {
        
    }
    
    func prepareNavigationView() {
        self.navigationController?.navigationBar.tintColor = UIColor.blue
        navigationItem.titleLabel.textAlignment = .left
        navigationItem.titleLabel.textColor = Color.white
        
        navigationItem.detail = "SECTION:"
        navigationItem.detailLabel.textAlignment = .left
        navigationItem.detailLabel.textColor = Color.white
    }
}

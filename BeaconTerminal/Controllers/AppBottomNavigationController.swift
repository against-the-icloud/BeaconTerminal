

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
    
    
    /**
     An initializer that initializes the object with a NSCoder object.
     - Parameter aDecoder: A NSCoder instance.
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     An initializer that initializes the object with an Optional nib and bundle.
     - Parameter nibNameOrNil: An Optional String for the nib.
     - Parameter bundle: An Optional NSBundle where the nib is located.
     */
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public override init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNavigationItem()
        prepareNotification()
    }
    
    override func prepareView() {
        super.prepareView()
        
    }
    
    /// Handles the menuButton.
    internal func handleMenuButton(_ sender: UITapGestureRecognizer) {
        navigationDrawerController?.openLeftView()
    }
    
    /// Prepares the navigationItem.
    private func prepareNavigationItem() {
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleMenuButton))
        navigationItem.detailLabel.isUserInteractionEnabled = true
        navigationItem.detailLabel.addGestureRecognizer(tap)
    }
    
    
    
    func prepareNotification() {
        
        runtimeResults = realmDataController?.realm.allObjects(ofType: Runtime.self)
        
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
}


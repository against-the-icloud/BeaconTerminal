

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
    }
    
    override func prepareView() {
        super.prepareView()
        prepareNavigationItem()
        prepareNotification()
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
            switch changes {
            case .Initial(let runtimeResults):
                
                if runtimeResults[0].currentGroup != nil {
                    let group = runtimeResults[0].currentGroup
                    let section = runtimeResults[0].currentSection
                    self?.changeTitle(with: group, and: section)
                }
                // Results are now populated and can be accessed without blocking the UI
                
                break
            case .Update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                //                collectionView.performBatchUpdates({
                //                    collectionView.insertItemsAtIndexPaths(insertions.map { NSIndexPath(forRow: $0, inSection: 0) })
                //                    collectionView.deleteItemsAtIndexPaths(deletions.map { NSIndexPath(forRow: $0, inSection: 0) })
                //                    collectionView.reloadItemsAtIndexPaths(modifications.map { NSIndexPath(forRow: $0, inSection: 0) })
                //                    }, completion: { _ in })
                break
            case .Error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
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


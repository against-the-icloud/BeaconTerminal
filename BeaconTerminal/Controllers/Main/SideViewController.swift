//
// Created by Anthony Perritano on 5/17/16.
// Copyright (c) 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Material
import RealmSwift

class SideViewController: UITableViewController {
    
    
    // MARK: View Methods
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = UIColor.white()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    // MARK: table
    
    /// Select item at row in tableView.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        for cell in tableView.visibleCells {
            cell.selectionStyle = .default
        }
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.selectionStyle = .blue
        }
                
        switch indexPath.section {
        case 0:
            getAppDelegate().prepareViews(applicationType: ApplicationType.login)
            break
        case 1:
            self.navigationDrawerController?.closeLeftView()
            break
        case 1:
            self.navigationDrawerController?.closeLeftView()
            break
        default:
            break
        }
    }
    
    func showSelectedCell(with applicationState: ApplicationType) {
        
        var indexPath: IndexPath?
        
        switch applicationState {
        case .objectGroup:
            indexPath = IndexPath(row: 0, section: 1)
            break
        case .placeTerminal:
            indexPath = IndexPath(row: 1, section: 0)
            break
        case .placeGroup:
            indexPath = IndexPath(row: 0, section: 0)
            break
        default:
            break
        }
        
        if let indexPath = indexPath {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.contentView.backgroundColor = Color.blueGrey.base
            // cell?.selectedBackgroundView?.backgroundColor = Color.blueGrey.base
            cell?.selectionStyle = .blue
        }
        
    }
    
    @IBAction func unwindToSideMenu(segue: UIStoryboardSegue) {
        self.navigationDrawerController?.closeLeftView()
    }
    
}

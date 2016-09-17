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
        
        if (indexPath as NSIndexPath).section == 0 {
            switch (indexPath as NSIndexPath).row {
            case 0:
                // Mark: Place Group
                
                if let runtime = realm?.runtime() {
                    try! realm?.write {
                        runtime.currentSpeciesIndex.value = nil
                        runtime.currentGroupIndex.value = nil
                        realm?.add(runtime, update: true)
                    }
                    
                    realmDataController.deleteAllSpeciesObservations()
                }
                
                getAppDelegate().changeSystemStateTo(.placeGroup)
        
                
                let terminalStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let terminalViewController = terminalStoryboard.instantiateViewController(withIdentifier: "mainContainerController") as! MainContainerController
                
                let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
                let sideViewController = mainStoryBoard.instantiateViewController(withIdentifier: "sideViewController") as! SideViewController
                
                let navigationController: AppNavigationController = AppNavigationController(rootViewController: terminalViewController)
                _ = NavigationDrawerController(rootViewController: navigationController, leftViewController:sideViewController)
                
                navigationController.isNavigationBarHidden = true
                navigationController.statusBarStyle = .default
                
                navigationDrawerController!.transitionFromRootViewController(toViewController: navigationController,
                                                                             duration: 0,
                                                                             options: [],
                                                                             animations: nil,
                                                                             completion: {
                                                                                [weak self] _ in
                                                                                  getAppDelegate().prepareDB(withSectionName: SECTION_NAME)
                                                                                getAppDelegate().setupConnection()
                                                                                self?.navigationDrawerController?.closeLeftView()
                    })
                
                break
            case 1:                                
                // Mark: place terminal
                
                if let runtime = realm?.runtime() {
                    try! realm?.write {
                        runtime.currentSpeciesIndex.value = nil
                        runtime.currentGroupIndex.value = nil
                        realm?.add(runtime, update: true)
                    }
                    
                    realmDataController.deleteAllSpeciesObservations()
                }
                
                getAppDelegate().changeSystemStateTo(.placeTerminal)
                
                let storyboard = UIStoryboard(name: "Terminal", bundle: nil)
                let terminalViewController = storyboard.instantiateViewController(withIdentifier: "terminalMainViewController") as! TerminalMainViewController
                
                let navigationController: AppNavigationController = AppNavigationController(rootViewController: terminalViewController)
                navigationController.isNavigationBarHidden = true
                navigationController.statusBarStyle = .default
                
                
                
                BadgeUtil.badge(shouldShow: false)
                
                if let sm = getAppDelegate().speciesViewController {
                    sm.showSpeciesMenu(showHidden: false)
                }
                
                
                navigationDrawerController!.transitionFromRootViewController(toViewController: navigationController,
                                                                             duration: 0,
                                                                             options: [],
                                                                             animations: nil,
                                                                             completion: {
                                                                                [weak self] _ in
                                                                                self?.navigationDrawerController?.closeLeftView()
                                                                                
                                                                                getAppDelegate().prepareDB(withSectionName: SECTION_NAME)
                                                                                getAppDelegate().setupConnection()
                                                                                
                                                                                
                                                                                
                    })
                
                
            default:
                break
            }
        } else if (indexPath as NSIndexPath).section == 1 {
            switch (indexPath as NSIndexPath).row {
            case 0:
                
                getAppDelegate().changeSystemStateTo(.objectGroup)
                
                //object group tablet
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainViewController = storyboard.instantiateViewController(withIdentifier: "mainViewController") as! MainViewController
                
                
                let scratchPadViewController = storyboard.instantiateViewController(withIdentifier: "scratchPadViewController") as! ScratchPadViewController
                
                let bottomNavigationController: AppBottomNavigationController = AppBottomNavigationController()
                
                bottomNavigationController.viewControllers = [mainViewController, scratchPadViewController]
                
                //create top navigationbar
                let navigationController: AppNavigationController = AppNavigationController(rootViewController: bottomNavigationController)
                
                navigationController.statusBarStyle = .lightContent
                
                navigationDrawerController?.transitionFromRootViewController(toViewController: navigationController,
                                                                             duration: 0,
                                                                             options: [],
                                                                             animations: nil,
                                                                             completion: {
                                                                                [weak self] _ in
                                                                                self?.navigationDrawerController?.closeLeftView()
                    })
                
                
            default:
                break
            }
        } else if (indexPath as NSIndexPath).section == 2 {
            switch (indexPath as NSIndexPath).row {
            case 0:
                break
            case 1:
                break
            default:
                break
            }
        } else if (indexPath as NSIndexPath).section == 3 {
            switch (indexPath as NSIndexPath).row {
            case 0:
                //control panel
                let storyboard = UIStoryboard(name: "Popover", bundle: nil)
                let loginNavigationController = storyboard.instantiateViewController(withIdentifier: "loginNavigationController") as! UINavigationController
                
                self.present(loginNavigationController, animated: true, completion: {})
            default:
                break
            }
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

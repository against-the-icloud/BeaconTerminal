//
// Created by Anthony Perritano on 5/17/16.
// Copyright (c) 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Material

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
                
                getAppDelegate().changeSystemStateTo(.placeGroup)
                
                //place group tablet
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainViewController = storyboard.instantiateViewController(withIdentifier: "mainViewController") as! MainViewController
                //mainViewController.changeApplicationState(ApplicationState.PLACE_GROUP)


                let scratchPadViewController = storyboard.instantiateViewController(withIdentifier: "scratchPadViewController") as! ScratchPadViewController
                
                let mapViewController = storyboard.instantiateViewController(withIdentifier: "mapViewController") as! MapViewController

                let bottomNavigationController: AppBottomNavigationController = AppBottomNavigationController()

                bottomNavigationController.viewControllers = [mainViewController, scratchPadViewController, mapViewController]
                bottomNavigationController.selectedIndex = 0

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
            case 1:
                
                
                // Mark: place terminal


                getAppDelegate().changeSystemStateTo(.placeTerminal)
                
                let storyboard = UIStoryboard(name: "Terminal", bundle: nil)
                let terminalViewController = storyboard.instantiateViewController(withIdentifier: "terminalViewController") as! TerminalViewController

                let navigationController: AppNavigationController = AppNavigationController(rootViewController: terminalViewController)
                navigationController.isNavigationBarHidden = true
                navigationController.statusBarStyle = .default
                


                BadgeUtil.badge(shouldShow: false)
                getAppDelegate().speciesViewController.showSpeciesMenu(showHidden: false)
                
                navigationDrawerController!.transitionFromRootViewController(toViewController: navigationController,
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
                //control panel
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controlPanelViewController = storyboard.instantiateViewController(withIdentifier: "controlPanelViewController") as! ControlPanelViewController
                
                //create top navigationbar
                let navigationController: AppNavigationController = AppNavigationController(rootViewController: controlPanelViewController)

                
                navigationDrawerController?.transitionFromRootViewController(toViewController: navigationController,
                        duration: 0,
                        options: [],
                        animations: nil,
                        completion: {
                            [weak self] _ in
                            self?.navigationDrawerController?.closeLeftView()
                        })
            case 1:
                
                //debug
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controlPanelViewController = storyboard.instantiateViewController(withIdentifier: "controlPanelViewController") as! ControlPanelViewController
                
                //create top navigationbar
                let navigationController: AppNavigationController = AppNavigationController(rootViewController: controlPanelViewController)
                
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

//
// Created by Anthony Perritano on 5/17/16.
// Copyright (c) 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Material

class SideViewController : UITableViewController {
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.redColor()
    }
    
    /// Select item at row in tableView.
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        LOG.debug("SIDEVIEW CONTROLLER ROW \(indexPath.row)")
        LOG.debug("SIDEVIEW CONTROLLER SECTION \(indexPath.section)")

//        var bottomNavigationController = getAppDelegate().bottomNavigationController


        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                //place group tablet
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainViewController = storyboard.instantiateViewControllerWithIdentifier("mainViewController") as! MainViewController
                let scratchPadViewController = storyboard.instantiateViewControllerWithIdentifier("scratchPadViewController") as! ScratchPadViewController

                let bottomNavigationController: BottomNavigationController = BottomNavigationController()

                bottomNavigationController.viewControllers = [mainViewController, scratchPadViewController]
                bottomNavigationController.selectedIndex = 1
                bottomNavigationController.tabBar.tintColor = MaterialColor.red.base
                bottomNavigationController.tabBar.backgroundColor = MaterialColor.yellow.darken4

//                getAppDelegate().bottomNavigationController.setViewControllers([mainViewController,scratchPadViewController], animated: true)
                //remove scan button
                mainViewController.hasScanButton = false
                mainViewController.hasTabbar = true

                //sideNavigationController?.closeLeftView()
                sideNavigationController?.transitionFromRootViewController(bottomNavigationController, duration: 0, options: .TransitionNone, animations: nil, completion: nil)
//                sideNavigationController?.transitionFromRootViewController(getAppDelegate().bottomNavigationController,
//                                                                           duration: 1,
//                                                                           options: .TransitionNone,
//                                                                           animations: nil,
//                                                                           completion: { [weak self] _ in
//                                                                            self?.sideNavigationController?.closeLeftView()
//                    })
            case 1:
                //place terminal
                let mainViewController = storyboard!.instantiateViewControllerWithIdentifier("mainViewController") as! MainViewController
                
                //remove scan button
                mainViewController.hasScanButton = false
                mainViewController.hasTabbar = false

                
                
                sideNavigationController?.transitionFromRootViewController(mainViewController,
                                                                           duration: 1,
                                                                           options: .TransitionNone,
                                                                           animations: nil,
                                                                           completion: { [weak self] _ in
                                                                            self?.sideNavigationController?.closeLeftView()})
            default:
                break
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                //object group tablet

                let mainViewController = storyboard!.instantiateViewControllerWithIdentifier("mainViewController") as! MainViewController
                let scratchPadViewController = storyboard!.instantiateViewControllerWithIdentifier("scratchPadViewController") as! ScratchPadViewController




                mainViewController.hasScanButton = true
                mainViewController.hasTabbar = true

                let bottomNavigationController: BottomNavigationController = BottomNavigationController()

                bottomNavigationController.viewControllers = [mainViewController, scratchPadViewController]
                bottomNavigationController.selectedIndex = 0
                bottomNavigationController.tabBar.tintColor = MaterialColor.red.base
                bottomNavigationController.tabBar.backgroundColor = MaterialColor.grey.darken4


                sideNavigationController?.transitionFromRootViewController(bottomNavigationController,
                        duration: 0,
                        options: .TransitionNone,
                        animations: nil,
                        completion: { [weak self] _ in
                            self?.sideNavigationController?.closeLeftView()
                        })
            default:
                break
            }
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                //control panel
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controlPanelViewController = storyboard.instantiateViewControllerWithIdentifier("controlPanelViewController") as! ControlPanelViewController
                sideNavigationController?.transitionFromRootViewController(controlPanelViewController,
                        duration: 1,
                        options: .TransitionNone,
                        animations: nil,
                        completion: { [weak self] _ in
                            self?.sideNavigationController?.closeLeftView()
                        })
            case 1:
                //debug
                let controlPanelViewController = storyboard!.instantiateViewControllerWithIdentifier("controlPanelViewController") as! ControlPanelViewController
                sideNavigationController?.transitionFromRootViewController(controlPanelViewController,
                        duration: 1,
                        options: .TransitionNone,
                        animations: nil,
                        completion: { [weak self] _ in
                            self?.sideNavigationController?.closeLeftView()
                        })
            default:
                break
            }
        }
        
        
    }

}

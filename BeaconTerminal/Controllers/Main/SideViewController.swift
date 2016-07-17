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
        self.view.backgroundColor = UIColor.whiteColor()
    }

    // MARK: table
    
    /// Select item at row in tableView.
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {


        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                
                getAppDelegate().changeSystemStateTo(ApplicationState.PLACE_GROUP)
                
                //place group tablet
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainViewController = storyboard.instantiateViewControllerWithIdentifier("mainViewController") as! MainViewController
                //mainViewController.changeApplicationState(ApplicationState.PLACE_GROUP)


                let scratchPadViewController = storyboard.instantiateViewControllerWithIdentifier("scratchPadViewController") as! ScratchPadViewController

                let bottomNavigationController: AppBottomNavigationController = AppBottomNavigationController()

                bottomNavigationController.viewControllers = [mainViewController, scratchPadViewController]
                bottomNavigationController.selectedIndex = 0
                bottomNavigationController.tabBar.tintColor = UIColor.whiteColor()
                bottomNavigationController.tabBar.backgroundColor = UIColor.blackColor()

                //create top navigationbar
                let navigationController: AppNavigationController = AppNavigationController(rootViewController: bottomNavigationController)

                navigationDrawerController?.transitionFromRootViewController(navigationController,
                        duration: 0,
                        options: .TransitionNone,
                        animations: nil,
                        completion: {
                            [weak self] _ in
                            bottomNavigationController.changeGroupAndSectionTitles((realmDataController?.currentGroup?.groupTitle)!, newSectionTitle: (realmDataController?.currentSection)!)

                            self?.navigationDrawerController?.closeLeftView()
                        })
            case 1:
                //place terminal


                getAppDelegate().changeSystemStateTo(ApplicationState.PLACE_TERMINAL)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainViewController = storyboard.instantiateViewControllerWithIdentifier("mainViewController") as! MainViewController

                let navigationController: AppNavigationController = AppNavigationController(rootViewController: mainViewController)

                navigationDrawerController!.transitionFromRootViewController(navigationController,
                        duration: 0,
                        options: .TransitionNone,
                        animations: nil,
                        completion: {
                            [weak self] _ in
                            self?.navigationDrawerController?.closeLeftView()
                        })


            default:
                break
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                
                getAppDelegate().changeSystemStateTo(ApplicationState.OBJECT_GROUP)
                
                //object group tablet
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainViewController = storyboard.instantiateViewControllerWithIdentifier("mainViewController") as! MainViewController
       

                let scratchPadViewController = storyboard.instantiateViewControllerWithIdentifier("scratchPadViewController") as! ScratchPadViewController

                let bottomNavigationController: AppBottomNavigationController = AppBottomNavigationController()

                bottomNavigationController.viewControllers = [mainViewController, scratchPadViewController]
                bottomNavigationController.tabBar.tintColor = UIColor.whiteColor()
                bottomNavigationController.tabBar.backgroundColor = UIColor.blackColor()


                //create top navigationbar
                let navigationController: AppNavigationController = AppNavigationController(rootViewController: bottomNavigationController)
                
                navigationDrawerController?.transitionFromRootViewController(navigationController,
                                                                             duration: 0,
                                                                             options: .TransitionNone,
                                                                             animations: nil,
                                                                             completion: {
                                                                                [weak self] _ in
                                                                                bottomNavigationController.changeGroupAndSectionTitles((realmDataController?.currentGroup?.groupTitle)!, newSectionTitle: (realmDataController?.currentSection)!)
                                                                                
                                                                                self?.navigationDrawerController?.closeLeftView()
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
                
                //create top navigationbar
                let navigationController: AppNavigationController = AppNavigationController(rootViewController: controlPanelViewController)

                
                navigationDrawerController?.transitionFromRootViewController(navigationController,
                        duration: 0,
                        options: .TransitionNone,
                        animations: nil,
                        completion: {
                            [weak self] _ in
                            self?.navigationDrawerController?.closeLeftView()
                        })
            case 1:
                
                //debug
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controlPanelViewController = storyboard.instantiateViewControllerWithIdentifier("controlPanelViewController") as! ControlPanelViewController
                
                //create top navigationbar
                let navigationController: AppNavigationController = AppNavigationController(rootViewController: controlPanelViewController)
                
                navigationDrawerController?.transitionFromRootViewController(navigationController,
                        duration: 0,
                        options: .TransitionNone,
                        animations: nil,
                        completion: {
                            [weak self] _ in
                            self?.navigationDrawerController?.closeLeftView()
                        })
            default:
                break
            }
        }


    }

}

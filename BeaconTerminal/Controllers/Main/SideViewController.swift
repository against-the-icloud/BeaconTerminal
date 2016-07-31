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
        self.view.backgroundColor = UIColor.white()
    }

    // MARK: table
    
    /// Select item at row in tableView.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {


        if (indexPath as NSIndexPath).section == 0 {
            switch (indexPath as NSIndexPath).row {
            case 0:
                
                getAppDelegate().changeSystemStateTo(ApplicationState.placeGroup)
                
                //place group tablet
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainViewController = storyboard.instantiateViewController(withIdentifier: "mainViewController") as! MainViewController
                //mainViewController.changeApplicationState(ApplicationState.PLACE_GROUP)


                let scratchPadViewController = storyboard.instantiateViewController(withIdentifier: "scratchPadViewController") as! ScratchPadViewController

                let bottomNavigationController: AppBottomNavigationController = AppBottomNavigationController()

                bottomNavigationController.viewControllers = [mainViewController, scratchPadViewController]
                bottomNavigationController.selectedIndex = 0
                bottomNavigationController.tabBar.tintColor = UIColor.white()
                bottomNavigationController.tabBar.backgroundColor = UIColor.black()

                //create top navigationbar
                let navigationController: AppNavigationController = AppNavigationController(rootViewController: bottomNavigationController)

                navigationDrawerController?.transitionFromRootViewController(toViewController: navigationController,
                        duration: 0,
                        options: [],
                        animations: nil,
                        completion: {
                            [weak self] _ in
                            bottomNavigationController.changeGroupAndSectionTitles((realmDataController?.currentGroup?.groupTitle)!, newSectionTitle: (realmDataController?.currentSection)!)

                            self?.navigationDrawerController?.closeLeftView()
                        })
            case 1:
                //place terminal


                getAppDelegate().changeSystemStateTo(ApplicationState.placeTerminal)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainViewController = storyboard.instantiateViewController(withIdentifier: "mainViewController") as! MainViewController

                let navigationController: AppNavigationController = AppNavigationController(rootViewController: mainViewController)

                
            
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
                
                getAppDelegate().changeSystemStateTo(ApplicationState.objectGroup)
                
                //object group tablet
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainViewController = storyboard.instantiateViewController(withIdentifier: "mainViewController") as! MainViewController
       

                let scratchPadViewController = storyboard.instantiateViewController(withIdentifier: "scratchPadViewController") as! ScratchPadViewController

                let bottomNavigationController: AppBottomNavigationController = AppBottomNavigationController()

                bottomNavigationController.viewControllers = [mainViewController, scratchPadViewController]
                bottomNavigationController.tabBar.tintColor = UIColor.white()
                bottomNavigationController.tabBar.backgroundColor = UIColor.black()


                //create top navigationbar
                let navigationController: AppNavigationController = AppNavigationController(rootViewController: bottomNavigationController)
                
                navigationDrawerController?.transitionFromRootViewController(toViewController: navigationController,
                                                                             duration: 0,
                                                                             options: [],
                                                                             animations: nil,
                                                                             completion: {
                                                                                [weak self] _ in
                                                                                bottomNavigationController.changeGroupAndSectionTitles((realmDataController?.currentGroup?.groupTitle)!, newSectionTitle: (realmDataController?.currentSection)!)
                                                                                
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
        }


    }

}

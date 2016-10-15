//
//  DefaultViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 9/16/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView


class DefaultViewController: UIViewController, NVActivityIndicatorViewable {
    
    var shouldShowLogin: Bool = true
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {            
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if shouldShowLogin {
            showLogin()
        }
    }
    
    func showLogin() {
        let storyboard = UIStoryboard(name: "Popover", bundle: nil)
        let loginNavigationController = storyboard.instantiateViewController(withIdentifier: "loginNavigationController") as! UINavigationController
        
        self.present(loginNavigationController, animated: true, completion: {})
    }
    
    func showGroupLogin() {
        let storyboard = UIStoryboard(name: "Popover", bundle: nil)
        let loginGroupViewController = storyboard.instantiateViewController(withIdentifier: "loginGroupNavigationController") as! UINavigationController
        
        if let loginGroupViewController = loginGroupViewController.viewControllers[0] as? LoginGroupViewController {
            loginGroupViewController.cancelButton.isEnabled = false
        }
        
        self.present(loginGroupViewController, animated: true, completion: {})
    }
    
}

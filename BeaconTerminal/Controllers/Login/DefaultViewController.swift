//
//  DefaultViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 9/16/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit

class DefaultViewController: UIViewController {
    
    
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
    }
    
    func showLogin() {
        let storyboard = UIStoryboard(name: "Popover", bundle: nil)
        let loginNavigationController = storyboard.instantiateViewController(withIdentifier: "loginNavigationController") as! UINavigationController
        
        self.present(loginNavigationController, animated: true, completion: {})
    }
}

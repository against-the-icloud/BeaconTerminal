//
//  ControlPanelViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 5/22/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Material

protocol ControlPanelDelegate: class {
    func resetDidFinish(withRecordCount recordCount:Int)
}

class ControlPanelViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    @IBOutlet weak var dbResetStatusLabel: UILabel!
    @IBOutlet weak var dbResetButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        getAppDelegate().controlPanelDelegate = self
    }
    
    @IBAction func dbResetAction(_ sender: AnyObject) {
        
        getAppDelegate().resetDB()
    }
    
    
    @IBAction func doneAction(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)   
    }
    
    @IBAction func onBurger() {
        navigationDrawerController?.openLeftView()
    }
}

extension ControlPanelViewController: ControlPanelDelegate {
    func resetDidFinish(withRecordCount recordCount:Int) {
        dbResetStatusLabel.text = "\(recordCount) records"
    }
}


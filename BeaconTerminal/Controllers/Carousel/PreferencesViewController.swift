//
//  PreferencesViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 7/29/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit

class PreferencesViewController: UIViewController {
    
    var speciesObservation: SpeciesObservation?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    @IBAction func doneAction(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
    
    func prepareView() {
        
        if let so = speciesObservation {
            if let speciesName = so.fromSpecies?.name {
                self.title = "\(speciesName) Preferences"
            } else {
                self.title = "Species Preferences"
            }
        }
        
    }
}
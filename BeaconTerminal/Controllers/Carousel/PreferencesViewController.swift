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
    
    @IBOutlet weak var okButton: UIBarButtonItem!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if let preferencesTableViewController = segue.destination as? PreferencesTableViewController {
            preferencesTableViewController.speciesObservation = speciesObservation
        }
    }
    
    
    func prepareView() {
        if let so = speciesObservation {
            if let speciesName = so.fromSpecies?.name {
                self.title = "\(speciesName) Ecosystem Preferences"
            } else {
                self.title = "Species Preferences"
            }
        }
        
    }
    
    func updateTint(_ tint: UIColor) {
        okButton.tintColor = tint
    }

    // Mark: IBAction
    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

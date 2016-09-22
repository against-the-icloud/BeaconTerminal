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
    
    var speciesIndex: Int?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            switch id {
            case "preferencesSegue":
                if let pvc = segue.destination as? PreferencesTableViewController, let fromSpecies = self.speciesIndex {
                    pvc.speciesIndex = fromSpecies
                }
            default:
                break
            }
        }
    }
    
    
}

//
//  TerminalPreferenceComparsionController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 10/4/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class TerminalPreferenceComparsionController: UIViewController {
    
    var speciesIndex: Int? 
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // Mark: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier {
            let id = NSNumber.init( value: Int32(segueId)!).intValue
            
            switch id {
            case 0,1,2,3,4:
                if let pvc = segue.destination as? TerminalPreferenceComparsionDetailController, let fromSpecies = self.speciesIndex{
                    pvc.speciesIndex = fromSpecies
                    pvc.groupIndex = id
                }
                break
            default:
                break
            }
        }
    }

    
    
}

//
//  TerminalViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/18/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class SpeciesRelationshipContainerController: UIViewController {
    
    var speciesIndex: Int?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Mark: segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tvc = segue.destination as? SpeciesRelationshipTableController, let segueId = segue.identifier {
            switch segueId {
            case "producerRelationshipSegue":
                tvc.relationshipType = .producer
                tvc.speciesIndex = speciesIndex
                break
            case "competesRelationshipSegue":
                tvc.relationshipType = .competes
                tvc.speciesIndex = speciesIndex
                break
            case "consumerRelationshipSegue":
                tvc.relationshipType = .consumer
                tvc.speciesIndex = speciesIndex
                break
            default:
                break
            }
        }
    }
}

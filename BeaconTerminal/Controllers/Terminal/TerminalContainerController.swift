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
import Photos
import MobileCoreServices
import Nutella


class TerminalContainerViewController: UIViewController {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Mark: segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tvc = segue.destination as? TerminalRelationshipTableViewController, let segueId = segue.identifier {
            switch segueId {
            case "terminalProducerRelationship":
                tvc.relationshipType = .producer
                break
            case "terminalCompetesRelationship":
                tvc.relationshipType = .competes
                break
            case "terminalConsumerRelationship":
                tvc.relationshipType = .consumer
                break
            case "terminalSpeciesPreferencesRelationship":
                tvc.relationshipType = .sPreference
                break
            default:
                break
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

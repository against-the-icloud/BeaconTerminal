//
//  TerminalComparsionController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/23/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class TerminalComparsionController: UIViewController {
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var foundRelationships = [Int:Relationship]()
    var groups:List<Group>?
    
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
    
            
            if let relationship = foundRelationships[id], let detailvc = segue.destination as? TerminalRelationshipDetailTableViewController, let group = groups?.filter(using: "index = \(id)") {
                
                
                detailvc.group = group.first
                detailvc.relationship = relationship
            }
        }
    }
    
    
    @IBAction func doneAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func shareButton(_ sender: AnyObject) {
    }
    
}

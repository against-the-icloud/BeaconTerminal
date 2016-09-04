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

    var cellItems: [CellItem]?
    var species: Species?
    var fromSpecies: Species?
    var groups: List<Group>?
    var relationshipType: RelationshipType?
    
    @IBOutlet weak var fromSpeciesImageView: UIImageView!    
    @IBOutlet weak var relationshipLabel: UILabel!
    @IBOutlet weak var toSpeciesImageView: UIImageView!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // Mark: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
    
    
    func prepareView() {
        if let toSpecies = species, let fromSpecies = self.fromSpecies, let relationshipType = self.relationshipType {
            
            fromSpeciesImageView.image = RealmDataController.generateImageForSpecies(fromSpecies.index, isHighlighted: true)
            toSpeciesImageView.image = RealmDataController.generateImageForSpecies(toSpecies.index, isHighlighted: true)
            
            relationshipLabel.text = StringUtil.relationshipString(withType: relationshipType)
            
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        prepareView()
        
        if let segueId = segue.identifier {
            
             let id = NSNumber.init( value: Int32(segueId)!).intValue
    
            
            if let detailvc = segue.destination as? TerminalRelationshipDetailTableViewController, let cellItems = self.cellItems {
                
                if let found = cellItems.filter( { (cellItem: CellItem) -> Bool in
                    return cellItem.groupIndex == id
                }).first {
                  detailvc.cellItem = found
                  detailvc.groupIndex = found.groupIndex
                } else {
                  detailvc.groupIndex = id
                }
            }
        }
    }
    
    
    @IBAction func doneAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func shareButton(_ sender: AnyObject) {
    }
    
}

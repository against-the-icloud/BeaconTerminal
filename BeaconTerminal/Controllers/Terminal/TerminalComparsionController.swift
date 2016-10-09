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
    var fromSpeciesIndex: Int?
    var toSpeciesIndex: Int?
    var relationshipType: String?
    
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
        
        guard let relationshipType = self.relationshipType else {
            return
        }
        
        guard let toSpeciesIndex = self.toSpeciesIndex else {
            return
        }
        
        guard let fromSpeciesIndex = realmDataController.getRealm(withRealmType: RealmType.terminalDB).runtimeSpeciesIndex() else {
            return
        }
        
        
        
        fromSpeciesImageView.image = RealmDataController.generateImageForSpecies(fromSpeciesIndex, isHighlighted: true)
        toSpeciesImageView.image = RealmDataController.generateImageForSpecies(toSpeciesIndex, isHighlighted: true)
        
        relationshipLabel.text = StringUtil.relationshipString(withString: relationshipType)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        prepareView()
        
        if let segueId = segue.identifier {
            let id = NSNumber.init( value: Int32(segueId)!).intValue

            switch id {
            case 0,1,2,3,4,5:
                if let detailvc = segue.destination as? TerminalComparsionDetailViewController, let cellItems = self.cellItems {
                
                        detailvc.cellItem = cellItems[id]
                    
              
                }

            default:
              break
            }
            
        }
    }
    
    
    @IBAction func doneAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func shareButton(_ sender: AnyObject) {
    }
    
}

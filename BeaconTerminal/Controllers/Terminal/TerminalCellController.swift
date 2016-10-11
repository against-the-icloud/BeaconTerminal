//
//  TerminalCellController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/26/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

struct CellItem {
    var groupIndex: Int?
    var relationship: Relationship?
    var speciesPreference: SpeciesPreference?
    var attachments: String?
    var note: String?
    var enabled = false
    
    init() {
        
    }
    init(withGroupIndex groupIndex: Int) {
        self.groupIndex = groupIndex
    }
}

class TerminalCellController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet var countLabel: UILabel!
    
    var relationshipType: String?
    
    var toSpeciesIndex: Int? {
        didSet {
            prepareView()
        }
    }
    
    var toHabitatIndex: Int? {
        didSet {
            prepareSpeciesPreferencesView()
        }
    }
    
    var cellItems = [CellItem(withGroupIndex: 0),CellItem(withGroupIndex: 1),CellItem(withGroupIndex: 2),CellItem(withGroupIndex: 3),CellItem(withGroupIndex: 4)]
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
    
    func prepareSpeciesPreferencesView() {
        
        self.relationshipType = RelationshipType.sPreference.rawValue
        
        guard let toHabitatIndex = self.toHabitatIndex else {
            return
        }
        
        if let habitat = realmDataController.getRealm(withRealmType: RealmType.terminalDB).habitat(withIndex: toHabitatIndex) {
            let name = habitat.name
            if let image = UIImage(named: name) {
                profileImageView.image = image
                profileImageView.tintColor = UIColor.gray
            }
        }
   
        cellItems = [CellItem(withGroupIndex: 0),CellItem(withGroupIndex: 1),CellItem(withGroupIndex: 2),CellItem(withGroupIndex: 3),CellItem(withGroupIndex: 4)]
        
        countLabel.text = ""
    
        self.view.setNeedsLayout()
        self.view.fadeIn(toAlpha: 0.3) {_ in
            
        }
    }
    
    func prepareView() {
        guard let toSpeciesIndex = self.toSpeciesIndex else {
            return
        }
        
        let disabledImage = RealmDataController.generateImageForSpecies(toSpeciesIndex, isHighlighted: false)
        
        profileImageView.image = disabledImage
        
        cellItems = [CellItem(withGroupIndex: 0),CellItem(withGroupIndex: 1),CellItem(withGroupIndex: 2),CellItem(withGroupIndex: 3),CellItem(withGroupIndex: 4)]
        
        countLabel.text = ""
        countLabel.isHidden = true
        
        self.view.setNeedsLayout()
        
        self.view.fadeIn(toAlpha: 0.3) {_ in
   
        }
        
        /**
        self.view.fadeIn(toAlpha: 0.3) {_ in
            for (index,tap) in self.tapCollection.enumerated() {
                self.imageViewCells[index].isUserInteractionEnabled = false
                tap.isEnabled = false
            }
        }
 **/
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
        switch id {
        case "comparsionSegue":
            if let uinc = segue.destination as? UINavigationController, let tcvc = uinc.viewControllers.first as? TerminalComparsionController, let relationshipType = self.relationshipType{
                tcvc.cellItems = cellItems
                tcvc.toSpeciesIndex = toSpeciesIndex
                tcvc.toHabitatIndex = toHabitatIndex
                tcvc.relationshipType = relationshipType
                //tcvc.relationship = relationship
                //tcvc.title = title
                tcvc.navigationController?.navigationBar.tintColor = Util.flatBlack
                tcvc.navigationItem.backBarButtonItem?.tintColor = UIColor.white
                tcvc.doneButton.tintColor = UIColor.white
                tcvc.navigationController?.toolbar.tintColor =  Util.flatBlack
            }
            break
        default:
            print("you know nothing jon snow")
        }
        }
    }
    
    func showComparsionView() {
        
        for cell in cellItems {
            if cell.enabled {
                self.performSegue(withIdentifier: "comparsionSegue", sender: self)
                return
            }
        }
        
    }
    
    func updateCell(withGroupIndex groupIndex: Int, andSpeciesPreference speciesPreference: SpeciesPreference) {
        
        guard let toHabitatIndex = self.toHabitatIndex else {
            return
        }
        
        if let habitat = realmDataController.getRealm(withRealmType: RealmType.terminalDB).habitat(withIndex: toHabitatIndex) {
            let name = habitat.name
            if let image = UIImage(named: name) {
                profileImageView.image = image
                profileImageView.tintColor = UIColor.clear
                profileImageView.backgroundColor = UIColor.clear
            }
        }
        
        cellItems[groupIndex].groupIndex = groupIndex
        cellItems[groupIndex].speciesPreference = speciesPreference
        cellItems[groupIndex].attachments = speciesPreference.attachments
        cellItems[groupIndex].note = speciesPreference.note
        cellItems[groupIndex].enabled = true
        
        doCounts(withType: "preference")
    }
    
    func updateCell(withGroupIndex groupIndex: Int, andRelationship relationship: Relationship) {
        
        guard let toSpeciesIndex = self.toSpeciesIndex else {
            return
        }
        
        let enabledImage = RealmDataController.generateImageForSpecies(toSpeciesIndex, isHighlighted: true)
        
        profileImageView.image = enabledImage
        
     
        cellItems[groupIndex].groupIndex = groupIndex
        cellItems[groupIndex].relationship = relationship
        cellItems[groupIndex].attachments = relationship.attachments
        cellItems[groupIndex].note = relationship.note
        cellItems[groupIndex].enabled = true

        doCounts(withType: "relationship")
    }
    
    func doCounts(withType type: String) {
        
        var count = 0
        
        switch type {
        case "preference":
            for cell in cellItems {
                if cell.speciesPreference != nil {
                    count += 1
                }
            }
        default:
            for cell in cellItems {
                if cell.relationship != nil {
                    count += 1
                }
            }
        }
       
        
        countLabel.text = "\(count)"
        countLabel.isHidden = false
        
        if self.view.alpha < 1.0 {
            self.view.fadeIn(toAlpha: 1.0)
        }
    }
    
    
}

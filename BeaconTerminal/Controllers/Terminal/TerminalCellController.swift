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
    
    func updateCell(withGroupIndex groupIndex: Int, andRelationship relationship: Relationship) {
        
        guard let toSpeciesIndex = self.toSpeciesIndex else {
            return
        }
        
        let enabledImage = RealmDataController.generateImageForSpecies(toSpeciesIndex, isHighlighted: true)
        
        profileImageView.image = enabledImage
        
     
        cellItems[groupIndex].groupIndex = groupIndex
        cellItems[groupIndex].relationship = relationship
        
        var count = 0
        
        for cell in cellItems {
            if cell.relationship != nil {
                count += 1
            }
        }
        
        countLabel.text = "\(count)"
        
        if self.view.alpha < 1.0 {
            self.view.fadeIn(toAlpha: 1.0)
        }
    }
    
    
}

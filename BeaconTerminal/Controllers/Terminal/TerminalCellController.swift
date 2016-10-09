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
}

class TerminalCellController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet var imageViewCells: [UIImageView]!
    @IBOutlet var tapCollection: [UITapGestureRecognizer]!
    var relationshipType: String?
    
    var toSpeciesIndex: Int? {
        didSet {
            prepareView()
        }
    }
    var cellItems = [CellItem(),CellItem(),CellItem(),CellItem(),CellItem()]
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
    
    func prepareView() {
        guard let toSpeciesIndex = self.toSpeciesIndex else {
            return
        }
        
        let disabledImage = RealmDataController.generateImageForSpecies(toSpeciesIndex, isHighlighted: false)
        
        profileImageView.image = disabledImage
        
        cellItems = [CellItem(),CellItem(),CellItem(),CellItem(),CellItem()]
        
        for (index, _) in cellItems.enumerated() {
            imageViewCells[index].isUserInteractionEnabled = false
            imageViewCells[index].backgroundColor = UIColor.clear
            imageViewCells[index].image = nil
        }
    
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
        switch segue.identifier! {
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
    
    func updateCell(withGroupIndex groupIndex: Int, andRelationship relationship: Relationship) {
        
        guard let toSpeciesIndex = self.toSpeciesIndex else {
            return
        }
        
        for (index,_) in self.imageViewCells.enumerated() {
            self.imageViewCells[index].isUserInteractionEnabled = true
        }
        
        let enabledImage = RealmDataController.generateImageForSpecies(toSpeciesIndex, isHighlighted: true)
        
        profileImageView.image = enabledImage
        
     
        cellItems[groupIndex].groupIndex = groupIndex
        cellItems[groupIndex].relationship = relationship
                        
        if let attachments = relationship.attachments {
            
            let urls = attachments.components(separatedBy: ",")
            
            if !urls.isEmpty {
                for attach in urls {
                    
                    if let url = URL(string: attach) {
                        UIImage.contentsOfURL(url: url, completion: { found, error in
                            if let image = found  {
                                self.imageViewCells[groupIndex].image = image
                            }
                        })
                    }
                }
            } else {
                imageViewCells[groupIndex].backgroundColor = #colorLiteral(red: 0.4824384836, green: 0.8372815179, blue: 0.9991987436, alpha: 1)
            }
         
            
        } else {
            imageViewCells[groupIndex].backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        }
        
        if self.view.alpha < 1.0 {
            self.view.fadeIn(toAlpha: 1.0)
        }
    }
    
    
}

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
    
    var toSpeciesIndex: Int? {
        didSet {
            prepareView()
        }
    }
    var cellItems = [CellItem]()
    var relationship: Relationship?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func prepareView() {
        guard let toSpeciesIndex = self.toSpeciesIndex else {
            return
        }
        
        let disabledImage = RealmDataController.generateImageForSpecies(toSpeciesIndex, isHighlighted: false)
        
        profileImageView.image = disabledImage
        self.view.fadeIn(toAlpha: 0.3) {_ in
            //            for tap in self.tapCollection {
            //                tap.isEnabled = false
            //            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "comparsionSegue":
            if let uinc = segue.destination as? UINavigationController, let tcvc = uinc.viewControllers.first as? TerminalComparsionController, let relationship = self.relationship {
                
                
                tcvc.cellItems = cellItems
                tcvc.relationship = relationship
                
                
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
        
        
        
        self.relationship = relationship
        //        for tap in tapCollection {
        //            tap.isEnabled = true
        //        }
        
        var cellItem = CellItem()
        cellItem.groupIndex = groupIndex
        cellItem.relationship = relationship
        cellItems.append(cellItem)
        
        let enabledImage = RealmDataController.generateImageForSpecies(toSpeciesIndex, isHighlighted: true)
        
        profileImageView.image = enabledImage
        
        if let attachments = relationship.attachments {
            
            let urls = attachments.components(separatedBy: ",")
            
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
            imageViewCells[groupIndex].backgroundColor = #colorLiteral(red: 0.8129653335, green: 0.8709804416, blue: 0.9280658364, alpha: 1)
        }
        
        if self.view.alpha < 1.0 {
            self.view.fadeIn(toAlpha: 1.0)
        }
    }
    
    
}

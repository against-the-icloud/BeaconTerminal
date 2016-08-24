//
//  TerminalRelationshipViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/19/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift


class TerminalRelationshipViewController: UIViewController {
    
    @IBOutlet weak var relationshipLabel: UILabel!
    @IBOutlet weak var relationshipStatusLabel: UILabel!
    
    @IBOutlet var speciesCell: [TerminalSpeciesCell]!
    
    var selectedSpeciesCell: TerminalSpeciesCell?
    
    var relationshipCount = 0

    var relationshipType: RelationshipType?
    var relationshipResults: [RelationshipResult] = [RelationshipResult]()
    
    // Mark: UIViewController methonds
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
    
    func prepareView() {
        //update title
        if let relationshipType = self.relationshipType {
            relationshipLabel.text = StringUtil.relationshipString(with: relationshipType)
        }
        
        //setup species TerminalSpeciesCell
        for (index,terminalCell) in speciesCell.enumerated() {
            terminalCell.speciesImage.image = RealmDataController.generateImageForSpecies(index, isHighlighted: false)
            terminalCell.speciesIndex = index
            terminalCell.allGroupStatusViewsOff()
            
            
             let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(showResultPopover(_:)))
            
            
            terminalCell.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    func updateUI() {
        for rr in relationshipResults {
            
            //go through all the relationships
            if let relationships = rr.relationships {
                
                relationshipCount += (rr.relationships?.count)!

                for r in relationships {
                    if let index = r.toSpecies?.index {
                        let terminalCell = speciesCell.filter({ (sc:TerminalSpeciesCell) -> Bool in
                            return sc.speciesIndex == index
                        }).first
                        
                        terminalCell?.groupStatusView(highlighted: true, for:  (rr.group?.index)!)
                    }
                }
            }
        }
                            
        relationshipStatusLabel.text = "Reporting \(relationshipCount) relationships from 5 of 5 groups"
    }
    
    // Mark: Gestures
    
    func showResultPopover(_ sender: UITapGestureRecognizer) {
        if sender.view is TerminalSpeciesCell {
            let tcell = sender.view as? TerminalSpeciesCell
            self.selectedSpeciesCell = tcell
            
            performSegue(withIdentifier: "resultsSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "resultsSegue"?:
            
                if let terminalRelationshipController = segue.source as? TerminalRelationshipViewController, let fromSpecies = self.relationshipResults.first?.speciesObservation?.fromSpecies {
                    
                    let selectedSpeciesCell = terminalRelationshipController.selectedSpeciesCell

                    if let uinc = segue.destination as? UINavigationController, let tcvc = uinc.viewControllers.first as? TerminalComparsionController, let toSpecies = realmDataController?.findSpecies((selectedSpeciesCell?.speciesIndex!)!), let relationshipType = self.relationshipType
                    {
                        
                        
                        
                        let title = "Comparison of \(fromSpecies.name) \(StringUtil.relationshipString(with: relationshipType)) \(toSpecies.name)"
                        
                        tcvc.title = title
                        tcvc.navigationController?.navigationBar.tintColor = Util.flatBlack
                        tcvc.navigationItem.backBarButtonItem?.tintColor = UIColor.white
                        tcvc.doneButton.tintColor = UIColor.white
                        tcvc.navigationController?.toolbar.tintColor =  Util.flatBlack
                    }
                    
                    
                }
        
           
            break
        default:
            print("you know nothing")
        }
    }
}


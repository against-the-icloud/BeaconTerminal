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
    var groups: List<Group>?
    
    var relationshipCount = 0
    
    var relationshipType: RelationshipType?
    var relationshipResults: [RelationshipResult]? {
        didSet {
            updateUI()
        }
    }
    
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
//        for (index,terminalCell) in speciesCell.enumerated() {
//            terminalCell.speciesImage.image = RealmDataController.generateImageForSpecies(index, isHighlighted: false)
//            terminalCell.speciesIndex = index
//            terminalCell.allGroupStatusViewsOff()
//            
//            
//            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(showResultPopover(_:)))
//            
//            
//            terminalCell.addGestureRecognizer(tapGestureRecognizer)
//        }
    }
    
    func updateUI() {
        
        
        
        if let relationshipResults =  self.relationshipResults {
            let countedSet = NSCountedSet()
            if !relationshipResults.isEmpty {
                
                for rr in relationshipResults {
                    
                    
                    //go through all the relationships
                    
                    
                    if let relationships = rr.relationships, let group = rr.group {
                        
                        let groupIndex = group.index
                        
                        countedSet.add(groupIndex)
                        
                        relationshipCount += (rr.relationships?.count)!
                        
                        
                        //for each cell see if there is a species
//                        for cell in speciesCell {
//                            
//                            let cellSpeciesIndex = cell.speciesIndex
//                            
//                            let foundRelationships = relationships.filter(using: "toSpecies.index = \(cellSpeciesIndex!)")
//                            
//                                if !foundRelationships.isEmpty {
//                                    
//                                    LOG.debug("GROUP INDEX \(groupIndex) RELATIONSHIP type \(rr.relationshipType) number\(rr.relationships!.count) for SPECIES \(foundRelationships.first?.toSpecies?.name)")
//                                    
//                                    cell.groupStatusView(highlighted: true, for: groupIndex)
//                                } else {
//                                    cell.groupStatusView(highlighted: false, for: groupIndex)
//                                }
//                            
//                            
//                            
//                            
//                        }
                        
                        
                    }
                }
                
                
                //updateLabel(withRelationshipCount: relationshipCount, groupCount: 0, groupMax: (groups?.count)!)
                
            } else {
                updateLabel(withRelationshipCount: relationshipCount, groupCount: 0, groupMax: (groups?.count)!)
                
                for (_,terminalCell) in speciesCell.enumerated() {
                    
                    terminalCell.allGroupStatusViewsOff()
                }
                
            }
        }
    }
    
    func updateLabel(withRelationshipCount relationshipCount: Int = 0, groupCount: Int = 0, groupMax: Int = 0 ) {
        if relationshipCount == 0 && groupCount == 0 && groupMax == 0 {
            relationshipStatusLabel.text = "Nothing to report"
        }
        relationshipStatusLabel.text = "Reporting \(relationshipCount) relationships from \(groupCount) of \(groupMax) groups"
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
            
            if let terminalRelationshipController = segue.source as? TerminalRelationshipViewController, let fromSpecies = self.relationshipResults?.first?.speciesObservation?.fromSpecies {
                
                let selectedSpeciesCell = terminalRelationshipController.selectedSpeciesCell
                
                if let uinc = segue.destination as? UINavigationController, let tcvc = uinc.viewControllers.first as? TerminalComparsionController, let toSpecies = realmDataController?.findSpecies((selectedSpeciesCell?.speciesIndex!)!), let relationshipType = self.relationshipType
                {
                    
                    //find all the relationships that have
                    
                    let foundRelationships = findRelationships(withSpecies: toSpecies)
                    
                    let title = "\(fromSpecies.name) \(StringUtil.relationshipString(with: relationshipType)) \(toSpecies.name)"
                    tcvc.foundRelationships = foundRelationships
                    tcvc.groups = groups
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
    
    
    func findRelationships(withSpecies species: Species) -> [Int:Relationship] {
        
        var foundRelationships = [Int:Relationship]()
        
        if let relationshipResults = self.relationshipResults {
            
            for rr in relationshipResults {
                
                //go through all the relationships
                if let relationships = rr.relationships {
                    
                    for r in relationships {
                        if let index = r.toSpecies?.index {
                            if index ==  species.index, let groupId =  rr.group?.index {
                                foundRelationships[groupId] = r
                            }
                        }
                    }
                }
            }
            
        }
        
        return foundRelationships
    }
    
    
}


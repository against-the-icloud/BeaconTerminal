//
//  TerminalRelationshipTableViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/26/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class TerminalRelationshipTableViewController: UITableViewController {
    
    
    @IBOutlet weak var relationshipHeaderLabel: UILabel!
    @IBOutlet weak var relationshipReportLabel: UILabel!
    
    var reportingGroups:[Int:Int] = [Int:Int]()
    
    var species: Species? {
        didSet {
            updateHeader()
        }
    }
    var groups: List<Group>?
    
    var relationshipType: RelationshipType?
    var relationshipResults: [RelationshipResult]? {
        didSet {
            updateResults()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateHeader() {
        if let species = species {
            relationshipHeaderLabel.backgroundColor = UIColor.speciesColor(forIndex: species.index, isLight: false)
            relationshipHeaderLabel.borderColor = UIColor.speciesColor(forIndex: species.index, isLight: true)
            
            prepareView()
        }
        
    }
    
    
    func updateCell(withRelationship relationship: Relationship, group: Group, relationshipType: RelationshipType) {
        //find the controller with that species
        
        self.relationshipType = relationshipType
        
        if let cells = self.childViewControllers as? [TerminalCellController] {
            
            //find the controller
            let found = cells.filter( { (c: TerminalCellController) -> Bool in
                return c.species!.index == relationship.toSpecies!.index
            }).first
            
            if let cell = found {
                LOG.debug("FOUND \(found)")
                //update
                cell.updateCell(withGroup: group, andRelationship: relationship, relationshipType: self.relationshipType!)
                cell.fromSpecies = species 
                cell.groups = groups
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier {
            switch segueId {
            case "embedCell":
                
                if let cellController = segue.destination as? TerminalCellController {
                    cellController.relationshipType = relationshipType
                }
                                
                break
            default:
                break
            }
        }
    }
    
    func updateResults() {
        
        //go through all the groups
        
        var relationshipCount = 0
        
        if let groups = self.groups, let relationshipResults = self.relationshipResults {
            for group in groups {
                //find all the relationships for group with that species
                
                //let temp = []
                
                
                let groupResults = relationshipResults.filter( { (rr: RelationshipResult) -> Bool in
                    return rr.group?.index == group.index
                })
                
                reportingGroups[group.index] = 0
                
                
                //all the relationsip results for group
                for relResult in groupResults {
                    //cycle through all the relationships
                    
                    if let relationships = relResult.relationships {
                        
                        if relationships.count > 0 {
                            relationshipCount += relationships.count
                            reportingGroups[group.index] = 1
                            
                        }
                        
                        //LOG.debug("count for group \(group.index) \(groupResults.count) TYPE \(relationshipType?.rawValue) relationships \(relationships)")
                        
                        for r in relationships {
                            updateCell(withRelationship: r, group: group, relationshipType: relResult.relationshipType!)
                        }
                    }
                }
            }
            
            var groupCount = 0
            
            for (_, value) in reportingGroups {
                groupCount += value
            }
            
            updateLabel(withRelationshipCount: relationshipCount, groupCount: groupCount, groupMax: groups.count)
        } else {
            updateLabel(withRelationshipCount: 0, groupCount: 0, groupMax: 0)
        }
        
        
        
    }
    
    func updateLabel(withRelationshipCount relationshipCount: Int = 0, groupCount: Int = 0, groupMax: Int = 0 ) {
        if relationshipCount == 0 && groupCount == 0 && groupMax == 0 {
            relationshipReportLabel.text = "Nothing to report."
        }
        relationshipReportLabel.text = "Reporting \(relationshipCount) relationships from \(groupCount) of \(groupMax) groups"
    }
    
    func prepareView() {
        
        if let currentSpecies = species {
            //update title
            if let relationshipType = self.relationshipType {
                relationshipHeaderLabel.text = StringUtil.relationshipString(withType: relationshipType)
            }
            
            let allSpecies = realm!.allObjects(ofType: Species.self)
            
            var adder = 0
            for (index, cc) in self.childViewControllers.enumerated() {
                if let tcc = cc as? TerminalCellController {
                    
                    if index == currentSpecies.index {
                        adder = 1
                    } else {
                        adder = 0
                    }
                    
                    tcc.prepareView(withSpecies: allSpecies[index+adder])
                    
                }
            }
        }
    }
}

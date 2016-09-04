//
//  TerminalRelationshipDetailTableViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/6/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit

class TerminalRelationshipDetailTableViewController: UITableViewController {
    
    
    var cellItem: CellItem?
    var groupIndex: Int?
    
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var ecosystemSegmentedControl: UISegmentedControl!
    @IBOutlet weak var reasoningTextView: UITextView!
    @IBOutlet weak var evidenceImageView: UIImageView!
    
    var showAlternate = false {
        didSet {
            if showAlternate {
                let cells = tableView.visibleCells
                
                for cell in cells{
                    cell.contentView.backgroundColor = UIColor.white
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Mark: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func prepareView() {
        if let groupIndex = self.groupIndex {
            
            if let sectionName = realm?.runtimeSectionName() {
                if let group = realm?.group(withSectionName: sectionName, withGroupIndex: groupIndex) {
                    groupNameLabel.text = group.name
                }
            }
        }
        
        if let cellItem = self.cellItem, let relationship = cellItem.relationship {
            if let ecosystemIndex = relationship.ecosystem?.index {
                ecosystemSegmentedControl.selectedSegmentIndex = ecosystemIndex
            }
            
            if let attachment = relationship.attachments {
                evidenceImageView.image = UIImage(named: attachment)
            }
            
            if let note = relationship.note {
                reasoningTextView.text = note
            } else {
                reasoningTextView.text = "no reason"
            }
        } else {
            ecosystemSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
            reasoningTextView.text = ""
            evidenceImageView.image = nil
            evidenceImageView.backgroundColor = UIColor.clear
        }
    }
}

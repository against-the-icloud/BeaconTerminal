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
    @IBOutlet var imageTapGesture: UITapGestureRecognizer!
    
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
            
            if let sectionName = realmDataController.getRealm(withRealmType: RealmType.terminalDB).runtimeSectionName() {
                if let group = realmDataController.getRealm(withRealmType: RealmType.terminalDB).group(withSectionName: sectionName, withGroupIndex: groupIndex) {
                    groupNameLabel.text = group.name
                }
            }
        }
        
        if let cellItem = self.cellItem, let relationship = cellItem.relationship {
            if let ecosystemIndex = relationship.ecosystem?.index {
                ecosystemSegmentedControl.selectedSegmentIndex = ecosystemIndex
            }
            
            if let attachments = relationship.attachments {
                
                    let urls = attachments.components(separatedBy: ",")
                    
                    if !urls.isEmpty {
                        if let url = URL(string: urls[0]) {
                            UIImage.contentsOfURL(url: url, completion: { found, error in
                                if let image = found  {
                                    self.evidenceImageView.image = image
                                }
                            })
                        }
                    }
                
                 imageTapGesture.isEnabled = true
            } else {
                 imageTapGesture.isEnabled = false
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
            imageTapGesture.isEnabled = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else {
            return
        }
        
        switch id {
        case "showEvidenceSegue":
            guard let attachment = cellItem?.relationship?.attachments else {
                return
            }
            
            if let uinavigationController = segue.destination as? UINavigationController, let evidenceController = uinavigationController.topViewController as? EvidenceViewController {
                evidenceController.evidenceImageName = attachment
            }
        default:
            break
        }
        
        
    }
}

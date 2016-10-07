//
//  TerminalRelationshipDetailTableViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/6/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit

class TerminalComparsionDetailViewController: UIViewController {
    
    
    var cellItem: CellItem?
    var groupIndex: Int?
    
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var ecosystemSegmentedControl: UISegmentedControl!
    @IBOutlet weak var reasoningTextView: UITextView!
    
    @IBOutlet var imageViews: [UIImageView]!
    

    
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
            /**
            if let ecosystemIndex = relationship.ecosystem?.index {
                ecosystemSegmentedControl.selectedSegmentIndex = ecosystemIndex
            }
             **/
            
            if let attachments = relationship.attachments {
                
                    let urls = attachments.components(separatedBy: ",")
                
                for (index, imageUrl) in urls.enumerated() {
                    let iv = imageViews[index]
                    iv.isUserInteractionEnabled = true
            
                    if !urls.isEmpty {
                        if let url = URL(string: imageUrl) {
                            UIImage.contentsOfURL(url: url, completion: { found, error in
                                if let image = found  {
                                    iv.image = image
                                    iv.isUserInteractionEnabled = true
                                }
                            })
                        }
                    }
            }
            if let note = relationship.note {
                reasoningTextView.text = note
            } else {
                reasoningTextView.text = "no answer"
            }
        } else {
          //  ecosystemSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
            reasoningTextView.text = ""
            for iv in imageViews {
                iv.image = nil
                iv.backgroundColor = UIColor.clear
                iv.isUserInteractionEnabled = false
            }
        }
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
        case "showImage":
            if let gesture = sender as? UITapGestureRecognizer, let iv = gesture.view as? UIImageView, let imc = segue.destination as? ImageViewController {
                
                imc.image = iv.image
                imc.canDelete = false
                
            }
            
        default:
            break
        }
        
        
    }
}

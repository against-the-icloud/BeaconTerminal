
//
//  SpeciesPageViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 9/9/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class TerminalInvestigationPageController: UIViewController {
    
    var relationship: Relationship?
    var experiment: Experiment?
    var experimentId: String?
    
    var attachments = [String]()
    var tags = [Int]()
    
    @IBOutlet var images: [UIImageView]!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var questionLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for im in images {
            let tag = Randoms.randomInt()
            im.tag = tag
        }
        prepareTitlePanel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareTitlePanel()
    }
    
    func prepareTitlePanel() {
        
        noteTextView.text = ""
        
        if let relationship = self.relationship, let experimentId = self.relationship?.experimentId {
            
            if let experiment = realmDataController.getRealm().experimentsWithId(withId: experimentId) {
                
                var noteText = ""
                
                if let question = experiment.question {
                    
                    questionLabel.text = question
                }
                
                if let manipulations = experiment.manipulations {
                    noteText.append("\nManipulation(s):\n\n\(manipulations)\n")
                }
                
                if let reasoning = experiment.reasoning {
                    noteText.append("\nReasoning:\n\n\(reasoning)\n")
                }
                
                if let results = experiment.results {
                    noteText.append("\nResults:\n\n\(results)\n")
                }
                
                if let conclusions = experiment.conclusions {
                    noteText.append("\nConclusions:\n\n\(conclusions)\n")
                }
                
                noteTextView.text = noteText
                
                
                if let attachments = experiment.attachments?.components(separatedBy: ",") {
                    self.attachments = attachments
                    
                    for (index, path) in self.attachments.enumerated() {
                        
                        if !path.contains("undefined") {                            
                            if let url = URL(string: path) {
                                self.images[index].hnk_setImageFromURL(url)
                                self.images[index].isUserInteractionEnabled = true
                                self.images[index].backgroundColor = UIColor.clear
                            }
                        }
                    }
                }
                
            }
        }
    }
    
    func reloadInvestigations() {
        prepareTitlePanel()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            switch id {
            case "imageSegue":
                if let ivc = segue.destination as? ImageViewController, let tap = sender as? UIGestureRecognizer {
                    if let iv = tap.view as? UIImageView, let image = iv.image {
                        let tag = iv.tag
                        if let index = tags.index(of: tag) {
                            ivc.imageUrl = self.attachments[index]
                        }
                        ivc.image = image
                        ivc.canDelete = false
                    }
                }
            default:
                break
            }
        }
    }
    
    
}

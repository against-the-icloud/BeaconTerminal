//
//  InvestigationsViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 11/6/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class InvestigationsViewController: UIViewController {
  

    @IBOutlet weak var questionButton: UIButton!

    @IBOutlet var images: [UIImageView]!
    @IBOutlet weak var noteTextView: UITextView!
    var selectedExperimentIndex = 0
    var experiment: Experiment?
    var experimentId: String?
    var relationship: Relationship?
    var attachments = [String]()
    var tags = [Int]()
    weak var evidencePhotoDelegate: EvidencePhotoDelegate?
    
    var experimentResults: Results<Experiment>?
    var experimentNotification: NotificationToken? = nil
    
    var notificationTokens = [NotificationToken]()
    
    deinit {
        experimentNotification?.stop()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noteTextView.text = ""

        for im in images {
            let tag = Randoms.randomInt()
            im.tag = tag
            self.tags.append(tag)
        }
        
        if let relationship = self.relationship, let id = self.relationship?.experimentId {
            
            self.prepareNotifications(withExperimentId: id)
            
//            let r = realmDataController.getRealm()
//            if let experiment = r.experimentsWithId(withId:id) {
//                update(withExperiment: experiment)
//            }
        }
        
    }
    
    func prepareNotifications(withExperimentId experimentId: String) {
        
        experimentNotification = realmDataController.getRealm().objects(Experiment.self).filter("id = '\(experimentId)'").addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
                    
                    guard let controller = self else { return }
                    switch changes {
                    case .initial(let experimentResults):
                        
                        if let exp = experimentResults.first {
                          controller.update(withExperiment: exp)
                        }
                        break
                    case .update(let experimentResults, let deletions, let insertions, let modifications):
                        
                        if let exp = experimentResults.first {
                            controller.update(withExperiment: exp)
                        }
                        break
                    case .error(let error):
                        // An error occurred while opening the Realm file on the background worker thread
                        fatalError("\(error)")
                        break
                    }
                }
                
        
        
    }
    
    func update(withExperiment experiment: Experiment) {
        self.experiment = experiment
        
        if let relationship = self.relationship, let e = self.experiment, let id = e.id {
            
            let r = realmDataController.getRealm()
            
            try! r.write {
                relationship.experimentId = id
                relationship.experiment = experiment

                r.add(relationship, update: true)
            }
            
        }
        
        if let experiment = self.experiment {
            
            if let question = experiment.question {                
                self.questionButton.setTitle(question, for: [])
            }
            
            
            if let attachments = experiment.attachments?.components(separatedBy: ",") {
                self.attachments = attachments
                
                for (index, path) in self.attachments.enumerated() {
                    
                    if let url = URL(string: path) {
                        self.images[index].hnk_setImageFromURL(url)
                        self.images[index].isUserInteractionEnabled = true
                        self.images[index].backgroundColor = UIColor.clear
                    }
                }
                
            }
            
            var noteText = ""
            
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
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            switch id {
            case "investigationSegue":
                if let uinc = segue.destination as? UINavigationController, let tcvc = uinc.viewControllers.first as? InvestigationViewTableViewController {
                
                    uinc.popoverPresentationController!.delegate = self
                    //controller.preferredContentSize = CGSize(width: 300, height: 300)
                    
                    uinc.popoverPresentationController?.sourceView = self.questionButton;
                    uinc.popoverPresentationController?.sourceRect = self.questionButton.bounds;
                }
                break
            case "imageSegue":
                if let ivc = segue.destination as? ImageViewController, let tap = sender as? UIGestureRecognizer{
                    if let iv = tap.view as? UIImageView, let image = iv.image {
                        let tag = iv.tag
                        if let index = self.tags.index(of: tag) {
                            ivc.imageUrl = self.attachments[index]
                        }
                        ivc.image = image
                        ivc.sourceType = .species
                    }
                }
            case "imageInvestigationsSegue":
                if let ivc = segue.destination as? ImageViewController, let tap = sender as? UIGestureRecognizer{
                    ivc.canDelete = false
                    if let iv = tap.view as? UIImageView, let image = iv.image {
                        let tag = iv.tag
                        if let index = self.tags.index(of: tag) {
                            ivc.imageUrl = self.attachments[index]
                        }
                        ivc.image = image
                        ivc.sourceType = .species
                    }
                }
            default:
                break
            }
        }
    }
    
    @IBAction func unwindToInvestigationsChooseExperiment(_ sender: UIStoryboardSegue) {
        
        if let itc = sender.source as? InvestigationViewTableViewController {            
            if let experiment = itc.experiment, let id = experiment.id {
                self.experimentId = id
                
                for im in images {
                    im.image = nil
                    im.backgroundColor = #colorLiteral(red: 0.8129653335, green: 0.8709804416, blue: 0.9280658364, alpha: 1)
                }
                
                self.prepareNotifications(withExperimentId: id)
                //self.update(withExperiment: experiment)
            }
        }
    }

    
    @IBAction func unwindToEvidenceDeleteSpecies(_ sender: UIStoryboardSegue) {
        
        if let imageController = sender.source as? ImageViewController {
            
            if let imageUrl = imageController.imageUrl {
                if let index = self.attachments.index(of: imageUrl) {
                    self.attachments.remove(at: index)
                    let tag = self.tags[index]
                    for iv in self.images {
                        if iv.tag == tag {
                            iv.image = nil
                            iv.backgroundColor = #colorLiteral(red: 0.8129653335, green: 0.8709804416, blue: 0.9280658364, alpha: 1)
                        }
                    }
                }
            }
        }
    }
    
}

extension InvestigationsViewController: UIPopoverPresentationControllerDelegate {
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        if let ivc = popoverPresentationController.presentedViewController as? InvestigationViewTableViewController, let experiment = ivc.experiment, let id = experiment.id {
            self.experiment = experiment
            self.experimentId = id
            self.selectedExperimentIndex = ivc.selectedExperimentIndex
            
            
            for im in images {
                im.image = nil
                im.backgroundColor = #colorLiteral(red: 0.8129653335, green: 0.8709804416, blue: 0.9280658364, alpha: 1)
            }
            
            self.prepareNotifications(withExperimentId: id)
            //self.update(withExperiment: experiment)
        }
    }
    
}

//
//  ExperimentViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 11/13/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Material
import RealmSwift
import Photos
import NVActivityIndicatorView
import Haneke

class ExperimentsViewController: UIViewController,  UINavigationControllerDelegate, NVActivityIndicatorViewable {
    
    @IBOutlet weak var conclusionsTextView: UITextView!
    @IBOutlet weak var resultsTextView: UITextView!
    @IBOutlet weak var manipulationsTextView: UITextView!
    @IBOutlet weak var questionButton: UIButton!
    @IBOutlet weak var reasoningTextView: UITextView!
    @IBOutlet var images: [UIImageView]!
    
    @IBOutlet weak var saveButton: Button!
    @IBOutlet weak var cameraButton: FabButton!
    @IBOutlet weak var photoLibButton: FabButton!
    var experiment: Experiment?
    var experimentId: String?
    var attachments = [String]()
    var tags = [Int]()
    
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
        
        conclusionsTextView.delegate = self
        resultsTextView.delegate = self
        manipulationsTextView.delegate = self
        reasoningTextView.delegate = self
        
        photoLibButton.image = Icon.cm.photoLibrary
        photoLibButton.tintColor = UIColor.white
        cameraButton.image = Icon.cm.photoCamera
        cameraButton.tintColor = UIColor.white
        
        for im in images {
            let tag = Randoms.randomInt()
            im.tag = tag
            self.tags.append(tag)
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
            case .update(let experimentResults, let _, let _, let _):
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
    
    func update(withExperiment experiment: Experiment?) {
        enableUI()
        if let exp = experiment {
            
            self.experiment = exp
            
            if let question = exp.question {
                questionButton.setTitle(question, for: [])
            }
            if let manipulations = exp.manipulations {
                manipulationsTextView.text = manipulations
            }
            if let reasoning = exp.reasoning {
                reasoningTextView.text = reasoning
            }
            if let results = exp.results {
                resultsTextView.text = results
            }
            if let conclusions = exp.conclusions {
                conclusionsTextView.text = conclusions
            }
            
            if let attachments = experiment?.attachments?.components(separatedBy: ",") {
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
    

    
    func enableUI() {
        
        conclusionsTextView.isEditable = true
        resultsTextView.isEditable = true
        manipulationsTextView.isEditable = true
        reasoningTextView.isEditable = true
        
        saveButton.isEnabled = true
        cameraButton.isEnabled = true
        photoLibButton.isEnabled = true
        
        
    }
    
    func enableView() {
        
        if let tag = tags.last, let index = tags.index(of: tag) {
            images[index].isUserInteractionEnabled = true
        }
        
    }
    
    func showImagePicker(withSourceType sourceType: UIImagePickerControllerSourceType) {
        switch sourceType {
        case .photoLibrary:
            let imagePickerController = UIImagePickerController()
            
            // Only allow photos to be picked, not taken.
            imagePickerController.sourceType = .photoLibrary
            
            imagePickerController.delegate = self
            
            imagePickerController.modalPresentationStyle = UIModalPresentationStyle.popover
            imagePickerController.popoverPresentationController?.sourceView = photoLibButton
            
            // Make sure ViewController is notified when the user picks an image.
            self.present(imagePickerController, animated: true, completion: nil)
        default:
            //camera
            let imagePickerController = UIImagePickerController()
            
            // Only allow photos to be picked, not taken.
            imagePickerController.sourceType = .camera
            
            imagePickerController.delegate = self
            
            imagePickerController.modalPresentationStyle = UIModalPresentationStyle.popover
            imagePickerController.popoverPresentationController?.sourceView = cameraButton
            
            // Make sure ViewController is notified when the user picks an image.
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
    }
    
 
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else {
            return
        }
        
        switch id {
        case "investigationsSegue":
            if let uinc = segue.destination as? UINavigationController, let _ = uinc.viewControllers.first as? InvestigationViewTableViewController {
                uinc.popoverPresentationController!.delegate = self
                uinc.popoverPresentationController?.sourceView = self.questionButton;
                uinc.popoverPresentationController?.sourceRect = self.questionButton.bounds;
            }
            break
        case "imageInvestigationsSegue":
            if let ivc = segue.destination as? ImageViewController, let tap = sender as? UIGestureRecognizer{
                if let iv = tap.view as? UIImageView, let image = iv.image {
                    let tag = iv.tag
                    if let index = self.tags.index(of: tag) {
                        ivc.imageUrl = self.attachments[index]
                    }
                    ivc.image = image
                    ivc.sourceType = .investigation
                }
            }
        default:
            break
        }
    }
    
    @IBAction func unwindToEvidenceDeleteInvestigation(_ sender: UIStoryboardSegue) {
        
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
    
    @IBAction func saveAction(_ sender: UIButton) {
        
            self.view.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        
            let newExperiment = Experiment()
            
            if let experiment = self.experiment {
                newExperiment.id = experiment.id
            } else {
                
            }
        
            if let ecosystem = experiment?.ecosystem {
                newExperiment.ecosystem = ecosystem
            }
        
        
            newExperiment.question = self.questionButton.titleLabel?.text
            newExperiment.manipulations = self.manipulationsTextView.text
            newExperiment.results = self.resultsTextView.text
            newExperiment.conclusions = self.conclusionsTextView.text
            newExperiment.reasoning = self.reasoningTextView.text
            
            
            let filtered = self.attachments.filter( {$0 != ""} )
            newExperiment.attachments = filtered.joined(separator: ",")
            
            realmDataController.add(withExperiment: newExperiment)
    }
    
    // MARK: Actions
    
    @IBAction func showCamera(_ sender: UIButton) {
        self.showImagePicker(withSourceType: .camera)
    }
    @IBAction func showPhotoLibrary(_ sender: UIButton) {
        self.showImagePicker(withSourceType: .photoLibrary)
    }
    
}

extension ExperimentsViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.view.backgroundColor = #colorLiteral(red: 0.996078372, green: 0.9674537485, blue: 0.7561766128, alpha: 1)
    }
}

extension ExperimentsViewController: UIImagePickerControllerDelegate {
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.startAnimating(CGSize(width: 100, height: 100), message: "Uploading image...")
        // The info dictionary contains multiple representations of the image, and this uses the original.
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            for iv in self.images {
                if iv.image != nil {
                    
                } else {
                    iv.contentMode = .scaleAspectFit
                    iv.image = pickedImage
                    iv.backgroundColor = UIColor.clear
                    //iv.isUserInteractionEnabled = true
                    if !self.tags.contains(iv.tag) {
                        self.tags.append(iv.tag)
                    }
                    
                    break
                }
            }
        }
        
        // Dismiss the picker.
        picker.dismiss(animated: true, completion: {
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                if let data = UIImagePNGRepresentation(pickedImage) {
                    let imageName = "\(Util.randomString(5)).png"
                    let filePath = Util.getDocumentsDirectory().appendingPathComponent(imageName)
                    try? data.write(to: filePath)
                    Util.uploadFile(withURL: filePath, andFilename: imageName, completion: { url in
                        if let url = url {
                            self.attachments.append(url)
                            self.enableView()
                        }
                        self.view.backgroundColor = #colorLiteral(red: 0.996078372, green: 0.9674537485, blue: 0.7561766128, alpha: 1)
                        self.stopAnimating()
                    })
                }
            }
            
        })
        
    }
}

extension ExperimentsViewController: UIPopoverPresentationControllerDelegate {
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        if let ivc = popoverPresentationController.presentedViewController as? InvestigationViewTableViewController, let experiment = ivc.experiment, let id = experiment.id {
            self.experiment = experiment
            //self.selectedExperimentIndex = ivc.selectedExperimentIndex
            
            
            for im in images {
                im.image = nil
                im.backgroundColor = #colorLiteral(red: 0.8129653335, green: 0.8709804416, blue: 0.9280658364, alpha: 1)
            }
            
            self.prepareNotifications(withExperimentId: id)
            //self.update(withExperiment: experiment)
        }
    }
}

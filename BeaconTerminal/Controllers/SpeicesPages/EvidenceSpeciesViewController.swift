//
//  LoginGroupTableViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/11/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Material
import RealmSwift
import Photos
import NVActivityIndicatorView
import Haneke

class EvidenceSpeciesViewController: UIViewController, UINavigationControllerDelegate, NVActivityIndicatorViewable {
    
    var index: Int?
    var groupIndex: Int?
    var fromSpeciesIndex: Int?
    var toSpeciesIndex: Int?
    var relationshipType: RelationshipType?
    var relationship: Relationship?
    var experiment: Experiment?
    

    @IBOutlet weak var topTabbar: ObservationsSegmentedControl!
    @IBOutlet var containerViews: [UIView]!
    @IBOutlet weak var toTextLabel: UILabel!
    @IBOutlet weak var fromTextLabel: UILabel!
    @IBOutlet weak var fromSpeciesImageView: UIImageView!
    @IBOutlet weak var relationshipTypeLabel: UILabel!
    @IBOutlet weak var toSpeciesImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var popoverNavigationController: UINavigationController?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // MARK: View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fromTextLabel.text = ""
        toTextLabel.text = ""
        
        topTabbar.initUI()
        colorizeSelectedSegment()
        prepareTitlePanel()
        
        
        if let obsVC = self.childViewControllers[0] as? ObservationsViewController {
            obsVC.evidencePhotoDelegate = self
            if let relationship = self.relationship {
                if let obsVC = self.childViewControllers[0] as? ObservationsViewController {
                    obsVC.update(withRelationship: relationship)
                }
            }

        }
        
        self.preferredContentSize = CGSize(width: 1000, height: 900)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.preferredContentSize = CGSize(width: 1000, height: 900)
        self.navigationController?.view.superview?.bounds = CGRect(x: 0, y: 0, width: 1000, height: 900)
        super.viewDidAppear(animated)
    }
    
    func prepareTitlePanel() {
        guard let fromSpeciesIndex = self.fromSpeciesIndex else {
            return
        }
        
        guard let toSpeciesIndex = self.toSpeciesIndex else {
            return
        }
        
        guard let relationshipType = self.relationshipType else {
            return
        }
        
        fromSpeciesImageView.image = RealmDataController.generateImageForSpecies(fromSpeciesIndex, isHighlighted: true)
        
        toSpeciesImageView.image = RealmDataController.generateImageForSpecies(toSpeciesIndex, isHighlighted: true)
        
        //get species
        
    
        
        if let fromSpecies = realmDataController.getRealm().speciesWithIndex(withIndex: fromSpeciesIndex) {
            fromTextLabel.text = fromSpecies.name
        }
        
        if let toSpecies = realmDataController.getRealm().speciesWithIndex(withIndex: toSpeciesIndex) {
            toTextLabel.text = toSpecies.name
        }
        
        relationshipTypeLabel.text = "\(StringUtil.relationshipString(withType: relationshipType))"
        
        if let ivc = self.childViewControllers[1] as? InvestigationsViewController, let relationship = self.relationship {
            ivc.relationship = relationship
        }
        
        if let relationship = self.relationship, let experimentId = relationship.experimentId {
            if let experiment = realmDataController.getRealm().experimentsWithId(withId: experimentId) {
                self.experiment = experiment
            }
        }
        
    }
    
    
    @IBAction func deleteAction(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: {
            
            guard let fromIndex = self.fromSpeciesIndex else {
                return
            }
            
            guard let toSpeciesIndex = self.toSpeciesIndex else {
                return
            }
            
            let newRelationship = Relationship()
            
            if let r = self.relationship {
                newRelationship.id = r.id
            } else {
                
            }
            
            
            if let toSpecies = realm?.speciesWithIndex(withIndex: toSpeciesIndex) {
                newRelationship.toSpecies = toSpecies
            }
            
            if let obsVC = self.childViewControllers[0] as? ObservationsViewController {
                newRelationship.note = obsVC.noteTextView.text
            }
            
            if let relationshipType = self.relationshipType {
                newRelationship.relationshipType = relationshipType.rawValue
            }
            
            realmDataController.delete(withRelationship: newRelationship, withSpeciesIndex: fromIndex)
            
        })
        
    }
    
    
    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: {
            guard let fromIndex = self.fromSpeciesIndex else {
                return
            }
            
            guard let toSpeciesIndex = self.toSpeciesIndex else {
                return
            }
            
            let newRelationship = Relationship()
            
            if let r = self.relationship {
                newRelationship.id = r.id
            } else {
                
            }
            
            if let toSpecies = realm?.speciesWithIndex(withIndex: toSpeciesIndex) {
                newRelationship.toSpecies = toSpecies
            }
            
            if let obsVC = self.childViewControllers[0] as? ObservationsViewController {
                newRelationship.note = obsVC.noteTextView.text
                let filtered = obsVC.attachments.filter( {$0 != ""} )
                newRelationship.attachments = filtered.joined(separator: ",")
            }
            
            if let ivc = self.childViewControllers[1] as? InvestigationsViewController, let e = ivc.experiment, let id = e.id {
                newRelationship.experimentId = id
            }

            if let relationshipType = self.relationshipType {
                newRelationship.relationshipType = relationshipType.rawValue
            }
            
            realmDataController.add(withRelationship: newRelationship, withSpeciesIndex: fromIndex)
        })
        
    }
    

    
    func enableView() {
        if let obsVC = self.childViewControllers[0] as? ObservationsViewController {
            if let tag = obsVC.tags.last, let index = obsVC.tags.index(of: tag) {
                obsVC.images[index].isUserInteractionEnabled = true
            }
        }
    }
    
    // MARK: Tab
    
    func colorizeSelectedSegment() {
        let sortedViews = topTabbar.subviews.sorted( by: { $0.frame.origin.x < $1.frame.origin.x } )
        
        for (index, view) in sortedViews.enumerated() {
            if index == 0 {
                
                view.backgroundColor = UIColor.white
                
                
            } else {
                
                view.backgroundColor = #colorLiteral(red: 0.9467939734, green: 0.9468161464, blue: 0.9468042254, alpha: 1)
                
            }
        }
    }
        
    // MARK: Action

    
    @IBAction func changeTab(_ sender: UISegmentedControl) {
        
        let selected =  sender.selectedSegmentIndex
        
        for (index,containerView) in containerViews.enumerated() {
            
            switch selected {
            case index:
                containerView.alpha = 0.0
                containerView.isHidden = false
                containerView.fadeIn(toAlpha: 1.0) {_ in
                    containerView.isHidden = false
                }
            default:
                containerView.fadeOut(0.0) {_ in
                    containerView.isHidden = true
                }
            }
            
        }
    }
    
    @IBAction func unwindToEvidenceSpecies(_ sender: UIStoryboardSegue) {
        
        if let imageController = sender.source as? ImageViewController, let obsVC = self.childViewControllers[0] as? ObservationsViewController {
            
            if let imageUrl = imageController.imageUrl {
                if let index = obsVC.attachments.index(of: imageUrl) {
                    obsVC.attachments.remove(at: index)
                    let tag = obsVC.tags[index]
                    for iv in obsVC.images {
                        if iv.tag == tag {
                            iv.image = nil
                            iv.backgroundColor = #colorLiteral(red: 0.8129653335, green: 0.8709804416, blue: 0.9280658364, alpha: 1)
                        }
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            switch id {
            case "embedInvestgationsSegue":
                realmDataController.fetchExperiments()
                if let ivc = segue.destination as? InvestigationsViewController, let relationship = self.relationship {
                    ivc.relationship = relationship
                }
            default:
                break
            }
        }
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {})
    }
    
    func showImagePicker(withSourceType sourceType: UIImagePickerControllerSourceType) {
        
        if let obsVC = self.childViewControllers[0] as? ObservationsViewController {
            
        switch sourceType {
        case .photoLibrary:
            let imagePickerController = UIImagePickerController()
            
            // Only allow photos to be picked, not taken.
            imagePickerController.sourceType = .photoLibrary
            
            imagePickerController.delegate = self
            
            imagePickerController.modalPresentationStyle = UIModalPresentationStyle.popover
            imagePickerController.popoverPresentationController?.sourceView = obsVC.photoLibButton
            
            // Make sure ViewController is notified when the user picks an image.
            self.present(imagePickerController, animated: true, completion: nil)
        default:
            //camera
            let imagePickerController = UIImagePickerController()
            
            // Only allow photos to be picked, not taken.
            imagePickerController.sourceType = .camera
            
            imagePickerController.delegate = self
            
            imagePickerController.modalPresentationStyle = UIModalPresentationStyle.popover
            imagePickerController.popoverPresentationController?.sourceView = obsVC.cameraButton
            
            // Make sure ViewController is notified when the user picks an image.
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    }

}

extension EvidenceSpeciesViewController: EvidencePhotoDelegate {
    func showCamera() {
        self.showImagePicker(withSourceType: .camera)
    }
    func showPhotoLibrary() {
        self.showImagePicker(withSourceType: .photoLibrary)
    }
}


extension EvidenceSpeciesViewController: UIImagePickerControllerDelegate {
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.doneButton.isEnabled = false
        
        self.startAnimating(CGSize(width: 100, height: 100), message: "Uploading image...")
        // The info dictionary contains multiple representations of the image, and this uses the original.
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage, let obsVC = self.childViewControllers[0] as? ObservationsViewController{
            for iv in obsVC.images {
                if iv.image != nil {
                    
                } else {
                    iv.contentMode = .scaleAspectFit
                    iv.image = pickedImage
                    iv.backgroundColor = UIColor.clear
                    //iv.isUserInteractionEnabled = true
                    if !obsVC.tags.contains(iv.tag) {
                        obsVC.tags.append(iv.tag)
                    }
                    
                    break
                }
            }
        }
        
        // Dismiss the picker.
        picker.dismiss(animated: true, completion: {
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                if let data = UIImagePNGRepresentation(pickedImage), let obsVC = self.childViewControllers[0] as? ObservationsViewController{
                    let imageName = "\(Util.randomString(5)).png"
                    let filePath = Util.getDocumentsDirectory().appendingPathComponent(imageName)
                    try? data.write(to: filePath)
                    Util.uploadFile(withURL: filePath, andFilename: imageName, completion: { url in
                        if let url = url {
                            obsVC.attachments.append(url)
                            self.enableView()
                        }
                        self.stopAnimating()
                        self.doneButton.isEnabled = true
                        
                    })
                }
            }
            
        })
        
    }
}

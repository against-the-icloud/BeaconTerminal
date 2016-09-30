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

class EvidenceSpeciesViewController: UIViewController, UINavigationControllerDelegate {
    
    var fromSpeciesIndex: Int?
    var toSpeciesIndex: Int?
    var relationshipType: RelationshipType?
    var relationship: Relationship?
    var attachments = [String]()
    var tags = [Int]()
    
    @IBOutlet var images: [UIImageView]!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var fromSpeciesImageView: UIImageView!
    @IBOutlet weak var relationshipTypeLabel: UILabel!
    @IBOutlet weak var toSpeciesImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var photoLibButton: FabButton!
    @IBOutlet weak var cameraButton: FabButton!
    
    var popoverNavigationController: UINavigationController?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // Mark: View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTitlePanel()
        photoLibButton.image = Icon.cm.photoLibrary
        photoLibButton.tintColor = UIColor.white
        cameraButton.image = Icon.cm.photoCamera
        cameraButton.tintColor = UIColor.white
        
        for im in images {
            let tag = Randoms.randomInt()
            im.tag = tag
        }
        
        if let relationship = self.relationship {
            if let attachments = relationship.attachments?.components(separatedBy: ",") {
                self.attachments = attachments
                
                for (index, path) in self.attachments.enumerated() {
                    
                    if let url = URL(string: path) {
                        UIImage.contentsOfURL(url: url, completion: { found, error in
                            let tag = self.images[index].tag
                            self.tags.append(tag)
                            self.images[index].isUserInteractionEnabled = true
                            self.images[index].image = found
                            self.images[index].backgroundColor = UIColor.clear
                        })
                    }
                }
                
            }
            
            if let reason = relationship.note {
                noteTextView.text = reason
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.viewDidLayoutSubviews()
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
        
        relationshipTypeLabel.text = "\(StringUtil.relationshipString(withType: relationshipType))"
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
            
            newRelationship.note = self.noteTextView.text
            
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
            
            newRelationship.note = self.noteTextView.text
            
            for attach in self.attachments {
                if attach.isEmpty {
                    
                }
            }
            
            let filtered = self.attachments.filter( {$0 != ""} )
            newRelationship.attachments = filtered.joined(separator: ",")
        
            
            if let relationshipType = self.relationshipType {
                newRelationship.relationshipType = relationshipType.rawValue
            }
            
            realmDataController.add(withRelationship: newRelationship, withSpeciesIndex: fromIndex)
        })
        
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
                    }
                }
            default:
                break
            }
        }
    }
    
    func enableView() {
        if let tag = tags.last, let index = tags.index(of: tag) {
            images[index].isUserInteractionEnabled = true
        }
    }
    
    // Mark: Action
    
    @IBAction func unwindToEvidenceSpecies(_ sender: UIStoryboardSegue) {
        
        if let imageController = sender.source as? ImageViewController {
            
            if let imageUrl = imageController.imageUrl {
                if let index = self.attachments.index(of: imageUrl) {
                    self.attachments.remove(at: index)
                    let tag = tags[index]
                    for iv in images {
                        if iv.tag == tag {
                            iv.image = nil
                            iv.backgroundColor = #colorLiteral(red: 0.8129653335, green: 0.8709804416, blue: 0.9280658364, alpha: 1)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {})
    }
    
    @IBAction func cameraAction(_ sender: FabButton) {
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .camera
        
        imagePickerController.delegate = self
        
        imagePickerController.modalPresentationStyle = UIModalPresentationStyle.popover
        imagePickerController.popoverPresentationController?.sourceView = sender
        
        // Make sure ViewController is notified when the user picks an image.
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func photoLibraryAction(_ sender: FabButton) {
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        imagePickerController.delegate = self
        
        imagePickerController.modalPresentationStyle = UIModalPresentationStyle.popover
        imagePickerController.popoverPresentationController?.sourceView = sender
        
        // Make sure ViewController is notified when the user picks an image.
        self.present(imagePickerController, animated: true, completion: nil)
        //present(imagePickerController, animated: true, completion: nil)
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
        // The info dictionary contains multiple representations of the image, and this uses the original.
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            for iv in images {
                if let found = iv.image {
                    
                } else {
                    iv.contentMode = .scaleAspectFit
                    iv.image = pickedImage
                    iv.backgroundColor = UIColor.clear
                    //iv.isUserInteractionEnabled = true
                    if !tags.contains(iv.tag) {
                        tags.append(iv.tag)
                    }
                    
                    break
                }
            }
        }
        
        // Dismiss the picker.
        self.dismiss(animated: true, completion: {
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
                        self.doneButton.isEnabled = true
                        
                    })
                }
            }
            
        })
        
    }
}

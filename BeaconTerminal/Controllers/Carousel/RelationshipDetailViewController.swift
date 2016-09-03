//
//  RelationshipDetailViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 7/23/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Material
import Photos
import MobileCoreServices

class RelationshipDetailViewController: UIViewController {
    
    // Mark: variables
    var speciesObservation: SpeciesObservation?
    var ecosystemIndex: Int?
    var relationship: Relationship? = nil {
        didSet {
            if let r = relationship {
                if let ecosystemIndex = r.ecosystem?.index {
                    self.ecosystemIndex = ecosystemIndex
                } else {
                    self.ecosystemIndex = 0
                }
                
               
                
                if let attachments = r.attachments {
                    self.attachments.append(attachments)
                }
            }
        }
    }
    
    var sourceView: UIView?
    var attachments: [String] = [String]()
    var isDirty = false
    var imagePickerController: UIImagePickerController = UIImagePickerController()
    var attachmentImageUrl: String?
    
    // Mark: Outlets
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var evidenceImageView: UIImageView!
    @IBOutlet weak var ecosystemSegmentedControl: UISegmentedControl!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var ecosystemSegementedControl: UISegmentedControl!
    @IBOutlet weak var okButton: UIBarButtonItem!
    
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBOutlet weak var fromSpecies: UIImageView!
    @IBOutlet weak var toSpecies: UIImageView!
    @IBOutlet weak var relationshipLabel: UILabel!
    
    // Mark: init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // Mark: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadImageAsset()
        loadTextAssets()
    }
    
    func prepareViews() {
        //textarea
        textView.delegate = self
        textView.becomeFirstResponder()
        textView.autocorrectionType = UITextAutocorrectionType.yes
        textView.spellCheckingType = UITextSpellCheckingType.yes
        
        //buttons
        libraryButton.tintColor = Color.blue.base
        cameraButton.tintColor = Color.blue.base
        
        //image picker and camera
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeLivePhoto as String]
        imagePickerController.allowsEditing = true
        
        //imageview
        evidenceImageView.clipsToBounds = true
        evidenceImageView.layer.masksToBounds = true
        evidenceImageView.contentMode = .scaleAspectFit
        
        updateHeaderView()
    }
    
    func updateHeaderView() {
        //header
        if let species = speciesObservation?.fromSpecies, let r = relationship {
            
            //from species
            
            let fromSpeciesImage = RealmDataController.generateImageForSpecies(species.index, isHighlighted: true)
            
            fromSpecies.contentMode = .scaleAspectFit
            fromSpecies.image = fromSpeciesImage
            
            let toSpeciesImage = RealmDataController.generateImageForSpecies((r.toSpecies?.index)!, isHighlighted: true)
            
            self.toSpecies.contentMode = .scaleAspectFit
            self.toSpecies.image = toSpeciesImage
            
            relationshipLabel.text = titleRelationshipText()
            
        }
    }
    
    func titleRelationshipText() -> String {
        if let r = relationship?.relationshipType {
            switch r {
            case "producer":
                //left side mid
                return "IS EATEN BY"
            case "consumer":
                //left side mid
                return "EATS"
            case "competes":
                //left side mid
                return "DEPENDS ON"
            default:
                //nothing
                return ""
            }
        }
        return ""
    }
    
    func updateTint(_ tint: UIColor) {
        okButton.tintColor = tint
        trashButton.tintColor = tint
    }

    func loadTextAssets() {
        //update views
        if let r = relationship, let index = ecosystemIndex {
            textView.text = r.note
            ecosystemSegementedControl.selectedSegmentIndex = index
        }
    }
    
    func loadImageAsset() {
        if let r = self.relationship {
            if let attachment = r.attachments {
                if !attachment.isEmpty {
                    if let url = URL(string: attachment) {
                        if let assets : PHAsset = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil).firstObject {
                            let targetSize = CGSize(width: evidenceImageView.frame.width,height: evidenceImageView.frame.height)
                            let options = PHImageRequestOptions()
                            
                            PHImageManager.default().requestImage(for: assets, targetSize: targetSize, contentMode: PHImageContentMode.aspectFit, options: options, resultHandler: {
                                (result, info) in
                                self.evidenceImageView.image = result
                            })
                        }
                    }
                }
            }
        }
        
    }
    
    func save() {
        if let r = self.relationship, let so = self.speciesObservation {
            
            LOG.debug("speciesOb \(so.id)")
            let ecosystem = realm!.allObjects(ofType: Ecosystem.self)[self.ecosystemSegmentedControl.selectedSegmentIndex]
            
            dispatch_on_main {
                try! realm!.write {
                    
                    if self.isDirty {
                        r.note = self.textView.text
                        self.isDirty = false
                    }
                    
                    if !self.attachments.isEmpty {
                        r.attachments = self.attachments.first
                    }
                    
                    r.ecosystem = ecosystem
                    r.lastModified = NSDate() as Date
                    realm!.add(r, update: true)
                }
            }
        }
        
    }
    
    // Mark: Actions

    @IBAction func evidenceImageTap(_ sender: UITapGestureRecognizer) {
        LOG.debug("WE TAPPED!")
    }
    
    @IBAction func okButtonAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {
            self.save()
        })
    }
    
    @IBAction func photoLibraryAction(_ sender: UIButton) {
        imagePickerController.sourceType = .savedPhotosAlbum
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func cameraAction(_ sender: UIButton) {
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true, completion: nil)
    }
    @IBAction func deleteButtonAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {
            
            if let r = self.relationship, let so = self.speciesObservation {
                dispatch_on_main {
                    if let rIndex = so.relationships.index(of: r) {
                        
                        Util.makeToast("Deleted \(self.title!)", duration: HRToastDefaultDuration, position: HRToastPositionTop as AnyObject)
                        
                        try! realm!.write {
                            so.relationships.remove(at: rIndex)
                            
                            realm!.add(so, update: true)
                        }
                        
                        realmDataController!.delete(r)
                        
                        if let sourceView = self.sourceView {
                            sourceView.fadeOut(0.4, delay: 0.0, completion: {_ in
                                sourceView.removeFromSuperview()
                            })
                        }
                        
                    }
                }
            }
        })
    }
    
    @IBAction func ecosystemSelectionChanged(_ sender: UISegmentedControl) {
        
        LOG.debug("ecoystem selection \(sender.selectedSegmentIndex)")
        
        if let r = self.relationship, let so = self.speciesObservation {
            
            LOG.debug("speciesOb \(so.id)")
            let ecosystem = realm!.allObjects(ofType: Ecosystem.self)[sender.selectedSegmentIndex]
            
            dispatch_on_main {
                try! realm?.write {
                    r.ecosystem = ecosystem
                    r.lastModified = NSDate() as Date
                    realm?.add(r, update: true)
                }
            }
        }
        
    }
    
    
}

extension RelationshipDetailViewController {
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        if error == nil {
            Util.makeToast("Your image has been saved.")
        } else {
            Util.makeToast("There was an error saving your photo \(error)")
        }
        
    }
}

extension RelationshipDetailViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) { //
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
    
            // todo: set contentMode
            evidenceImageView.image = image
            
                if let imageURL = info[UIImagePickerControllerReferenceURL] as? URL {
                    _ = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil)
                    attachmentImageUrl = imageURL.absoluteString
                    if let attachUrl =  attachmentImageUrl {
                        LOG.debug("url \(attachUrl)")
                        self.attachments.insert(attachUrl, at: 0)
                        
                        UIImageWriteToSavedPhotosAlbum(image, self, #selector(RelationshipDetailViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
                        
                        
                        if let r = self.relationship {
                            dispatch_on_main {
                                try! realm!.write {
                                    r.attachments = attachUrl
                                    r.lastModified = NSDate() as Date
                                    realm!.add(r, update: true)
                                    self.imagePickerController.dismiss(animated: true, completion: nil)
                                    
                                }
                            }
                        }
                        
                    }
                }
        }

    }
    
}

extension RelationshipDetailViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        isDirty = true
    }
}

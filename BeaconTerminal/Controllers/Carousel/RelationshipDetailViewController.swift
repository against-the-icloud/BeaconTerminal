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
    var relationship: Relationship? {
        didSet {
            if let r = relationship {
                if let ecosystemIndex = r.ecosystem?.ecosystemNumber {
                    self.ecosystemIndex = ecosystemIndex
                } else {
                    self.ecosystemIndex = -1
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
    
    // Mark: init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // Mark: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func prepareViews() {


        //textarea
        textView.delegate = self
        textView.becomeFirstResponder()
        textView.autocorrectionType = UITextAutocorrectionType.Yes
        textView.spellCheckingType = UITextSpellCheckingType.Yes


        
        //buttons
        libraryButton.tintColor = MaterialColor.blue.base
        cameraButton.tintColor = MaterialColor.blue.base
        
        //image picker and camera
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeLivePhoto as String]
        imagePickerController.allowsEditing = true
        
        //imageview
        evidenceImageView.clipsToBounds = true
        evidenceImageView.layer.masksToBounds = true
        evidenceImageView.contentMode = .ScaleAspectFit
        
        loadImageAsset()
        loadTextAssets()
    }

    func loadTextAssets() {
        //update views
        if let r = relationship, index = ecosystemIndex {
            textView.text = r.note
            ecosystemSegementedControl.selectedSegmentIndex = index
        }
    }
    
    func loadImageAsset() {
        if let r = self.relationship {
            if let attachment = r.attachments {
                if !attachment.isEmpty {
                    if let url = NSURL(string: attachment) {
                        let assets = PHAsset.fetchAssetsWithALAssetURLs([url], options: nil).firstObject as! PHAsset

                        let targetSize = CGSizeMake(CGRectGetWidth(evidenceImageView.frame),CGRectGetHeight(evidenceImageView.frame))
                        let options = PHImageRequestOptions()

                        PHImageManager.defaultManager().requestImageForAsset(assets, targetSize: targetSize, contentMode: PHImageContentMode.AspectFit, options: options, resultHandler: {
                            (result, info) in
                            self.evidenceImageView.image = result
                        })
                    }
                }
            }
        }
        
    }
    
    func save() {
        if let r = self.relationship, so = self.speciesObservation {
            
            LOG.debug("speciesOb \(so.id)")
            let ecosystem = realm!.objects(Ecosystem.self)[self.ecosystemSegmentedControl.selectedSegmentIndex]
            
            dispatch_on_main {
                try! realmDataController!.realm.write {
                    if self.isDirty {
                        r.note = self.textView.text
                        self.isDirty = false
                    }
                    
                    if !self.attachments.isEmpty {
                        r.attachments = self.attachments.first
                    }
                    
                    r.ecosystem = ecosystem
                    r.lastModified = NSDate()
                    realmDataController!.realm.add(r, update: true)
                }
            }
        }
        
    }
    
    // Mark: Actions

    @IBAction func evidenceImageTap(sender: UITapGestureRecognizer) {
        LOG.debug("WE TAPPED!")
    }
    
    @IBAction func okButtonAction(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {
            self.save()
        })
    }
    
    @IBAction func photoLibraryAction(sender: UIButton) {
        imagePickerController.sourceType = .SavedPhotosAlbum
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func cameraAction(sender: UIButton) {
        imagePickerController.sourceType = .Camera
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    @IBAction func deleteButtonAction(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {
            
            if let r = self.relationship, so = self.speciesObservation {
                dispatch_on_main {
                    if let rIndex = so.relationships.indexOf(r) {
                        
                        getAppDelegate().makeToast("Deleted \(self.title!)", duration: HRToastDefaultDuration, position: HRToastPositionTop)
                        
                        try! realmDataController!.realm.write {
                            so.relationships.removeAtIndex(rIndex)
                            
                            realmDataController!.realm.add(so, update: true)
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
    
    @IBAction func ecosystemSelectionChanged(sender: UISegmentedControl) {
        
        LOG.debug("ecoystem selection \(sender.selectedSegmentIndex)")
        
        if let r = self.relationship, so = self.speciesObservation {
            
            LOG.debug("speciesOb \(so.id)")
            let ecosystem = realm!.objects(Ecosystem.self)[sender.selectedSegmentIndex]
            
            dispatch_on_main {
                try! realmDataController!.realm.write {
                    r.ecosystem = ecosystem
                    r.lastModified = NSDate()
                    realmDataController!.realm.add(r, update: true)
                }
            }
        }
        
    }
    
    
}

extension RelationshipDetailViewController {
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if error == nil {
            getAppDelegate().makeToast("Your image has been saved.")
        } else {
            getAppDelegate().makeToast("There was an error saving your photo \(error)")
        }
        
    }
}

extension RelationshipDetailViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        evidenceImageView.image = image
        
        if let info = editingInfo {
            if let imageURL = info[UIImagePickerControllerReferenceURL] as? NSURL {
                let result = PHAsset.fetchAssetsWithALAssetURLs([imageURL], options: nil)
                attachmentImageUrl = imageURL.absoluteString
                if let attachUrl =  attachmentImageUrl {
                    self.attachments.insert(attachUrl, atIndex: 0)
                    
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(RelationshipDetailViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    
                    
                    if let r = self.relationship {
                        dispatch_on_main {
                            try! realmDataController!.realm.write {
                                r.attachments = attachUrl
                                r.lastModified = NSDate()
                                realmDataController!.realm.add(r, update: true)
                                self.imagePickerController.dismissViewControllerAnimated(true, completion: nil)
                                
                            }
                        }
                    }
                    
                }
                
            }
        }
        
        
        
    }
    
}

extension RelationshipDetailViewController: UITextViewDelegate {

    func textViewDidChange(textView: UITextView) {
        isDirty = true
    }
}
//
//  ObservationViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 11/6/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Material
import RealmSwift
import Photos
import NVActivityIndicatorView
import Haneke

protocol EvidencePhotoDelegate: class {
    func showCamera()
    func showPhotoLibrary()
}


class ObservationsViewController: UIViewController {
    
    @IBOutlet weak var questionButton: UIButton!
    @IBOutlet weak var photoLibButton: FabButton!
    @IBOutlet weak var cameraButton: FabButton!
    @IBOutlet var images: [UIImageView]!
    @IBOutlet weak var noteTextView: UITextView!
    
    var relationshipType: RelationshipType?
    var relationship: Relationship?
    var attachments = [String]()
    var tags = [Int]()
    weak var evidencePhotoDelegate: EvidencePhotoDelegate?

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoLibButton.image = Icon.cm.photoLibrary
        photoLibButton.tintColor = UIColor.white
        cameraButton.image = Icon.cm.photoCamera
        cameraButton.tintColor = UIColor.white
        
        noteTextView.text = "We saw… \n\n\n\n We think…because…"

        for im in images {
            let tag = Randoms.randomInt()
            im.tag = tag
            self.tags.append(tag)
        }
        
    }
    
    func update(withRelationship relationship: Relationship) {
        self.relationship = relationship

       
        if let relationship = self.relationship {
            if let attachments = relationship.attachments?.components(separatedBy: ",") {
                self.attachments = attachments
                
                for (index, path) in self.attachments.enumerated() {
                    
                    if let url = URL(string: path) {
                        self.images[index].hnk_setImageFromURL(url)
                        self.images[index].isUserInteractionEnabled = true
                        self.images[index].backgroundColor = UIColor.clear
                    }
                }
                
            }
            
            if let reason = relationship.note {
                noteTextView.text = reason
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            switch id {
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
            default:
                break
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
    
    @IBAction func cameraAction(_ sender: FabButton) {
        self.evidencePhotoDelegate?.showCamera()
    }
    
    @IBAction func photoLibraryAction(_ sender: FabButton) {
        self.evidencePhotoDelegate?.showPhotoLibrary()
    }
}




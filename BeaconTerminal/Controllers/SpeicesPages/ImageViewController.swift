//
//  ImageViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 9/28/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit

enum ImageControllerSourceType {
    case preferences
    case species
}

class ImageViewController: UIViewController {
    
    var sourceType: ImageControllerSourceType?
    var image: UIImage?
    var imageUrl: String?
    var canDelete: Bool?
    @IBOutlet weak var imageScrollView: ImageScrollView!
    
    @IBOutlet weak var deleteButtonItem: UIBarButtonItem!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = self.image {
            imageScrollView.display(image: image)
        }
        
        if let canDelete = self.canDelete {
            deleteButtonItem.tintColor = UIColor.black
            deleteButtonItem.isEnabled = false
        }
        
    }
    @IBAction func deleteImageAction(_ sender: AnyObject) {
        
        if let st = self.sourceType {
            switch st {
            case .preferences:
                break
            default:
                self.performSegue(withIdentifier: "unwindToEvidenceDeleteSpeciesWithSegue", sender: self)
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func closeAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}

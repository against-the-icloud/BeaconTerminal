//
//  ImageViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 9/28/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit

class ImageViewController: UIViewController {
    
    var image: UIImage?
    var imageUrl: String?
    var canDelete: Bool?
    
    @IBOutlet weak var deleteButtonItem: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        
        if let canDelete = self.canDelete {
            deleteButtonItem.tintColor = UIColor.black
            deleteButtonItem.isEnabled = false
        }
        
    }
    @IBAction func deleteImageAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil) 
    }
    @IBAction func closeAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}

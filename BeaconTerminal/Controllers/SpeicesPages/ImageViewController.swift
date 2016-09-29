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
    
    @IBOutlet weak var imageView: UIImageView!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
    @IBAction func deleteImageAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil) 
    }
    @IBAction func closeAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}

//
//  EvidenceViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 9/5/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit

class EvidenceViewController: UIViewController {
    
    var evidenceImageName:String?
    
    @IBOutlet weak var evidenceImageView: UIImageView!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let evidenceImageName = self.evidenceImageName else {
            return
        }
        
        evidenceImageView.image = UIImage(named: evidenceImageName)
    }
    
    @IBAction func doneAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}

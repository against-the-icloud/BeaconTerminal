//
//  TerminalCellController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/26/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit

class TerminalCellController: UIViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet var imageViewCells: [UIImageView]!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
    
    func prepareView() {
        
    }
    
}

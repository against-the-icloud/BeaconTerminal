//
// Created by Anthony Perritano on 6/1/16.
// Copyright (c) 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Material

class AddContributionViewController : UIViewController {


    @IBOutlet weak var observationView: ObservationView!
  
    @IBOutlet weak var reasonTextView: TextView!
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    var speciesIndex = 0
    var observationId : String? //use enums


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        changeSpecies(self.speciesIndex)
        let _border = CAShapeLayer()

        _border.strokeColor = UIColor.blackColor().CGColor
        _border.fillColor = nil
        _border.lineDashPattern = [4, 4]
        
        imageView1.layer.addSublayer(_border)
         imageView2.layer.addSublayer(_border)
         imageView3.layer.addSublayer(_border)
    }

    func changeSpecies(speciesIndex: Int) {
        let speciesImage = DataManager.sharedInstance.generateImageForSpecies(speciesIndex)

        observationView.mainSpiecesImage.image = speciesImage
        if let  obsId = observationId {
            observationView.viewLabel.text = obsId
        }
    }
    
}

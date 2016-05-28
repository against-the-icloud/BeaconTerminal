//
//  ObservationView.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 5/26/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Spring

@IBDesignable
class ObservationView: SpringView {
    
    @IBOutlet weak var viewLabel: UILabel!
    
    @IBOutlet var view: UIView!
    
    @IBOutlet weak var mainSpiecesImage: UIImageView!
    
    @IBOutlet weak var dropView: SpringView!
    
    @IBInspectable var text: String? {
        didSet { viewLabel.text = text }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    private func nibSetup() {        
        self.view = loadViewFromNib()
        self.view.frame = bounds
        
        self.view.translatesAutoresizingMaskIntoConstraints = true
        
        self.addSubview(view)
        
        prepareView()
    }

    private func prepareView() {
        self.view.bringSubviewToFront(self.mainSpiecesImage)
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: String(self.dynamicType), bundle: bundle)
        let nibView = nib.instantiateWithOwner(self, options: nil).first as! UIView
        
        return nibView
    }
}
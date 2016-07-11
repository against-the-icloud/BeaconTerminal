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
class ObservationView: UIView {
    
    
    
    @IBOutlet weak var viewLabel: UILabel!
    
    @IBOutlet var view: UIView!
    
    @IBOutlet weak var tapGesture: SpringView!
    
    @IBOutlet weak var mainSpiecesImage: UIImageView!
    
  
    @IBOutlet weak var imageView: UIImageView!
    
    @IBInspectable var text: String? {
        didSet { viewLabel.text = text }
    }
    
    @IBInspectable var isEditing: Bool = false
    
    @IBOutlet weak var observationDropView: ObservationDropView!
    
    @IBInspectable var observationId: String?    
    
    
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
       // LOG.debug("bounds \(dropView.bounds) frame \(dropView.frame)")

        self.view.frame = bounds
        self.observationDropView.isEditing = self.isEditing
        //self.view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        //dropView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        //self.view.frame = bounds
        
        //self.view.translatesAutoresizingMaskIntoConstraints = true
        //self.dropView.translatesAutoresizingMaskIntoConstraints = false

        
        self.addSubview(view)
        prepareView()
    }
    
    override func setNeedsDisplay() {
        super.setNeedsLayout()
        clearBorder()
    }

    func clearBorder() {
        if isEditing {
            self.observationDropView.borderWidth = 0.0
            self.observationDropView.borderColor = UIColor.clearColor()
            self.observationDropView.shadowColor = UIColor.clearColor()
        }
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


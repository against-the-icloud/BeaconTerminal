//
//  ScannerViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 5/8/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Material
import Pulsator
import Spring
import IBAnimatable

class ScannerViewController: UIViewController {

   
    let _border = CAShapeLayer()
    
    @IBOutlet weak var scannerView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupPulseView()
        setup()

      
    }
    
    func setup() {
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.view.backgroundColor = UIColor.clearColor()
            
            let blurEffect = UIBlurEffect(style: .ExtraLight)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            self.view.insertSubview(blurEffectView, atIndex: 0)
        } else {
            self.view.backgroundColor = UIColor.whiteColor()
        }
        
        _border.strokeColor = UIColor.blackColor().CGColor
        _border.fillColor = nil
        _border.lineDashPattern = [4, 4]
        scannerView.layer.addSublayer(_border)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
         let pulsator = Pulsator()
       // pulseView.superview?.layer.insertSublayer(pulsator, below: pulseView.layer)
        
        
        scannerView.layer.addSublayer(pulsator)
        pulsator.position = CGPointMake(scannerView.frame.width/2, scannerView.frame.height/2)
        pulsator.numPulse = 5
        pulsator.radius = scannerView.frame.width/2
        pulsator.animationDuration = 5
        pulsator.backgroundColor = UIColor.redColor().CGColor
        pulsator.start()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _border.path = UIBezierPath(roundedRect: scannerView.bounds, cornerRadius:scannerView.frame.width/2).CGPath
        _border.frame = scannerView.bounds
    }
}
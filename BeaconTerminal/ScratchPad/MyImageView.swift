//
//  MyImageView.swift
//  TouchCanvas
//
//  Created by Anthony Perritano on 5/11/16.
//  Copyright © 2016 Apple, Inc. All rights reserved.
//

import Foundation
import UIKit


class MyImageView: UIImageView {
    var lastLocation:CGPoint = CGPointMake(0, 0)
    
    override init(image: UIImage?) {
        super.init(image: image)
        setup()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        // Initialization code
//        let panRecognizer = UIPanGestureRecognizer(target:self, action:"detectPan:")
//        self.gestureRecognizers = [panRecognizer]
//        
//        //randomize view color
//        let blueValue = CGFloat(Int(arc4random() % 255)) / 255.0
//        let greenValue = CGFloat(Int(arc4random() % 255)) / 255.0
//        let redValue = CGFloat(Int(arc4random() % 255)) / 255.0
//        
//        self.backgroundColor = UIColor(red:redValue, green: greenValue, blue: blueValue, alpha: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
         self.userInteractionEnabled = true
        // Initialization code
        let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(MyImageView.detectPan(_:)))
        self.gestureRecognizers = [panRecognizer]
    }
    
    func detectPan(recognizer:UIPanGestureRecognizer) {
        let translation  = recognizer.translationInView(self.superview!)
        self.center = CGPointMake(lastLocation.x + translation.x, lastLocation.y + translation.y)
    }
    
    /*override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
     // Promote the touched view
     self.superview?.bringSubviewToFront(self)
     
     // Remember original location
     lastLocation = self.center
     }*/
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Promote the touched view
        self.superview?.bringSubviewToFront(self)
        
        // Remember original location
        lastLocation = self.center
    }
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect)
     {
     // Drawing code
     }
     */
    
}

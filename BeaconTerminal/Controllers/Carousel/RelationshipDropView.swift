//
//  ObservationDropView.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 6/5/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit

class RelationshipDropView: DropTargetView {

    var anchorCenter: CGPoint = CGPoint(x: 0, y: 0)
    var targetPaths = [Int: UIBezierPath]()
    var ringColor : UIColor?


    var draggableViews = [Int: DraggableSpeciesImageView]()
    var anchorView : UIView?

    var isEditing: Bool = false {
        didSet {
            if isEditing {
                self.clearsContextBeforeDrawing = true
            } else {
                self.clearsContextBeforeDrawing = false
            }
        }
    }
    var targetBorderWidth: CGFloat = 0.0
    var targetBorderColor = UIColor.blackColor()
    var lineWidth : CGFloat = 1.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareView()
    }

    func prepareView() {
    }

//    func addDraggableView(draggableView: DraggableSpeciesImageView) {
//        
//        let index = draggableView.tag
//        
//        if draggableViews.indexForKey(index) == nil {
//            self.addSubview(draggableView)
//            self.setNeedsDisplay()
//            draggableViews.updateValue(draggableView, forKey: draggableView.tag)
//        }
//
//    }
    

    // Resizes an input image (self) to a specified size
    func imageView() -> UIImage? {
        // Begins an image context with the specified size
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.frame.width,self.frame.height    ), false, 0.0);
        // Draws the input image (self) in the specified size
        for (_, value) in targetPaths {
            value.lineWidth = 3
            UIColor.blackColor().setStroke()
            value.stroke()
        }
        // Gets an UIImage from the image context
        let result = UIGraphicsGetImageFromCurrentImageContext()
        // Ends the image context
        UIGraphicsEndImageContext();
        // Returns the final image, or NULL on error
        return result;
    }
}
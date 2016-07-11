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

    var originPoint: CGPoint = CGPoint(x: 0, y: 0)
    var targetPoints = [CGPoint]()
    var targetPaths = [Int: UIBezierPath]()

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


    func updatePath(index: Int, pathPoint: CGPoint) {
        if let p = targetPaths[index] {
            // now val is not nil and the Optional has been unwrapped, so use it
            p.removeAllPoints()
            p.lineWidth = lineWidth
            p.moveToPoint(originPoint)
            p.addLineToPoint(pathPoint)
            p.closePath()
        } else {
            let p = UIBezierPath()
            p.moveToPoint(originPoint)
            p.addLineToPoint(pathPoint)
            p.closePath()
            targetPaths.updateValue(p, forKey: index)
        }
//        LOG.debug("PATHS targetPaths")
//        for (key, value) in targetPaths {
//            LOG.debug("\n \(key) \(value)")
//        }
    }


    override func drawRect(rect: CGRect) {
        let con = UIGraphicsGetCurrentContext()
        CGContextClearRect(con, rect)
        CGContextSetFillColorWithColor(con, self.backgroundColor?.CGColor)
        CGContextFillRect(con, rect)
        if isEditing {
            LOG.debug("PATHS \(targetPaths)")
            for (_, value) in targetPaths {
                value.lineWidth = lineWidth
                UIColor.blackColor().setStroke()
                value.stroke()
            }
        } else {
            super.drawRect(rect)
        }
    }

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
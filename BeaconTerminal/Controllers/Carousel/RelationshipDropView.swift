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

    func addDraggableView(draggableView: DraggableSpeciesImageView) {
        
        let index = draggableView.tag
        

        
        if draggableViews.indexForKey(index) == nil {
            // the key exists does not  in the dictionary
//            draggableView.borderColor = ringColor
//            draggableView.borderWidth = 4.0
            self.addSubview(draggableView)
            self.setNeedsDisplay()
            draggableViews.updateValue(draggableView, forKey: draggableView.tag)
            self.updatePath(draggableView.tag, pathPoint: draggableView.center, doubleArrow: draggableView.doubleArrow, inwardArrow: draggableView.inwardArrow)
        }
        

        
    }

    func updatePath(index: Int, pathPoint: CGPoint, doubleArrow: Bool, inwardArrow: Bool) {
        
        let headLength : CGFloat = 15.0
        let headWidth : CGFloat = 8.0
        let tailWidth : CGFloat = 4.0
        
         //var halfRect = CGRectIntersection(anchorView!.frame, self.frame)
         //let halfRect = (anchorView?.frame.offsetBy(dx: -15.0, dy: -15.0))!
        
        //let mOrigin = CGPointMake(halfRect.midX, halfRect.midY)
        
        
        let masterLine = UIBezierPath.bezierPathWithArrowFromPoint(anchorCenter, endPoint: pathPoint, tailWidth: tailWidth, headWidth: headWidth, headLength: headLength, doubleArrow: doubleArrow, inwardArrow: inwardArrow)
        masterLine.closePath()
        
        let dView = draggableViews[index]
        
        let newPathPoint : CGPoint = findIntersectionPointWithView(masterLine, view: dView!)
        //let newOrigin : CGPoint = findIntersectionPoint(masterLine, view: anchorView!)
        
//        let newOrigin = findIntersectionRect(masterLine, rect1: anchorView!.frame, rect2: self.frame)
        let newOrigin : CGPoint = findIntersectionPointWithView(masterLine, view: anchorView!)
        //let newOrigin = findIntersectionPointWithRect(masterLine, rect: halfRect)
        
        if var p = targetPaths[index] {
            
            p = UIBezierPath.bezierPathWithArrowFromPoint(anchorCenter, endPoint: newPathPoint, tailWidth: tailWidth, headWidth: headWidth, headLength: headLength, doubleArrow: doubleArrow, inwardArrow: inwardArrow)
            
            p.closePath()
            
            targetPaths.updateValue(p, forKey: index)

        } else {
    
            
            
            var p = UIBezierPath.bezierPathWithArrowFromPoint(anchorCenter, endPoint: newPathPoint, tailWidth: tailWidth, headWidth: headWidth, headLength: headLength, doubleArrow: doubleArrow, inwardArrow: inwardArrow)
            p.closePath()
            targetPaths.updateValue(p, forKey: index)
        }
    }

    func findIntersectionRect(path: UIBezierPath, rect1: CGRect, rect2: CGRect) -> CGPoint {
        
        let rect3 = CGRectIntersection(rect1, rect2)
        
        //find x
        
        let maxY = CGRectGetMaxY(rect3)
        let minY = CGRectGetMinY(rect3)
        
        let maxX = CGRectGetMaxX(rect3)
        let minX = CGRectGetMinX(rect3)
        
        
        //check left minX constant, maxY interate
        for y in Int(minY)...Int(maxY) {
            let testPoint = CGPointMake(minX, CGFloat(y))
            if path.containsPoint(testPoint) {
                return testPoint
            }
        }
        
        //check bottom maxY constant, minX interate
        for x in Int(minX)...Int(maxX) {
            let testPoint = CGPointMake(CGFloat(x), maxY)
            if path.containsPoint(testPoint) {
                return testPoint
            }
        }
        
        //check right maxX constant, minY interate
        for y in Int(minY)...Int(maxY) {
            let testPoint = CGPointMake(maxX, CGFloat(y))
            if path.containsPoint(testPoint) {
                return testPoint
            }
        }
        
        //check top minY constant, minX interate
        for x in Int(minX)...Int(maxX) {
            let testPoint = CGPointMake(CGFloat(x),minY)
            if path.containsPoint(testPoint) {
                return testPoint
            }
        }
        
        return CGPointZero
    }


    func findIntersectionPointWithView(path: UIBezierPath, view: UIView) -> CGPoint {
        return findIntersectionPointWithRect(path, rect: view.frame)
    }
    
   func findIntersectionPointWithRect(path: UIBezierPath, rect: CGRect) -> CGPoint {
        
        //find x
        
        let maxY = rect.maxY
        let minY = rect.minY
        
        let maxX = rect.maxX
        let minX = rect.minX
        
        
        //check left minX constant, maxY interate
        for y in Int(minY)...Int(maxY) {
            let testPoint = CGPointMake(minX, CGFloat(y))
            if path.containsPoint(testPoint) {
                return testPoint
            }
        }
        
        //check bottom maxY constant, minX interate
        for x in Int(minX)...Int(maxX) {
            let testPoint = CGPointMake(CGFloat(x), maxY)
            if path.containsPoint(testPoint) {
                return testPoint
            }
        }
        
        //check right maxX constant, minY interate
        for y in Int(minY)...Int(maxY) {
            let testPoint = CGPointMake(maxX, CGFloat(y))
            if path.containsPoint(testPoint) {
                return testPoint
            }
        }
        
        //check top minY constant, minX interate
        for x in Int(minX)...Int(maxX) {
            let testPoint = CGPointMake(CGFloat(x),minY)
            if path.containsPoint(testPoint) {
                return testPoint
            }
        }
        
        return CGPointZero
    }
    
    override func drawRect(rect: CGRect) {
        let con = UIGraphicsGetCurrentContext()
        CGContextClearRect(con, rect)
        CGContextSetFillColorWithColor(con, self.backgroundColor?.CGColor)
        CGContextFillRect(con, rect)
        if isEditing {
//            for (_, value) in targetPaths {
//                //value.lineWidth = lineWidth
//                UIColor.blackColor().setStroke()
//                value.stroke()
//            }
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
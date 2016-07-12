//: Playground - noun: a place where people can play

import UIKit
import Foundation
import XCPlayground











class TestView: UIView {
    
    var originPoint: CGPoint = CGPoint(x: 50, y: 25)
    var newCenter: CGPoint = CGPoint(x: 75, y: 100)
    
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
    var targetBorderWidth: CGFloat = 2.0
    var targetBorderColor = UIColor.redColor()
    var lineWidth : CGFloat = 2.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareView()
    }
    
    func prepareView() {
        isEditing = true
    }
    
    
    func updatePath() {
        
        let p = UIBezierPath.bezierPathWithArrowFromPoint(originPoint, endPoint: newCenter, tailWidth: 4, headWidth: 8, headLength: 6)
        p.closePath()
        targetPaths.updateValue(p, forKey: 0)
    }
    
    
    
    override func drawRect(rect: CGRect) {
        let con = UIGraphicsGetCurrentContext()
        CGContextClearRect(con, rect)
        CGContextSetFillColorWithColor(con, UIColor.whiteColor().CGColor)
        CGContextFillRect(con, rect)
        if isEditing {
            for (_, value) in targetPaths {
                //value.lineWidth = lineWidth
                UIColor.blackColor().setStroke()
                value.stroke()
            }
        } else {
            super.drawRect(rect)
        }
    }
}

let containerView = TestView(frame: CGRect(x: 0.0, y: 0.0, width: 200, height: 200))


//XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = containerView

containerView.updatePath()

extension UIBezierPath {
    
    class func getAxisAlignedArrowPoints(inout points: Array<CGPoint>, forLength: CGFloat, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat, doubleArrow: Bool) {
        
        let tailLength = forLength - headLength
        
        //-->
        //starts bottom left
        
        //right side length
        points.append(CGPointMake(0, tailWidth/2))
        points.append(CGPointMake(tailLength, tailWidth/2))
        
        
        //arrowhead
        points.append(CGPointMake(tailLength, headWidth/2))
        points.append(CGPointMake(forLength, 0))
        points.append(CGPointMake(tailLength, -headWidth/2))
        //
        //        //left side length
        //
        points.append(CGPointMake(tailLength, -tailWidth/2))
        points.append(CGPointMake(0, -tailWidth/2))
        
    
        //double arrow
        if doubleArrow {
            points.append(CGPointMake(0, -headWidth/2))
            points.append(CGPointMake(-headWidth, 0))
            points.append(CGPointMake(0, tailWidth))
        }
        
    }
    
    
    class func transformForStartPoint(startPoint: CGPoint, endPoint: CGPoint, length: CGFloat) -> CGAffineTransform{
        let cosine: CGFloat = (endPoint.x - startPoint.x)/length
        let sine: CGFloat = (endPoint.y - startPoint.y)/length
        
        return CGAffineTransformMake(cosine, sine, -sine, cosine, startPoint.x, startPoint.y)
    }
    
    
    class func bezierPathWithArrowFromPoint(startPoint:CGPoint, endPoint: CGPoint, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat) -> UIBezierPath {
        
        let xdiff: Float = Float(endPoint.x) - Float(startPoint.x)
        let ydiff: Float = Float(endPoint.y) - Float(startPoint.y)
        let length = hypotf(xdiff, ydiff)
        
        //let doubleArrowLength = CGFloat(length)-headLength
        
        
        var points = [CGPoint]()
        self.getAxisAlignedArrowPoints(&points, forLength: CGFloat(length), tailWidth: tailWidth, headWidth: headWidth, headLength: headLength, doubleArrow: true)
        
        var transform: CGAffineTransform = self.transformForStartPoint(startPoint, endPoint: endPoint, length:  CGFloat(length))
        
        let cgPath: CGMutablePathRef = CGPathCreateMutable()
        CGPathAddLines(cgPath, &transform, points,points.count)
        
        
        //
        //        var points2 = [CGPoint]()
        //        self.getAxisAlignedArrowPoints(&points2, forLength: CGFloat(length), tailWidth: tailWidth, headWidth: headWidth, headLength: headLength, doubleArrow: false)
        //
        //
        //        var transform2: CGAffineTransform = self.transformForStartPoint(endPoint, endPoint: startPoint, length:  CGFloat(doubleArrowLength))
        //
        //
        //        CGPathAddLines(cgPath, &transform2, points2, 7)
        
        
        CGPathCloseSubpath(cgPath)
        
        let uiPath: UIBezierPath = UIBezierPath(CGPath: cgPath)
        return uiPath
    }
}

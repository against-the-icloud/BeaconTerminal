import UIKit
import Foundation

extension UIBezierPath {
    
    class func getAxisAlignedArrowPoints(inout points: Array<CGPoint>, forLength: CGFloat, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat, doubleArrow: Bool, inwardArrow: Bool) {
        
       let tailLength = forLength - headLength

        
        //right side length
        points.append(CGPointMake(0, tailWidth/2))
        points.append(CGPointMake(tailLength, tailWidth/2))
        
        
        //arrowhead
        if inwardArrow == false {
                    points.append(CGPointMake(tailLength, headWidth/2))
                    points.append(CGPointMake(forLength, 0))
                    points.append(CGPointMake(tailLength, -headWidth/2))
        }


        //left side length
        
        points.append(CGPointMake(tailLength, -tailWidth/2))
        points.append(CGPointMake(0, -tailWidth/2))
        
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
    
    
    class func bezierPathWithArrowFromPoint(startPoint:CGPoint, endPoint: CGPoint, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat, doubleArrow: Bool, inwardArrow: Bool) -> UIBezierPath {
        
        let xdiff: Float = Float(endPoint.x) - Float(startPoint.x)
        let ydiff: Float = Float(endPoint.y) - Float(startPoint.y)
        let length = hypotf(xdiff, ydiff)
        
        //let doubleArrowLength = CGFloat(length)-headLength

        
        var points = [CGPoint]()
        self.getAxisAlignedArrowPoints(&points, forLength: CGFloat(length), tailWidth: tailWidth, headWidth: headWidth, headLength: headLength, doubleArrow: doubleArrow, inwardArrow: inwardArrow)
        
        var transform: CGAffineTransform = self.transformForStartPoint(startPoint, endPoint: endPoint, length:  CGFloat(length))
        
        let cgPath: CGMutablePathRef = CGPathCreateMutable()
        CGPathAddLines(cgPath, &transform, points,points.count)
        
        CGPathCloseSubpath(cgPath)
        
        let uiPath: UIBezierPath = UIBezierPath(CGPath: cgPath)
        return uiPath
    }
}
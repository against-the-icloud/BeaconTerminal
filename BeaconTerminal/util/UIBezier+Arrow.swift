import UIKit
import Foundation

extension UIBezierPath {
    
    class func getAxisAlignedArrowPoints(_ points: inout Array<CGPoint>, forLength: CGFloat, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat, doubleArrow: Bool, inwardArrow: Bool) {
        
       let tailLength = forLength - headLength

        
        //right side length
        points.append(CGPoint(x: 0, y: tailWidth/2))
        points.append(CGPoint(x: tailLength, y: tailWidth/2))
        
        
        //arrowhead
        if inwardArrow == false {
                    points.append(CGPoint(x: tailLength, y: headWidth/2))
                    points.append(CGPoint(x: forLength, y: 0))
                    points.append(CGPoint(x: tailLength, y: -headWidth/2))
        }


        //left side length
        
        points.append(CGPoint(x: tailLength, y: -tailWidth/2))
        points.append(CGPoint(x: 0, y: -tailWidth/2))
        
        if doubleArrow {
            points.append(CGPoint(x: 0, y: -headWidth/2))
            points.append(CGPoint(x: -headWidth, y: 0))
            points.append(CGPoint(x: 0, y: tailWidth))
        }
    }
    
    
    class func transformForStartPoint(_ startPoint: CGPoint, endPoint: CGPoint, length: CGFloat) -> CGAffineTransform{
        let cosine: CGFloat = (endPoint.x - startPoint.x)/length
        let sine: CGFloat = (endPoint.y - startPoint.y)/length
        
            
        return __CGAffineTransformMake(cosine, sine, -sine, cosine, startPoint.x, startPoint.y)
    }
    
    
    class func bezierPathWithArrowFromPoint(_ startPoint:CGPoint, endPoint: CGPoint, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat, doubleArrow: Bool, inwardArrow: Bool) -> UIBezierPath {
        
        let xdiff: Float = Float(endPoint.x) - Float(startPoint.x)
        let ydiff: Float = Float(endPoint.y) - Float(startPoint.y)
        let length = hypotf(xdiff, ydiff)
        
        //let doubleArrowLength = CGFloat(length)-headLength

        
        var points = [CGPoint]()
        self.getAxisAlignedArrowPoints(&points, forLength: CGFloat(length), tailWidth: tailWidth, headWidth: headWidth, headLength: headLength, doubleArrow: doubleArrow, inwardArrow: inwardArrow)
        
        var transform: CGAffineTransform = self.transformForStartPoint(startPoint, endPoint: endPoint, length:  CGFloat(length))
        
        let cgPath: CGMutablePath = CGMutablePath()
        cgPath.addLines(&transform, between: points,count: points.count)
        
        cgPath.closeSubpath()
        
        let uiPath: UIBezierPath = UIBezierPath(cgPath: cgPath)
        return uiPath
    }
}

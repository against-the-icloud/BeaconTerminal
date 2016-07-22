
import Foundation
import UIKit

class DragUtil {
    
    class func scaledImageToSize(image: UIImage, newSize: CGSize) -> UIImage{
        UIGraphicsBeginImageContext(newSize)
        image.drawInRect(CGRectMake(0 ,0, newSize.width, newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        return newImage
    }
    class func animateView(view:UIView, scale:CGFloat = 1.3, alpha:CGFloat = 0.5,duration:NSTimeInterval = 0.2){
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(duration)
        view.transform = CGAffineTransformMakeScale(scale, scale)
        view.alpha = alpha
        UIView.commitAnimations()
    }
    
    class func animateViewWithCompletion(view:UIView, scale:CGFloat = 1.3, alpha:CGFloat = 0.5,duration:NSTimeInterval = 0.2, completion: (() -> Void)? = nil){
  
        UIView.animateWithDuration(duration, animations: {
            
       
            view.transform = CGAffineTransformMakeScale(scale, scale)
            view.alpha = alpha
            
            }, completion: { (complete: Bool) in
                if let c = completion {
                    c()
                }
        })
    }
    
}
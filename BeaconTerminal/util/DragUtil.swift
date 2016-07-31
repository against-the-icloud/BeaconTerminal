
import Foundation
import UIKit

class DragUtil {
    
    class func scaledImageToSize(_ image: UIImage, newSize: CGSize) -> UIImage{
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0 ,y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    class func animateView(_ view:UIView, scale:CGFloat = 1.3, alpha:CGFloat = 0.5,duration:TimeInterval = 0.2){
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(duration)
        view.transform = CGAffineTransform(scaleX: scale, y: scale)
        view.alpha = alpha
        UIView.commitAnimations()
    }
    
    class func animateViewWithCompletion(_ view:UIView, scale:CGFloat = 1.3, alpha:CGFloat = 0.5,duration:TimeInterval = 0.2, completion: (() -> Void)? = nil){
  
        UIView.animate(withDuration: duration, animations: {
            view.transform = CGAffineTransform(scaleX: scale, y: scale)
            view.alpha = alpha
            }, completion: { (complete: Bool) in
                if let c = completion {
                    c()
                }
        })
    }
    
}

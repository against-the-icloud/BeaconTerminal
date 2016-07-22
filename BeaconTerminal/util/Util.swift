import Foundation
import UIKit

class Util {
    
    class func classNameAsString(obj: Any) -> String {
        return String(obj.dynamicType).componentsSeparatedByString("__").last!
    }
    // MARK: Color
    class func isLightColor(color: UIColor) -> Bool {
        var white: CGFloat = 0.0
        color.getWhite(&white, alpha: nil)
        
        var isLight = false
        
        LOG.debug("WHITE \(white)")
        
        if white >= 0.5 {
            isLight = true
        } else {
        }
        
        return isLight
    }
    
    class func generateRandomPoint(maxXValue: UInt32, maxYValue: UInt32) -> CGPoint {
        let rand_x = CGFloat(arc4random_uniform(maxXValue)) // maxXValue is a variable with your maximum possible x value
        let rand_y = CGFloat(arc4random_uniform(maxYValue)) // maxYValue is a variable with your maximum possible y value
        return CGPoint(x: rand_x, y: rand_y)
        
    }
    
    
    class func getRandomColor() -> UIColor{
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
}



// MARK: UIImage Extensions

extension UIImage {
    
    // Resizes an input image (self) to a specified size
    func resizeToSize(size: CGSize!) -> UIImage? {
        // Begins an image context with the specified size
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
        // Draws the input image (self) in the specified size
        self.drawInRect(CGRectMake(0, 0, size.width, size.height))
        // Gets an UIImage from the image context
        let result = UIGraphicsGetImageFromCurrentImageContext()
        // Ends the image context
        UIGraphicsEndImageContext();
        // Returns the final image, or NULL on error
        return result;
    }
    
    // Crops an input image (self) to a specified rect
    func cropToRect(rect: CGRect!) -> UIImage? {
        // Correct rect size based on the device screen scale
        let scaledRect = CGRectMake(rect.origin.x * self.scale, rect.origin.y * self.scale, rect.size.width * self.scale, rect.size.height * self.scale);
        // New CGImage reference based on the input image (self) and the specified rect
        let imageRef = CGImageCreateWithImageInRect(self.CGImage, scaledRect);
        // Gets an UIImage from the CGImage
        let result = UIImage(CGImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        // Returns the final image, or NULL on error
        return result;
    }
    
}

// MARK: UIView Extensions

extension UIView {
    
    func fadeIn(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.alpha = 1.0
            }, completion: completion)  }
    
    func fadeOut(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.alpha = 0.0
            }, completion: completion)
    }
    
    
    func captureImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 1)
        self.drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func createBlurForView(style: UIBlurEffectStyle) -> UIView  {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        
        let wrapperView = UIView(frame: blurEffectView.frame)
        wrapperView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        wrapperView.addSubview(blurEffectView)
        return wrapperView
    }
    
    /// When positive, the background of the layer will be drawn with rounded corners. Also effects the mask generated by the `masksToBounds' property. Defaults to zero. Animatable.
    @IBInspectable var cornerRadius: Double {
        get {
            return Double(self.layer.cornerRadius)
        }
        set {
            self.layer.cornerRadius = CGFloat(newValue)
        }
    }
    
    /// The width of the layer's border, inset from the layer bounds. The border is composited above the layer's content and sublayers and includes the effects of the `cornerRadius' property. Defaults to zero. Animatable.
    @IBInspectable var borderWidth: Double {
        get {
            return Double(self.layer.borderWidth)
        }
        set {
            self.layer.borderWidth = CGFloat(newValue)
        }
    }
    
    /// The color of the layer's border. Defaults to opaque black. Colors created from tiled patterns are supported. Animatable.
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(CGColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue?.CGColor
        }
    }
    
    /// The color of the shadow. Defaults to opaque black. Colors created from patterns are currently NOT supported. Animatable.
    @IBInspectable var shadowColor: UIColor? {
        get {
            return UIColor(CGColor: self.layer.shadowColor!)
        }
        set {
            self.layer.shadowColor = newValue?.CGColor
        }
    }
    
    /// The opacity of the shadow. Defaults to 0. Specifying a value outside the [0,1] range will give undefined results. Animatable.
    @IBInspectable var shadowOpacity: Float {
        get {
            return self.layer.shadowOpacity
        }
        set {
            self.layer.shadowOpacity = newValue
        }
    }
    
    /// The shadow offset. Defaults to (0, -3). Animatable.
    @IBInspectable var shadowOffset: CGSize {
        get {
            return self.layer.shadowOffset
        }
        set {
            self.layer.shadowOffset = newValue
        }
    }
    
    /// The blur radius used to create the shadow. Defaults to 3. Animatable.
    @IBInspectable var shadowRadius: Double {
        get {
            return Double(self.layer.shadowRadius)
        }
        set {
            self.layer.shadowRadius = CGFloat(newValue)
        }
    }
    
    func addDashedBorder(borderColor: UIColor, borderWidth: CGFloat, dashPattern: [NSNumber], cornerRadius: CGFloat) {
        
        
        let color = borderColor.CGColor
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.bounds.size
        //LOG.debug("bounds \(self.bounds) frame \(self.frame)")
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height-1)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = borderWidth
        shapeLayer.lineJoin = kCALineJoinMiter
        shapeLayer.lineDashPattern = dashPattern
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: cornerRadius).CGPath
        
        self.layer.addSublayer(shapeLayer)
        
    }
    
    
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
    
}

// MARK: UIViewController Extensions

extension UIViewController {
    
    func setTabBarVisible(visible:Bool, duration:NSTimeInterval, animated:Bool) {
        
        //* This cannot be called before viewDidLayoutSubviews(), because the frame is not set before this time
        
        // bail if the current state matches the desired state
        if (tabBarIsVisible() == visible) { return }
        
        // get a frame calculation ready
        let frame = self.tabBarController?.tabBar.frame
        let height = frame?.size.height
        let offsetY = (visible ? -height! : height)
        
        // zero duration means no animation
        let duration:NSTimeInterval = (animated ? 0.5 : 0.0)
        
        //  animate the tabBar
        if frame != nil {
            UIView.animateWithDuration(duration) {
                self.tabBarController?.tabBar.frame = CGRectOffset(frame!, 0, offsetY!)
                return
            }
        }
    }
    
    func tabBarIsVisible() -> Bool {
        return self.tabBarController?.tabBar.frame.origin.y < UIScreen.mainScreen().bounds.height
    }
}



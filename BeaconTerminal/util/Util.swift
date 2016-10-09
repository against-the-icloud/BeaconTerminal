import Foundation
import UIKit
import Material
import Alamofire
import CryptoSwift

enum ImageFormat: String {
    case png = ".png"
    case placeTerminal = "PLACE TERMINAL"
    case placeGroup = "PLACE GROUP"
    case objectGroup = "ARTIFACT GROUP"
    
    static let allValues = [placeTerminal, placeGroup, objectGroup]
}

class Util {
    
    
    
    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    class func randomString(_ length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString = ""
        
        for _ in 0 ..< length {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString += String(letters.character(at: Int(rand)))
        }
        
        return randomString
    }
    
    class func uploadFile(withURL fileData: Data, andFilename filename: String, completion: @escaping ((URL?) -> Void)) {
        
        // Add Headers
        let headers = ["Content-Type":"multipart/form-data; charset=utf-8; boundary=__X_PAW_BOUNDARY__"]
        
        let uploadUrl = "http://\(CURRENT_HOST):57882/upload"
        
        // Fetch Request
        
        //"d41d8cd98f00b204e9800998ecf8427e.jpg".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let md5filename = "\(filename.fileName().md5()).\(filename.fileExtension())"
        let encodedFilename = md5filename.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        //let encodedFile = fileData
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(encodedFilename, withName: "filename")
                multipartFormData.append(fileData, withName: "file")
            },
            to: uploadUrl,
            method: .post,
            headers: headers,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        LOG.debug("-----RESPONSE \(response)")
                    }
                case .failure(let encodingError):
                    LOG.debug("-----ERROR \(encodingError)")
                }
            }
        )
    }
    /**
     Upload file and return the URL which it can be found
     
     upload
     POST http://localhost:57882/upload
     
     - parameter file: The file to upload to nutella
     */
    class func uploadFile(withURL fileURL: URL, andFilename filename: String, completion: @escaping ((_ url:String?) -> Void)) {
        
        // Add Headers
        let headers = ["Content-Type":"multipart/form-data; charset=utf-8; boundary=__X_PAW_BOUNDARY__"]
        
        let uploadUrl = "http://\(CURRENT_HOST):57882/upload"
        
        // Fetch Request
        
        let url = URL(fileURLWithPath: filename)
        
        //"d41d8cd98f00b204e9800998ecf8427e.jpg".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let md5filename = "\(filename.fileName().md5()).\(filename.fileExtension())"
        let encodedFilename = md5filename.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        //let encodedFile = fileData
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(encodedFilename, withName: "filename")
                multipartFormData.append(fileURL, withName: "file")
            },
            to: uploadUrl,
            method: .post,
            headers: headers,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        //LOG.debug("-----RESPONSE \(response)")
                        if let data = response.data {
                            
                         let json = JSON(data: data)
                        if let found = json["url"].string {
                            completion(found)
                        }
                        }
                    }
                case .failure(let encodingError):
                     LOG.debug("-----ERROR \(encodingError)")
                }
            }
        )
    }
    
    class func makeToast(_ message: String) {
        if let presentWindow = UIApplication.shared.keyWindow {
            presentWindow.makeToast(message: message, duration: 3.0, position: HRToastPositionTop as AnyObject)
        }
    }
    
    class func makeToast(_ message: String, duration: Double = 3.0, position: AnyObject) {
        if let presentWindow = UIApplication.shared.keyWindow {
            presentWindow.makeToast(message: message, duration: duration, position: HRToastPositionTop as AnyObject)
        }
    }
    
    class func makeToast(_ message: String, title: String, duration: Double = 3.0, image: UIImage) {
        if let presentWindow = UIApplication.shared.keyWindow {
            presentWindow.makeToast(message: message, duration: duration,  position: HRToastPositionTop as AnyObject, title: title, image: image)
            
        }
    }
    
    static let flatBlack: UIColor = UIColor(red:0.10, green:0.10, blue:0.10, alpha:1.00)
    
    
    //    class func classNameAsString(_ obj: Any) -> String {
    //        return String(type(descring)).components(separatedBy: "__").last!
    //    }
    
    class func prepareTabBar(with item: UITabBarItem) {
        item.setTitleColor(color: Color.grey.base, forState: .normal)
        item.setTitleColor(color: Color.black, forState: .selected)
    }
    
    // MARK: Color
    class func isLightColor(_ color: UIColor) -> Bool {
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
    
    class func generateRandomPoint(_ maxXValue: UInt32, maxYValue: UInt32) -> CGPoint {
        let rand_x = CGFloat(arc4random_uniform(maxXValue)) // maxXValue is a variable with your maximum possible x value
        let rand_y = CGFloat(arc4random_uniform(maxYValue)) // maxYValue is a variable with your maximum possible y value
        return CGPoint(x: rand_x, y: rand_y)
        
    }
    
    class func generateRandomPoint(_ minXValue: UInt32, minYValue: UInt32, _ maxXValue: UInt32, maxYValue: UInt32) -> CGPoint {
        var rand_x = CGFloat(arc4random_uniform(maxXValue)) // maxXValue is a variable with your maximum possible x value
        
        if rand_x < CGFloat(minXValue) {
            rand_x = CGFloat(minXValue)
        }
        
        var rand_y = CGFloat(arc4random_uniform(maxYValue)) // maxYValue is a variable with your maximum possible y value
        
        
        if rand_y < CGFloat(minYValue) {
            rand_y = CGFloat(minYValue)
        }
        
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
    func resizeToSize(_ size: CGSize!) -> UIImage? {
        // Begins an image context with the specified size
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
        // Draws the input image (self) in the specified size
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        // Gets an UIImage from the image context
        let result = UIGraphicsGetImageFromCurrentImageContext()
        // Ends the image context
        UIGraphicsEndImageContext();
        // Returns the final image, or NULL on error
        return result;
    }
    
    // Crops an input image (self) to a specified rect
    func cropToRect(_ rect: CGRect!) -> UIImage? {
        // Correct rect size based on the device screen scale
        let scaledRect = CGRect(x: rect.origin.x * self.scale, y: rect.origin.y * self.scale, width: rect.size.width * self.scale, height: rect.size.height * self.scale);
        // New CGImage reference based on the input image (self) and the specified rect
        let imageRef = self.cgImage!.cropping(to: scaledRect);
        // Gets an UIImage from the CGImage
        let result = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        // Returns the final image, or NULL on error
        return result;
    }
    
}

// MARK: UIView Extensions

extension UIView {
    
    func fadeIn(toAlpha alpha: CGFloat = 1.0, duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = alpha
            }, completion: completion)  }
    
    func fadeIn(_ duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
            }, completion: completion)  }
    
    func fadeOut(_ duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion:  @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
            }, completion:(completion))
    }
    
    
    func captureImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 1)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func createBlurForView(_ style: UIBlurEffectStyle) -> UIView  {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        
        let wrapperView = UIView(frame: blurEffectView.frame)
        wrapperView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
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
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    
    /// The color of the shadow. Defaults to opaque black. Colors created from patterns are currently NOT supported. Animatable.
    @IBInspectable var shadowColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.shadowColor!)
        }
        set {
            self.layer.shadowColor = newValue?.cgColor
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
    
    func addDashedBorder(_ borderColor: UIColor, borderWidth: CGFloat, dashPattern: [NSNumber], cornerRadius: CGFloat) {
        
        
        let color = borderColor.cgColor
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.bounds.size
        //LOG.debug("bounds \(self.bounds) frame \(self.frame)")
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height-1)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = borderWidth
        shapeLayer.lineJoin = kCALineJoinMiter
        shapeLayer.lineDashPattern = dashPattern
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: cornerRadius).cgPath
        
        self.layer.addSublayer(shapeLayer)
        
    }
    
    class func loadFromNibNamed(_ nibNamed: String, bundle : Bundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
    

        
        func bindFrameToSuperviewBounds() {
            guard let superview = self.superview else {
                print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
                return
            }
            
            self.translatesAutoresizingMaskIntoConstraints = false
            superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
            superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
        }
 
    
}

// MARK: UIViewController Extensions

extension UIViewController {
    
    func setTabBarVisible(_ visible:Bool, duration:TimeInterval, animated:Bool) {
        
        //* This cannot be called before viewDidLayoutSubviews(), because the frame is not set before this time
        
        // bail if the current state matches the desired state
        if (tabBarIsVisible() == visible) { return }
        
        // get a frame calculation ready
        let frame = self.tabBarController?.tabBar.frame
        let height = frame?.size.height
        let offsetY = (visible ? -height! : height)
        
        // zero duration means no animation
        let duration:TimeInterval = (animated ? 0.5 : 0.0)
        
        //  animate the tabBar
        if frame != nil {
            UIView.animate(withDuration: duration) {
                self.tabBarController?.tabBar.frame = frame!.offsetBy(dx: 0, dy: offsetY!)
                return
            }
        }
    }
    
    func tabBarIsVisible() -> Bool {
        return (self.tabBarController?.tabBar.frame.origin.y)! < UIScreen.main.bounds.height
    }
}

extension UINavigationBar {
    
    func hideBottomHairline() {
        self.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.shadowImage = UIImage()
    }
    
}

extension UIToolbar {
    
    func hideHairline() {
        let navigationBarImageView = hairlineImageViewInToolbar(self)
        navigationBarImageView!.isHidden = true
    }
    
    func showHairline() {
        let navigationBarImageView = hairlineImageViewInToolbar(self)
        navigationBarImageView!.isHidden = false
    }
    
    private func hairlineImageViewInToolbar(_ view: UIView) -> UIImageView? {
        if view.isKind(of: UIImageView.self) && view.bounds.height <= 1.0 {
            return (view as! UIImageView)
        }
        
        let subviews = (view.subviews as [UIView])
        for subview: UIView in subviews {
            if let imageView: UIImageView = hairlineImageViewInToolbar(subview) {
                return imageView
            }
        }
        
        return nil
    }
    
}

extension UIImagePickerController {
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .landscape
        }
    }
    
    open override var shouldAutorotate: Bool {
        get {
            return false
        }
    }
}

extension String {
    
    func fileName() -> String {
        
        if let fileNameWithoutExtension = NSURL(fileURLWithPath: self).deletingPathExtension?.lastPathComponent {
            return fileNameWithoutExtension
        } else {
            return ""
        }
    }
    
    func fileExtension() -> String {
        
        if let fileExtension = NSURL(fileURLWithPath: self).pathExtension {
            return fileExtension
        } else {
            return ""
        }
    }

}



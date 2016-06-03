//
//  Utility.swift
//  DraggableView
//
//  Created by Anthony Perritano on 5/28/16.
//  Copyright © 2016 Mark Angelo Noquera. All rights reserved.
//

import Foundation
import UIKit

class Utility {

    class func classNameAsString(obj: Any) -> String {
        return String(obj.dynamicType).componentsSeparatedByString("__").last!
    }

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

}

//UIImage+ResizeAndCrop.swift

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

extension UIView {
    func captureImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 1)
        self.drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
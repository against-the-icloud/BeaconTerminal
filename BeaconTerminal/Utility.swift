//
//  Utility.swift
//  DraggableView
//
//  Created by Anthony Perritano on 5/28/16.
//  Copyright © 2016 Mark Angelo Noquera. All rights reserved.
//

import Foundation

class Utility {
    class func classNameAsString(obj: Any) -> String {
        return String(obj.dynamicType).componentsSeparatedByString("__").last!
    }
}
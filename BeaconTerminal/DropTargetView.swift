//
//  DropTargetView.swift
//  DraggableView
//
//  Created by Anthony Perritano on 5/28/16.
//  Copyright © 2016 Mark Angelo Noquera. All rights reserved.
//

import Foundation
import UIKit
import Material

class DropTargetView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        if CGRectContainsPoint(self.bounds, point) {
            return true
        }
        return super.pointInside(point, withEvent: event)
    }
    
    
    func highlight() {
        self.backgroundColor = MaterialColor.grey.lighten3
        self.borderColor = MaterialColor.blue.base
    }
    
    func unhighlight() {
        self.backgroundColor = UIColor.whiteColor()
        self.borderColor = UIColor.blackColor()
    }
}

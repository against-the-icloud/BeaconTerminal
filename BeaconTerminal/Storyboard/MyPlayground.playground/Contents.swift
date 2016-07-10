//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

var view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
view.backgroundColor = UIColor.redColor()
view.layer.borderColor = UIColor.whiteColor().CGColor
view.layer.borderWidth = 6.0

// path for the mask
let rectanglePath = UIBezierPath(roundedRect:view.bounds, cornerRadius: 20)
// applying the mask over the view
let maskLayer = CAShapeLayer()
maskLayer.frame = view.bounds
maskLayer.path = rectanglePath.CGPath
view.layer.mask = maskLayer
//
//  LoadingView.swift
//  LoadingAnimationSwift
//
//  Created by Adam Salvitti-Gucwa on 10/20/14.
//  Copyright (c) 2014 esgie. All rights reserved.
//

import Foundation
import QuartzCore
import UIKit

struct circleSize {
    var width :CGFloat = 6
    var height :CGFloat = 6
}

class LoadingView: UIImageView {
    
    var color = UIColor.lightGray
    var speed = 0.6
    var isAnimate:Bool?
    var opacityWasSet:Bool?
    var dotSize = circleSize()
    var spacing :CGFloat = 6
    var opacity :Float = 1
    var centerPT :CGPoint?
    
    var dotOne = CAShapeLayer()
    var dotTwo = CAShapeLayer()
    var dotThree = CAShapeLayer()
    var dots: Array<CAShapeLayer>?
    
    override func layoutSubviews() {
        self.frame = CGRect(x: (centerPT!.x - dotSize.width * 1.5) - spacing, y: (centerPT!.y - dotSize.height), width: dotSize.width * 3 + spacing * 2, height: dotSize.height)
    }
    
    func showAtCenterPointWithSize(_ centerPT:CGPoint, size:CGFloat)
    {
        self.dotSize.width = size
        self.dotSize.height = size
        self.spacing = (size * 1.25 - size) + 2.0
        self.centerPT = centerPT
        
        self.dots = [dotOne, dotTwo, dotThree]
        
        setupDotsFromArray(dots!)
    }
    
    func setupDotsFromArray(_ dotArray: [CAShapeLayer])
    {
        
        for dot in dotArray
        {
            if dot == dotOne {
                dot.frame = CGRect(x: 0, y: 0, width: dotSize.width, height: dotSize.height)
                
            } else if dot == dotTwo {
                dot.frame = CGRect(x: (dotSize.width + spacing), y: 0, width: dotSize.width, height: dotSize.height)
                
            } else {
                dot.frame = CGRect(x: (dotSize.width + spacing) * 2, y: 0, width: dotSize.width, height: dotSize.height)
                
            }
            dot.path = UIBezierPath(ovalIn:dot.bounds).cgPath
            dot.fillColor = color.cgColor
            dot.opacity = opacity
            self.layer.addSublayer(dot)
        }
    }
    
    func addStartingOpacity(_ opac:Float)
    {
        self.opacity = opac
        for dot in dots!
        {
            dot.opacity = opac
        }
        self.opacityWasSet = true
    }
    
    func hide()
    {
        self.isHidden = true
        self.stopAnimating()
    }
    
    func startLoading ()
    {
        self.isAnimate = true
        let dotOneBeg:CFTimeInterval = self.layer.convertTime(CACurrentMediaTime(), from:nil)
        let dotTwoBeg:CFTimeInterval = dotOneBeg + (speed/3)
        let dotThreeBeg:CFTimeInterval = dotOneBeg + ((speed/3) * 2)
        let timeArray = [dotOneBeg, dotTwoBeg, dotThreeBeg]
        
        for index in 0...(timeArray.count - 1)
        {
            let scaleAnimation = generateScaleAnimation()
            scaleAnimation.beginTime = timeArray[index]
            
            let opacAnimation = generateOpacityAnimation()
            opacAnimation.beginTime = timeArray[index]
            
            dots![index].add(scaleAnimation, forKey: "scale")
            if self.opacityWasSet == true {
                dots![index].add(opacAnimation, forKey: "opacity")
            }
            
        }
    }
    
    func stopLoading ()
    {
        self.isAnimate = false
        for dot in dots!
        {
            dot.removeAllAnimations()
        }
    }
    
    func generateScaleAnimation () -> CABasicAnimation
    {
        let scaleAni: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAni.fromValue = 1
        scaleAni.toValue = 1.22
        scaleAni.duration = speed
        scaleAni.isRemovedOnCompletion = false
        scaleAni.fillMode = kCAFillModeForwards
        scaleAni.repeatCount = Float.infinity
        scaleAni.autoreverses = true
        scaleAni.timingFunction = CAMediaTimingFunction(controlPoints: 0.5, 0, 0.5, 1)
        return scaleAni
    }
    
    func generateOpacityAnimation () -> CABasicAnimation
    {
        let opAni: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        opAni.fromValue = opacity
        opAni.toValue = 1
        opAni.duration = speed
        opAni.isRemovedOnCompletion = false
        opAni.fillMode = kCAFillModeForwards
        opAni.repeatCount = Float.infinity
        opAni.autoreverses = true
        opAni.timingFunction = CAMediaTimingFunction(controlPoints: 0.5, 0, 0.5, 1)
        return opAni
    }
}

//
//  DraggableImageView.swift
//  PrototypeGesture
//
//  Created by Anthony Perritano on 5/27/16.
//  Copyright © 2016 Mark Angelo Noquera. All rights reserved.
//

import Foundation
import UIKit

protocol DraggableViewDelegate {
    func onDroppedToTarget(sender: DraggableImageView)
    func isDragging(sender: DraggableImageView)
    func onDraggingStarted(sender: DraggableImageView)
    func onSnappedBack(sender: DraggableImageView)
    func onCopied(copiedSender: DraggableImageView)
    func enteringZone(sender: DraggableImageView, targets: [UIView])
    func exitingZone(sender: DraggableImageView, targets: [UIView])

}

protocol DropTargetProtocol {

}

// scenario 1: copy duplicate with snapback
class DraggableImageView: UIImageView {


    var delegate:DraggableViewDelegate?

    @IBInspectable var shouldCopy : Bool = true
    @IBInspectable var shouldSnapBack : Bool = true
    @IBInspectable var dragScaleFactor : CGFloat = 1.4
    @IBInspectable var dragAlpha : CGFloat = 1.0

    var currentView : DraggableImageView?
    var dropTarget : DropTargetView?

    var enteredZones = [UIView]()

    var startPoint : CGPoint?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initGestures(self)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initGestures(self)
    }

    func initGestures(view: UIView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(DraggableImageView.responseToPanGesture(_:)))
        view.userInteractionEnabled = true
        view.addGestureRecognizer(panGesture)
    }

    func getDropTarget(tag: Int) -> UIView? {
        let parentView = self.superview
        for sview in (parentView?.subviews)! {
            if !sview.hidden && sview.alpha > 0 {
                if sview.tag == tag {
                    return sview
                }
            }
        }
        return nil
    }
    



    func responseToPanGesture(sender: UIPanGestureRecognizer){

        if sender.state == UIGestureRecognizerState.Began {


            if self.shouldCopy {
                self.currentView = DraggableImageView(frame: self.frame)
                self.currentView!.userInteractionEnabled = true
                self.currentView!.autoresizingMask = UIViewAutoresizing.None
                self.currentView!.contentMode = UIViewContentMode.Center
                self.currentView!.layer.cornerRadius = 10.0
                self.currentView!.layer.borderWidth = 0.0
                self.currentView!.tintColor = UIColor.blueColor()
                self.currentView!.delegate = self.delegate
                self.currentView!.tag = self.tag
                
                self.currentView!.clipsToBounds = true
                self.currentView!.addSubview(UIImageView(image: scaledImageToSize(self.image!, newSize: self.bounds.size)))

                self.superview?.insertSubview(self.currentView!, atIndex: 0)
                self.startPoint = self.currentView?.center

                self.animateView(self.currentView!, scale: self.dragScaleFactor, alpha: self.dragAlpha, duration: 0.3)
            } else {


                self.currentView = sender.view as? DraggableImageView
//                if let startPoint = self.startPoint {
//                    self.currentView?.center =  startPoint
//                }
                self.animateView(self.currentView!, scale: self.dragScaleFactor, alpha: self.dragAlpha, duration: 0.3)
            }


           // LOG.debug("DROP START \(currentView!.tag)")

            self.superview?.bringSubviewToFront(self.currentView!)

            UIApplication.sharedApplication().keyWindow!.bringSubviewToFront(self.currentView!)

        } else if sender.state == UIGestureRecognizerState.Changed {

            //LOG.debug("DRAG TAG \(currentView!.tag)")

            let translation = sender.translationInView(currentView!.superview)
            self.currentView!.center = CGPointMake(self.currentView!.center.x + translation.x, currentView!.center.y + translation.y)
            sender.setTranslation(CGPointZero, inView: currentView!.superview)

            self.superview?.bringSubviewToFront(self.currentView!)
            UIApplication.sharedApplication().keyWindow!.bringSubviewToFront(self.currentView!)

            pointInside(sender)


            self.delegate?.isDragging(self.currentView!)


//            LOG.debug("CENTER DRAGGED \(self.currentView!)")

        } else if sender.state == UIGestureRecognizerState.Ended{


            self.superview?.bringSubviewToFront(self.currentView!)

//            LOG.debug("is in the Zone: \(pointInside(sender))")

            //LOG.debug("DROP TAG \(currentView!.tag)")


            if (shouldCopy == true) || (shouldCopy == false && shouldSnapBack == true) {


                if pointInside(sender) == false  {
                    //if we are NOT nside dropzone
                    //snapback and remove
                    //LOG.debug("WE ARE NOT COPYING NOT INSIDE")
                    UIView.animateWithDuration(0.4, animations: {

                        if let startPoint = self.startPoint {
                            self.currentView?.center = startPoint
                        }

                        self.currentView?.transform = CGAffineTransformMakeScale(1.0, 1.0)
                        self.currentView?.alpha = 1.0
                    }, completion: {
                        (finished:Bool) in
                        //print("finished: \(finished) NOT COPY")
                        
                        self.currentView?.removeFromSuperview()
                    })

                } else {
                    //LOG.debug("SUCCESS COPY")
                    //SUCCESS COPY END
                    //TURN OFF COPY leave SNAPBACK TO ORIGNAL POSITON
                    self.currentView?.shouldCopy = false
                    self.currentView?.shouldSnapBack = true
                    if let startPoint = self.startPoint {
                        self.currentView?.startPoint = startPoint
                    }
                    //move ended
                    UIView.animateWithDuration(0.4, animations: {
                        self.currentView?.transform = CGAffineTransformMakeScale(1.0, 1.0)
                        self.currentView?.alpha = 1.0
                    }, completion: {
                        (finished:Bool) in
                        self.updateDelegates()
                    })
                }
            } else {
                //SUCCESS MOVE
                UIView.animateWithDuration(0.4, animations: {
                    self.currentView?.transform = CGAffineTransformMakeScale(1.0, 1.0)
                    self.currentView?.alpha = 1.0
                    self.currentView?.borderColor = UIColor.clearColor()
                }, completion: {
                    (finished:Bool) in
                    self.updateDelegates()
                })

            }

        }
    }


    func pointInside(sender:UIGestureRecognizer) -> Bool {

        let parentView = self.window

        let p:CGPoint = sender.locationInView(parentView)
        if let hitTestView = self.window!.hitTest(p, withEvent: nil) {
            if ((hitTestView as? DropTargetView) != nil) {
                if(CGRectIntersectsRect(hitTestView.frame, self.currentView!.frame) || CGRectContainsPoint(hitTestView.frame,p)){
                    if enteredZones.contains(hitTestView) {
                    } else {
                        enteredZones.append(hitTestView)
                    }
                    delegate?.enteringZone(self.currentView!, targets: enteredZones)
                    return true
                }
            } else {

                //LOG.debug("NOT IN ZONE COUNT \(enteredZones.count) POINT \(p)")
                if !self.enteredZones.isEmpty {
                    //LOG.debug("EXTING ZONE ---- ZONE ARRAY ENTER \(self.enteredZones.count)")
                    delegate?.exitingZone(self.currentView!, targets: enteredZones)
                    enteredZones.removeAll()
                }

                return false
            }
        } else {
            //nothing
            LOG.debug("NOT A HIT")
        }


        return false
    }
    
    func updateDelegates() {

        for zone in enteredZones {
            //current the point to the target view
            //LOG.debug("CV \(self.currentView!.frame)")
            let newPoint = self.superview!.convertPoint(self.currentView!.center, toView: zone)
            zone.addSubview(self.currentView!)
            zone.bringSubviewToFront(self.currentView!)
            self.currentView!.center =  newPoint
        }

        enteredZones.removeAll()
        self.delegate!.onDroppedToTarget(self.currentView!)
    }

    private func scaledImageToSize(image: UIImage, newSize: CGSize) -> UIImage{
        UIGraphicsBeginImageContext(newSize)
        image.drawInRect(CGRectMake(0 ,0, newSize.width, newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        return newImage
    }
    private func animateView(view:UIView, scale:CGFloat = 1.3, alpha:CGFloat = 0.5,duration:NSTimeInterval = 0.2){
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(duration)
        view.transform = CGAffineTransformMakeScale(scale, scale)
        view.alpha = alpha
        UIView.commitAnimations()
    }
}
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
    @IBInspectable var shouldWindow : Bool = false
    @IBInspectable var shouldClipBounds : Bool = true
    @IBInspectable var dragScaleFactor : CGFloat = 1.4
    @IBInspectable var dragAlpha : CGFloat = 1.0
    

    var currentView : DraggableImageView?
    var dropTarget : DropTargetView?
    var shouldDropOnCell = false

    var enteredZones = [UIView]()

    var startPoint : CGPoint?
    var overlay : UIView?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initGestures(self)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initGestures(self)
    }

    func initGestures(view: UIView) {
        
        self.backgroundColor = UIColor.lightGrayColor()
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
                self.userInteractionEnabled = false 
                self.currentView = DraggableImageView(frame: self.frame)
                self.currentView!.userInteractionEnabled = true
                self.currentView!.autoresizingMask = UIViewAutoresizing.None
                self.currentView!.contentMode = UIViewContentMode.Center
                self.currentView!.layer.cornerRadius = 10.0
                self.currentView!.layer.borderWidth = 0.0
                self.currentView!.tintColor = UIColor.blueColor()
                self.currentView!.delegate = self.delegate
                self.currentView!.tag = self.tag
                self.currentView?.shouldDropOnCell = self.shouldDropOnCell
                
                self.currentView!.clipsToBounds = true
                self.currentView!.addSubview(UIImageView(image: DragUtil.scaledImageToSize(self.image!, newSize: self.bounds.size)))

                
                //let rootViewPoint = self.currentView!.convertPoint(self.currentView!.center, toView: overlay)
                self.superview?.insertSubview(self.currentView!, atIndex: 0)
                
              

                self.startPoint = self.currentView?.center


            } else {


                self.currentView = sender.view as? DraggableImageView
                self.startPoint = self.currentView?.center

//                if let startPoint = self.startPoint {
//                    self.currentView?.center =  startPoint
//                }
               
            }

             DragUtil.animateView(self.currentView!, scale: self.dragScaleFactor, alpha: self.dragAlpha, duration: 0.3)

           // LOG.debug("DROP START \(currentView!.tag)")

            self.superview?.bringSubviewToFront(self.currentView!)

            UIApplication.sharedApplication().keyWindow!.bringSubviewToFront(self.currentView!)
            
        } else if sender.state == .Cancelled {
            

        } else if sender.state == UIGestureRecognizerState.Changed {

        

            let translation = sender.translationInView(currentView!.superview)
            self.currentView!.center = CGPointMake(self.currentView!.center.x + translation.x, currentView!.center.y + translation.y)
            sender.setTranslation(CGPointZero, inView: currentView!.superview)
            
//            let draggingPoint = sender.locationInView(currentView!)
//            LOG.debug("dragging Point \(draggingPoint)")
//            let hitView = currentView!.hitTest(draggingPoint, withEvent: nil)
//            LOG.debug("hitview \(hitView)")
//
//            if hitView!.superview == currentView! {
//                hitView!.center = draggingPoint
//                LOG.debug("hit view FOUND \(hitView)")
//            }
//            

            //LOG.debug("DRAGGING  \(currentView!.center)")
            
            //check if it is getting clipped
            if shouldClipBounds {
                if (!CGRectEqualToRect(CGRectIntersection(self.currentView!.superview!.bounds, self.currentView!.frame), self.currentView!.frame))
                {
                    //view is partially out of bounds
                    LOG.debug("CLIPPPED")
                    
                    UIView.animateWithDuration(0.4, animations: {
                        
                        if let startPoint = self.startPoint {
                            self.currentView?.center = startPoint
                        }
                        
                        self.currentView?.transform = CGAffineTransformMakeScale(1.0, 1.0)
                        self.currentView?.alpha = 1.0
                        }, completion: {
                            (finished:Bool) in
                            //print("finished: \(finished) NOT COPY")
                            
                            //self.currentView?.removeFromSuperview()
                    })
                    
                    //snap back
                    
                }
            }
            
            //self.superview?.bringSubviewToFront(self.currentView!)
            UIApplication.sharedApplication().keyWindow!.bringSubviewToFront(self.currentView!)

            //pointInside(sender)


            self.delegate?.isDragging(self.currentView!)


//            LOG.debug("CENTER DRAGGED \(self.currentView!)")

        } else if sender.state == UIGestureRecognizerState.Ended{


            self.superview?.bringSubviewToFront(self.currentView!)

//            LOG.debug("is in the Zone: \(pointInside(sender))")

            //LOG.debug("DROP TAG \(currentView!.tag)")

            LOG.debug("\(currentView!.subviews)")

            if (shouldCopy == true) || (shouldCopy == false && shouldSnapBack == true) {


                if pointInside(sender) == false  {
                    //if we are NOT inside dropzone
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

        if self.shouldDropOnCell {
        
    
           
            let pc:CGPoint = sender.locationInView(self.currentView!)
            let parentView = UIApplication.sharedApplication().keyWindow!
            let p:CGPoint = sender.locationInView(parentView)
            
            let pointInCollection = CGPointMake(p.x + getAppDelegate().collectionView!.contentOffset.x, p.y + getAppDelegate().collectionView!.contentOffset.y);

            
            let path = getAppDelegate().collectionView!.indexPathForItemAtPoint(pointInCollection)
            let cell = getAppDelegate().collectionView!.cellForItemAtIndexPath(path!) as! CoverFlowCell
            for relationshipView in cell.relationshipViews {
                
                if (CGRectContainsPoint(relationshipView.dropView.bounds, pointInCollection))
                {
                    LOG.debug("FOUND")
                }
                
            }
            
            
            let found = pointInside(currentView!.center , withEvent: nil)
            
            LOG.debug("found \(found)")

        } else {
            let parentView = UIApplication.sharedApplication().keyWindow!
            
            let p:CGPoint = sender.locationInView(parentView)
            
            let found = pointInside(currentView!.center , withEvent: nil)
            
            LOG.debug("found \(found)")
            
            if let hitTestView = parentView.hitTest(p, withEvent: nil) {
                
                //LOG.debug("HIT TEST: \(hitTestView)")
                
                
                let newHit = hitTestView.hitTest(p, withEvent: nil)
                
                
                //LOG.debug("\(hitTestView) HIT NW TEST: \(newHit)")
                
                
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
            
        }
        return false
    }
    
    
    func pointInsideWindow(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return ((subviewAtPoint(point, view: UIApplication.sharedApplication().keyWindow!) as? DropTargetView) != nil)
    }
    
    private func subviewAtPoint(point: CGPoint, view: UIView) -> UIView? {
        for subview in view.subviews {
            let view = subview.hitTest(point, withEvent: nil)
            if view != nil {
                return view
            }
        }
        return nil
    }
    
    
    func updateDelegates() {

        if self.delegate != nil {
            for zone in enteredZones {
                //convert the point to the target view
                //LOG.debug("CV \(self.currentView!.frame)")
                let newPoint = self.superview!.convertPoint(self.currentView!.center, toView: zone)
                zone.addSubview(self.currentView!)
                zone.bringSubviewToFront(self.currentView!)
                self.currentView!.center =  newPoint
            }
            
            enteredZones.removeAll()
            self.delegate!.onDroppedToTarget(self.currentView!)
        }

    }
}
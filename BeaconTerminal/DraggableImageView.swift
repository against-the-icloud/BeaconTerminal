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
    func onDroppedToTarget(_ sender: DraggableImageView)
    func isDragging(_ sender: DraggableImageView)
    func onDraggingStarted(_ sender: DraggableImageView)
    func onSnappedBack(_ sender: DraggableImageView)
    func onCopied(_ copiedSender: DraggableImageView)
    func enteringZone(_ sender: DraggableImageView, targets: [UIView])
    func exitingZone(_ sender: DraggableImageView, targets: [UIView])

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

    func initGestures(_ view: UIView) {
        
        self.backgroundColor = UIColor.lightGray()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(DraggableImageView.responseToPanGesture(_:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(panGesture)
        
        
     
        
    }

    func getDropTarget(_ tag: Int) -> UIView? {
        let parentView = self.superview
        for sview in (parentView?.subviews)! {
            if !sview.isHidden && sview.alpha > 0 {
                if sview.tag == tag {
                    return sview
                }
            }
        }
        return nil
    }
    



    func responseToPanGesture(_ sender: UIPanGestureRecognizer){

        if sender.state == UIGestureRecognizerState.began {


            if self.shouldCopy {
                self.isUserInteractionEnabled = false 
                self.currentView = DraggableImageView(frame: self.frame)
                self.currentView!.isUserInteractionEnabled = true
                self.currentView!.autoresizingMask = UIViewAutoresizing()
                self.currentView!.contentMode = UIViewContentMode.center
                self.currentView!.layer.cornerRadius = 10.0
                self.currentView!.layer.borderWidth = 0.0
                self.currentView!.tintColor = UIColor.blue()
                self.currentView!.delegate = self.delegate
                self.currentView!.tag = self.tag
                self.currentView?.shouldDropOnCell = self.shouldDropOnCell
                
                self.currentView!.clipsToBounds = true
                self.currentView!.addSubview(UIImageView(image: DragUtil.scaledImageToSize(self.image!, newSize: self.bounds.size)))

                
                //let rootViewPoint = self.currentView!.convertPoint(self.currentView!.center, toView: overlay)
                self.superview?.insertSubview(self.currentView!, at: 0)
                
              

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

            self.superview?.bringSubview(toFront: self.currentView!)

            UIApplication.shared().keyWindow!.bringSubview(toFront: self.currentView!)
            
        } else if sender.state == .cancelled {
            

        } else if sender.state == UIGestureRecognizerState.changed {

        

            let translation = sender.translation(in: currentView!.superview)
            self.currentView!.center = CGPoint(x: self.currentView!.center.x + translation.x, y: currentView!.center.y + translation.y)
            sender.setTranslation(CGPoint.zero, in: currentView!.superview)
            
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
                if (!self.currentView!.superview!.bounds.intersection(self.currentView!.frame).equalTo(self.currentView!.frame))
                {
                    //view is partially out of bounds
                    LOG.debug("CLIPPPED")
                    
                    UIView.animate(withDuration: 0.4, animations: {
                        
                        if let startPoint = self.startPoint {
                            self.currentView?.center = startPoint
                        }
                        
                        self.currentView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
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
            UIApplication.shared().keyWindow!.bringSubview(toFront: self.currentView!)

            //pointInside(sender)


            self.delegate?.isDragging(self.currentView!)


//            LOG.debug("CENTER DRAGGED \(self.currentView!)")

        } else if sender.state == UIGestureRecognizerState.ended{


            self.superview?.bringSubview(toFront: self.currentView!)

//            LOG.debug("is in the Zone: \(pointInside(sender))")

            //LOG.debug("DROP TAG \(currentView!.tag)")

            LOG.debug("\(currentView!.subviews)")

            if (shouldCopy == true) || (shouldCopy == false && shouldSnapBack == true) {


                if pointInside(sender) == false  {
                    //if we are NOT inside dropzone
                    //snapback and remove
                    //LOG.debug("WE ARE NOT COPYING NOT INSIDE")
                    UIView.animate(withDuration: 0.4, animations: {

                        if let startPoint = self.startPoint {
                            self.currentView?.center = startPoint
                        }

                        self.currentView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
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
                    UIView.animate(withDuration: 0.4, animations: {
                        self.currentView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        self.currentView?.alpha = 1.0
                    }, completion: {
                        (finished:Bool) in
                        self.updateDelegates()
                    })
                }
            } else {
                //SUCCESS MOVE
                UIView.animate(withDuration: 0.4, animations: {
                    self.currentView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    self.currentView?.alpha = 1.0
                    self.currentView?.borderColor = UIColor.clear()
                }, completion: {
                    (finished:Bool) in
                    self.updateDelegates()
                })

            }

        }
    }


    func pointInside(_ sender:UIGestureRecognizer) -> Bool {

        if self.shouldDropOnCell {
        
            
            //let pc:CGPoint = sender.locationInView(self.currentView!)
            let parentView = UIApplication.shared().keyWindow!
            let p:CGPoint = sender.location(in: parentView)
            
            let pointInCollection = CGPoint(x: p.x + getAppDelegate().collectionView!.contentOffset.x, y: p.y + getAppDelegate().collectionView!.contentOffset.y);

            
            let path = getAppDelegate().collectionView!.indexPathForItem(at: pointInCollection)
            let cell = getAppDelegate().collectionView!.cellForItem(at: path!) as! CoverFlowCell
            for relationshipView in cell.relationshipViews {
                
                if (relationshipView.dropView.bounds.contains(pointInCollection))
                {
                    LOG.debug("FOUND")
                }
                
            }
            
            
            let found = point(inside: currentView!.center , with: nil)
            
            LOG.debug("found \(found)")

        } else {
            let parentView = UIApplication.shared().keyWindow!
            
            let p:CGPoint = sender.location(in: parentView)
            
            let found = point(inside: currentView!.center , with: nil)
            
            LOG.debug("found \(found)")
            
            if let hitTestView = parentView.hitTest(p, with: nil) {
                
                //LOG.debug("HIT TEST: \(hitTestView)")
                
                
                _ = hitTestView.hitTest(p, with: nil)
                
                
                //LOG.debug("\(hitTestView) HIT NW TEST: \(newHit)")
                
                
                if ((hitTestView as? DropTargetView) != nil) {
                    if(hitTestView.frame.intersects(self.currentView!.frame) || hitTestView.frame.contains(p)){
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
    
    
    func pointInsideWindow(_ point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return ((subviewAtPoint(point, view: UIApplication.shared().keyWindow!) as? DropTargetView) != nil)
    }
    
    private func subviewAtPoint(_ point: CGPoint, view: UIView) -> UIView? {
        for subview in view.subviews {
            let view = subview.hitTest(point, with: nil)
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
                let newPoint = self.superview!.convert(self.currentView!.center, to: zone)
                zone.addSubview(self.currentView!)
                zone.bringSubview(toFront: self.currentView!)
                self.currentView!.center =  newPoint
            }
            
            enteredZones.removeAll()
            self.delegate!.onDroppedToTarget(self.currentView!)
        }

    }
}

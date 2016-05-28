/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The primary view controller that hosts a `CanvasView` for the user to interact with.
 */

import UIKit
import Material
import MaterialDesignSymbol

class ScratchPadViewController: UIViewController {
    // MARK: Properties
    @IBOutlet weak var canvasView: CanvasView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareTabBarItem()
    }
    
//    var visualizeAzimuth = false
//    
//    let reticleView: ReticleView = {
//        let view = ReticleView(frame: CGRect.null)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.hidden = true
//        
//        return view
//    }()
//    
////    var canvasView: CanvasView {
////        return con as! CanvasView
////    }
//    
//    // MARK: View Life Cycle
    private func prepareTabBarItem() {
        tabBarItem.title = "Scratch Pad"
        var symbol:MaterialDesignSymbol = MaterialDesignSymbol(text:MaterialDesignIcon.modeEdit24px, size:25)
        //symbol.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor())
        var iconImage:UIImage = symbol.imageWithSize(CGSizeMake(25, 25))

        tabBarItem.image = iconImage
        tabBarItem.setTitleColor(MaterialColor.grey.base, forState: .Normal)
        tabBarItem.setTitleColor(MaterialColor.white, forState: .Selected)
    }

//    override func viewDidLoad() {
//        canvasView.addSubview(reticleView)
//
//        var halfSizeOfView = 25.0
//        //        let maxViews = 25
//        _ = CGRectInset(self.view.bounds, CGFloat(Int(2 * halfSizeOfView)), CGFloat(Int(2 * halfSizeOfView))).size
//        //
//        //        // Add the Views
//        for i in 0..<9 {
//            
//            let imageName = "species_0\(i).png"
//            let image = UIImage(named: imageName)
//            let imageView = MyImageView(image: image!)
//            
//            
//            
//            _ = CGFloat(UInt(arc4random() % UInt32(UInt(25))))
//            _ = CGFloat(UInt(arc4random() % UInt32(UInt(25))))
//            
//            imageView.contentMode = UIViewContentMode.ScaleAspectFit
//            
//            halfSizeOfView += 100
//            
//            imageView.frame = CGRectMake(CGFloat(halfSizeOfView), 100, 100, 100)
//            
//            
//            
//            
//            
//            self.view.addSubview(imageView)
//        }
//    }
//    
//    // MARK: Touch Handling
//    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        canvasView.drawTouches(touches, withEvent: event)
//        
//        if visualizeAzimuth {
//            for touch in touches {
//                if touch.type == .Stylus {
//                    reticleView.hidden = false
//                    updateReticleViewWithTouch(touch, event: event)
//                }
//            }
//        }
//    }
//    
//    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        canvasView.drawTouches(touches, withEvent: event)
//        
//        if visualizeAzimuth {
//            for touch in touches {
//                if touch.type == .Stylus {
//                    updateReticleViewWithTouch(touch, event: event)
//                    
//                    // Use the last predicted touch to update the reticle.
//                    guard let predictedTouch = event?.predictedTouchesForTouch(touch)?.last else { return }
//                    
//                    updateReticleViewWithTouch(predictedTouch, event: event, isPredicted: true)
//                }
//            }
//        }
//    }
//    
//    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        canvasView.drawTouches(touches, withEvent: event)
//        canvasView.endTouches(touches, cancel: false)
//        
//        if visualizeAzimuth {
//            for touch in touches {
//                if touch.type == .Stylus {
//                    reticleView.hidden = true
//                }
//            }
//        }
//    }
//    
//    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
//        guard let touches = touches else { return }
//        canvasView.endTouches(touches, cancel: true)
//        
//        if visualizeAzimuth {
//            for touch in touches {
//                if touch.type == .Stylus {
//                    reticleView.hidden = true
//                }
//            }
//        }
//    }
//    
//    override func touchesEstimatedPropertiesUpdated(touches: Set<NSObject>) {
//        canvasView.updateEstimatedPropertiesForTouches(touches)
//    }
//    
//    // MARK: Actions
//    
//    @IBAction func clearView(sender: UIBarButtonItem) {
//        canvasView.clear()
//    }
//    
//    @IBAction func toggleDebugDrawing(sender: UIButton) {
//        canvasView.isDebuggingEnabled = !canvasView.isDebuggingEnabled
//        visualizeAzimuth = !visualizeAzimuth
//        sender.selected = canvasView.isDebuggingEnabled
//    }
//    
//    @IBAction func toggleUsePreciseLocations(sender: UIButton) {
//        canvasView.usePreciseLocations = !canvasView.usePreciseLocations
//        sender.selected = canvasView.usePreciseLocations
//    }
//    
//    // MARK: Rotation
//    
//    override func shouldAutorotate() -> Bool {
//        return true
//    }
//    
//    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//        return [.LandscapeLeft, .LandscapeRight]
//    }
//    
//    // MARK: Convenience
//    
//    func updateReticleViewWithTouch(touch: UITouch?, event: UIEvent?, isPredicted: Bool = false) {
//        guard let touch = touch where touch.type == .Stylus else { return }
//        
//        reticleView.predictedDotLayer.hidden = !isPredicted
//        reticleView.predictedLineLayer.hidden = !isPredicted
//        
//        let azimuthAngle = touch.azimuthAngleInView(view)
//        let azimuthUnitVector = touch.azimuthUnitVectorInView(view)
//        let altitudeAngle = touch.altitudeAngle
//        
//        if isPredicted {
//            reticleView.predictedAzimuthAngle = azimuthAngle
//            reticleView.predictedAzimuthUnitVector = azimuthUnitVector
//            reticleView.predictedAltitudeAngle = altitudeAngle
//        }
//        else {
//            let location = touch.preciseLocationInView(view)
//            reticleView.center = location
//            reticleView.actualAzimuthAngle = azimuthAngle
//            reticleView.actualAzimuthUnitVector = azimuthUnitVector
//            reticleView.actualAltitudeAngle = altitudeAngle
//        }
//    }
}

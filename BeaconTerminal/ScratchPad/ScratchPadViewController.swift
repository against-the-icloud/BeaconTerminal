/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The primary view controller that hosts a `drawingCanvasView` for the user to interact with.
 */

import UIKit
import Material
import MaterialDesignSymbol

class ScratchPadViewController: UIViewController {
    
    
    @IBOutlet weak var drawingCanvasView: CanvasView!
    
    @IBOutlet var draggableImageViews: [DraggableImageView]!
    
    // MARK: Properties
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareTabBarItem()
    }
    
    var visualizeAzimuth = false
    
    let reticleView: ReticleView = {
        let view = ReticleView(frame: CGRect.null)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidden = true
        
        return view
    }()
//
////    var drawingCanvasView: drawingCanvasView {
////        return con as! drawingCanvasView
////    }
//    
//    // MARK: View Life Cycle
    private func prepareTabBarItem() {
        tabBarItem.title = "Scratch Pad"
        let symbol:MaterialDesignSymbol = MaterialDesignSymbol(text:MaterialDesignIcon.modeEdit24px, size:25)
        let iconImage:UIImage = symbol.imageWithSize(CGSizeMake(25, 25))

        tabBarItem.image = iconImage
        tabBarItem.setTitleColor(MaterialColor.grey.base, forState: .Normal)
        tabBarItem.setTitleColor(MaterialColor.white, forState: .Selected)
    }

    override func viewDidLoad() {
        drawingCanvasView.addSubview(reticleView)
        
        for dview in draggableImageViews {
            dview.delegate = self
        }
    }
    
    // MARK: Touch Handling
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        drawingCanvasView.drawTouches(touches, withEvent: event)
        
        if visualizeAzimuth {
            for touch in touches {
                if touch.type == .Stylus {
                    reticleView.hidden = false
                    updateReticleViewWithTouch(touch, event: event)
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        drawingCanvasView.drawTouches(touches, withEvent: event)
        
        if visualizeAzimuth {
            for touch in touches {
                if touch.type == .Stylus {
                    updateReticleViewWithTouch(touch, event: event)
                    
                    // Use the last predicted touch to update the reticle.
                    guard let predictedTouch = event?.predictedTouchesForTouch(touch)?.last else { return }
                    
                    updateReticleViewWithTouch(predictedTouch, event: event, isPredicted: true)
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        drawingCanvasView.drawTouches(touches, withEvent: event)
        drawingCanvasView.endTouches(touches, cancel: false)
        
        if visualizeAzimuth {
            for touch in touches {
                if touch.type == .Stylus {
                    reticleView.hidden = true
                }
            }
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        guard let touches = touches else { return }
        drawingCanvasView.endTouches(touches, cancel: true)
        
        if visualizeAzimuth {
            for touch in touches {
                if touch.type == .Stylus {
                    reticleView.hidden = true
                }
            }
        }
    }
    
    override func touchesEstimatedPropertiesUpdated(touches: Set<NSObject>) {
        drawingCanvasView.updateEstimatedPropertiesForTouches(touches)
    }
    
    // MARK: Actions
    
    @IBAction func clearView(sender: UIBarButtonItem) {
        drawingCanvasView.clear()
    }
    
    @IBAction func toggleDebugDrawing(sender: UIButton) {
        drawingCanvasView.isDebuggingEnabled = !drawingCanvasView.isDebuggingEnabled
        visualizeAzimuth = !visualizeAzimuth
        sender.selected = drawingCanvasView.isDebuggingEnabled
    }
    
    @IBAction func toggleUsePreciseLocations(sender: UIButton) {
        drawingCanvasView.usePreciseLocations = !drawingCanvasView.usePreciseLocations
        sender.selected = drawingCanvasView.usePreciseLocations
    }
    
    // MARK: Rotation
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.LandscapeLeft, .LandscapeRight]
    }
    
    // MARK: Convenience
    
    func updateReticleViewWithTouch(touch: UITouch?, event: UIEvent?, isPredicted: Bool = false) {
        guard let touch = touch where touch.type == .Stylus else { return }
        
        reticleView.predictedDotLayer.hidden = !isPredicted
        reticleView.predictedLineLayer.hidden = !isPredicted
        
        let azimuthAngle = touch.azimuthAngleInView(view)
        let azimuthUnitVector = touch.azimuthUnitVectorInView(view)
        let altitudeAngle = touch.altitudeAngle
        
        if isPredicted {
            reticleView.predictedAzimuthAngle = azimuthAngle
            reticleView.predictedAzimuthUnitVector = azimuthUnitVector
            reticleView.predictedAltitudeAngle = altitudeAngle
        }
        else {
            let location = touch.preciseLocationInView(view)
            reticleView.center = location
            reticleView.actualAzimuthAngle = azimuthAngle
            reticleView.actualAzimuthUnitVector = azimuthUnitVector
            reticleView.actualAltitudeAngle = altitudeAngle
        }
    }
}

extension ScratchPadViewController: DraggableViewDelegate {
    
    func onDroppedToTarget(sender: DraggableImageView, targets: [UIView]) {
        LOG.debug("\(sender) \(targets)")
        
        sender.borderColor = UIColor.clearColor()
    }
    
    func enteringZone(sender: DraggableImageView, targets: [UIView]) {
        
                if !targets.isEmpty {
            for zone in targets {
                zone.backgroundColor = UIColor.brownColor()
            }
        }
    }
    
    func exitingZone(sender: DraggableImageView, targets: [UIView]) {
        
        self.drawingCanvasView.backgroundColor = UIColor ( red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0 )

        if !targets.isEmpty {
            for zone in targets {
                zone.backgroundColor = UIColor.brownColor()
            }
        }
    }
}


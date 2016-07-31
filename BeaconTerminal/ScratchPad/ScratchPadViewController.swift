/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The primary view controller that hosts a `drawingCanvasView` for the user to interact with.
 */

import UIKit
import Material

class ScratchPadViewController: UIViewController {
    
    
    @IBOutlet weak var drawingCanvasView: CanvasView!
    
    @IBOutlet weak var toolbarView: UIView!
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
        view.isHidden = true
        
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
        let iconImage = UIImage(named: "ic_mode_edit_white")!
        
        
        tabBarItem.image = iconImage
        tabBarItem.setTitleColor(color: Color.grey.base, forState: .normal)
        tabBarItem.setTitleColor(color: Color.white, forState: .selected)

    }

    override func viewDidLoad() {
        drawingCanvasView.addSubview(reticleView)
        
        for dview in draggableImageViews {
            dview.delegate = self
        }
        
        self.view.sendSubview(toBack: drawingCanvasView)
       // self.view.bringSubview(toFront: toolbarView)
    }
    
    // MARK: Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        drawingCanvasView.drawTouches(touches, withEvent: event)
        
        if visualizeAzimuth {
            for touch in touches {
                if touch.type == .stylus {
                    reticleView.isHidden = false
                    updateReticleViewWithTouch(touch, event: event)
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        drawingCanvasView.drawTouches(touches, withEvent: event)
        
        if visualizeAzimuth {
            for touch in touches {
                if touch.type == .stylus {
                    updateReticleViewWithTouch(touch, event: event)
                    
                    // Use the last predicted touch to update the reticle.
                    guard let predictedTouch = event?.predictedTouches(for: touch)?.last else { return }
                    
                    updateReticleViewWithTouch(predictedTouch, event: event, isPredicted: true)
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        drawingCanvasView.drawTouches(touches, withEvent: event)
        drawingCanvasView.endTouches(touches, cancel: false)
        
        if visualizeAzimuth {
            for touch in touches {
                if touch.type == .stylus {
                    reticleView.isHidden = true
                }
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        guard let touches = touches else { return }
        drawingCanvasView.endTouches(touches, cancel: true)
        
        if visualizeAzimuth {
            for touch in touches {
                if touch.type == .stylus {
                    reticleView.isHidden = true
                }
            }
        }
    }
    
    override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        drawingCanvasView.updateEstimatedPropertiesForTouches(touches)
    }
    
    // MARK: Actions
    
    @IBAction func clearView(_ sender: UIBarButtonItem) {
        drawingCanvasView.clear()
    }
    
    @IBAction func toggleDebugDrawing(_ sender: UIButton) {
        drawingCanvasView.isDebuggingEnabled = !drawingCanvasView.isDebuggingEnabled
        visualizeAzimuth = !visualizeAzimuth
        sender.isSelected = drawingCanvasView.isDebuggingEnabled
    }
    
    @IBAction func toggleUsePreciseLocations(_ sender: UIButton) {
        drawingCanvasView.usePreciseLocations = !drawingCanvasView.usePreciseLocations
        sender.isSelected = drawingCanvasView.usePreciseLocations
    }
    
    // MARK: Rotation
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.landscapeLeft, .landscapeRight]
    }
    
    // MARK: Convenience
    
    func updateReticleViewWithTouch(_ touch: UITouch?, event: UIEvent?, isPredicted: Bool = false) {
//        guard let touch = touch where touch.type == .stylus else { return }
//        
//        reticleView.predictedDotLayer.isHidden = !isPredicted
//        reticleView.predictedLineLayer.isHidden = !isPredicted
//        
//        let azimuthAngle = touch.azimuthAngle(in: view)
//        let azimuthUnitVector = touch.azimuthUnitVector(in: view)
//        let altitudeAngle = touch.altitudeAngle
//        
//        if isPredicted {
//            reticleView.predictedAzimuthAngle = azimuthAngle
//            reticleView.predictedAzimuthUnitVector = azimuthUnitVector
//            reticleView.predictedAltitudeAngle = altitudeAngle
//        }
//        else {
//            let location = touch.preciseLocation(in: view)
//            reticleView.center = location
//            reticleView.actualAzimuthAngle = azimuthAngle
//            reticleView.actualAzimuthUnitVector = azimuthUnitVector
//            reticleView.actualAltitudeAngle = altitudeAngle
//        }
    }
}

extension ScratchPadViewController: DraggableViewDelegate {
    
    func onDroppedToTarget(_ sender: DraggableImageView) {
        LOG.debug("dropped! \(sender.tag)")
        sender.shouldSnapBack = false
        sender.shouldCopy = false
    }
    
    func enteringZone(_ sender: DraggableImageView, targets: [UIView]) {

    }
    
    func exitingZone(_ sender: DraggableImageView, targets: [UIView]) {

    }

    func isDragging(_ sender: DraggableImageView) {}
    func onDraggingStarted(_ sender: DraggableImageView) {}
    func onSnappedBack(_ sender: DraggableImageView) {}
    func onCopied(_ copiedSender: DraggableImageView) {}


}


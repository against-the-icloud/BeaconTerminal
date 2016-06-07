

import UIKit

class DragViewController: UIViewController {
    
    @IBOutlet weak var d2: DraggableImageView!
    @IBOutlet weak var d1: DraggableImageView!
    @IBOutlet weak var T2: DropTargetView!
    
    @IBOutlet weak var T3: DropTargetView!
    @IBOutlet weak var t1: DropTargetView!
    
    @IBOutlet weak var copySwitch: UISwitch!
    
    @IBOutlet weak var snapbackSwitch: UISwitch!
    @IBOutlet weak var moveSwitch: UISwitch!
    var draggableViews = [DraggableImageView]()
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        d1.shouldCopy = copySwitch.on
        d1.shouldSnapBack = snapbackSwitch.on
        
        d1.delegate = self
        
        d2.shouldCopy = copySwitch.on
        d2.shouldSnapBack = snapbackSwitch.on
        
        d2.delegate = self
        
        
        draggableViews.append(d1)
        draggableViews.append(d2)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func copySwitchAction(sender: UISwitch) {
        moveSwitch.on = !sender.on
        if sender.on {
            for draggableView in draggableViews {
                draggableView.shouldCopy = true
                draggableView.shouldSnapBack = true
            }
            snapbackSwitch.setOn(true, animated: true)
        }
    }
    @IBAction func moveSwitchAction(sender: UISwitch) {
        if sender.on {
            for draggableView in draggableViews {
                draggableView.shouldCopy = false
                draggableView.shouldSnapBack = false
            }
            copySwitch.setOn(false, animated: true)
        }
    }
    
    @IBAction func snapbackSwitchAction(sender: UISwitch) {
        
        if sender.on == false {
            copySwitch.setOn(false, animated: true)
        }
        
        for draggableView in draggableViews {
            draggableView.shouldCopy = sender.on
            draggableView.shouldSnapBack = sender.on
        }
    }
    

}

extension DragViewController: DraggableViewDelegate {
    
    func onDroppedToTarget(sender: DraggableImageView) {
        LOG.debug("\(sender)")
    }
    
    func enteringZone(sender: DraggableImageView, targets: [UIView]) {
        if !targets.isEmpty {
            for zone in targets {
                zone.backgroundColor = UIColor.brownColor()
            }
        }
    }
    
    func exitingZone(sender: DraggableImageView, targets: [UIView]) {
        if !targets.isEmpty {
            for zone in targets {
                zone.backgroundColor = UIColor.brownColor()
            }
        }
    }


    func isDragging(sender: DraggableImageView) {}
    func onDraggingStarted(sender: DraggableImageView) {}
    func onSnappedBack(sender: DraggableImageView) {}
    func onCopied(copiedSender: DraggableImageView) {}


}



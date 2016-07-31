

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
        d1.shouldCopy = copySwitch.isOn
        d1.shouldSnapBack = snapbackSwitch.isOn
        
        d1.delegate = self
        
        d2.shouldCopy = copySwitch.isOn
        d2.shouldSnapBack = snapbackSwitch.isOn
        
        d2.delegate = self
        
        
        draggableViews.append(d1)
        draggableViews.append(d2)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func copySwitchAction(_ sender: UISwitch) {
        moveSwitch.isOn = !sender.isOn
        if sender.isOn {
            for draggableView in draggableViews {
                draggableView.shouldCopy = true
                draggableView.shouldSnapBack = true
            }
            snapbackSwitch.setOn(true, animated: true)
        }
    }
    @IBAction func moveSwitchAction(_ sender: UISwitch) {
        if sender.isOn {
            for draggableView in draggableViews {
                draggableView.shouldCopy = false
                draggableView.shouldSnapBack = false
            }
            copySwitch.setOn(false, animated: true)
        }
    }
    
    @IBAction func snapbackSwitchAction(_ sender: UISwitch) {
        
        if sender.isOn == false {
            copySwitch.setOn(false, animated: true)
        }
        
        for draggableView in draggableViews {
            draggableView.shouldCopy = sender.isOn
            draggableView.shouldSnapBack = sender.isOn
        }
    }
    

}

extension DragViewController: DraggableViewDelegate {
    
    func onDroppedToTarget(_ sender: DraggableImageView) {
        LOG.debug("\(sender)")
    }
    
    func enteringZone(_ sender: DraggableImageView, targets: [UIView]) {
        if !targets.isEmpty {
            for zone in targets {
                zone.backgroundColor = UIColor.brown()
            }
        }
    }
    
    func exitingZone(_ sender: DraggableImageView, targets: [UIView]) {
        if !targets.isEmpty {
            for zone in targets {
                zone.backgroundColor = UIColor.brown()
            }
        }
    }


    func isDragging(_ sender: DraggableImageView) {}
    func onDraggingStarted(_ sender: DraggableImageView) {}
    func onSnappedBack(_ sender: DraggableImageView) {}
    func onCopied(_ copiedSender: DraggableImageView) {}


}



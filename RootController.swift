
import UIKit
import Material
import ChameleonFramework
import Pulsator
import Spring
import IBAnimatable
import PageMenu

class RootController: UIViewController {
    
    @IBOutlet weak var pulseView: AnimatableView!
    @IBOutlet weak var blurView: UIView!
    
    var shouldPresentScanner  = true
    
    // var pulsator : Pulsator?
    var pulsator = Pulsator()
    
    var isExpanded : Bool = false
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupMenu()
        prepareView()
        //preparePulseView()
        //pulsator.start()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(startPulsor), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
 
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let scannerViewController = self.storyboard?.instantiateViewControllerWithIdentifier("scannerViewController")
        
        if shouldPresentScanner {
            self.presentViewController(scannerViewController!, animated: true, completion: {
                self.shouldPresentScanner = false
                LOG.debug("Presented Scanner")
            })
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
              //self.addCircleBorderToImageView(pulseView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pulseView.layer.layoutIfNeeded()
        pulsator.position = CGPointMake(pulseView.frame.width/2, pulseView.frame.height/2)
    }
    
    internal func startPulsor() {
        //        pulsator.position = CGPointMake(pulseView.frame.width/2, pulseView.frame.height/2)
        //        pulsator.start()
    }
    
    func setupMenu() {
        
    }
    
    
    internal func preparePulseView() {
        
        //pulseView.layer.layoutIfNeeded()
        
        //        pulseView.layer.layoutIfNeeded()
        
        pulseView.layer.addSublayer(pulsator)
        print("\(pulseView.frame.size)")
        //pulsator!.position = CGPointMake(0, 0.5)
        //        pulsator!.position = pulseView.center
        
        pulsator.radius = pulseView.frame.size.width - (pulseView.frame.size.width/4)
        pulsator.radius = pulseView.frame.size.width/2.0
        pulsator.backgroundColor = MaterialColor.blue.base.CGColor
        pulsator.numPulse = 3
        pulsator.animationDuration = 5
        //        self.setAnchorPoint(CGPointMake(0.5, 0.5), forView: self.pulseView)
        pulseView.layer.layoutIfNeeded()
        
        pulsator.start()
        
    }
    
    /// Prepares view.
    private func prepareView() {
        view.backgroundColor = UIColor.whiteColor()
        pulseView.backgroundColor = MaterialColor.blue.base
        
        // view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.TopToBottom, withFrame:self.view.bounds, andColors:[UIColor.blackColor(),MaterialColor.white])
    }
    
    func setAnchorPoint(anchorPoint: CGPoint, forView view: UIView) {
        var newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y)
        
        newPoint = CGPointApplyAffineTransform(newPoint, view.transform)
        oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform)
        
        var position = view.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        view.layer.position = position
        view.layer.anchorPoint = anchorPoint
    }
    
    @IBAction func tapScanView(sender: UITapGestureRecognizer) {
        
        
        if !isExpanded {
            //            blurView.bringSubviewToFront(pulseView)
            
            //            setAnchorPoint(CGPointMake(0, 0.5), forView: pulseView)
            UIView.animateWithDuration(0.7, delay: 0.0, options: [],
                                       animations:
                {
                    //                    self.pulseView.transform = CGAffineTransformMakeScale(3, 3)
                    self.pulseView.backgroundColor = UIColor.whiteColor()
                    self.pulseView.borderColor = UIColor.whiteColor()
                }, completion: {
                    (value: Bool) in
                    //self.setAnchorPoint(CGPointMake(0.5, 0.5), forView: self.pulseView)
                    
                    self.preparePulseView()
                    self.isExpanded = true
                    
            });
        } else {
            //            setAnchorPoint(CGPointMake(0, 0.5), forView: pulseView)
            UIView.animateWithDuration(0.7, delay: 0.0, options: [],
                                       animations:
                {
                    self.pulseView.backgroundColor = MaterialColor.blue.base
                    self.pulseView.borderColor = MaterialColor.blue.base
                    
                    
                    //                    self.pulseView.transform = CGAffineTransformMakeScale(1, 1)
                    
                }, completion: {
                    (value: Bool) in
                    //self.setAnchorPoint(CGPointMake(0.5, 0.5), forView: self.pulseView)
                    
                    //self.preparePulseView()
                    self.isExpanded = false
                    self.pulsator.stop()
                    
            });
        }
        
    }
    
    @IBAction func unwindScannerView(unwindSegue: UIStoryboardSegue) {
        LOG.info("UNWINDED")
    }
    
    
}

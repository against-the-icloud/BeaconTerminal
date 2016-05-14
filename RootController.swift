
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
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(startPulsor), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
 
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let scannerViewController = self.storyboard?.instantiateViewControllerWithIdentifier("scannerViewController")
        scannerViewController!.modalPresentationStyle = .OverFullScreen
        if shouldPresentScanner {
            
            //performSegueWithIdentifier("scannerViewSegue", sender: nil)
            self.shouldPresentScanner = false
            LOG.debug("Presented Scanner")
//            self.presentViewController(scannerViewController!, animated: true, completion: {
//                self.shouldPresentScanner = false
//                LOG.debug("Presented Scanner")
//            })
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    
    /// Prepares view.
    private func prepareView() {
        view.backgroundColor = UIColor.whiteColor()
    }
    
    func updateViewCritter(index: Int) {
        LOG.debug("NEW CRITTER")
    }
    

    
    @IBAction func unwindToHereFromScannerView(segue: UIStoryboardSegue) {
        // And we are back
        let svc = segue.sourceViewController as! ScannerViewController
        
        let speciesIndex = svc.selectedSpeciesIndex
        
        
        // use svc to get mood, action, and place
    }
    
    
}

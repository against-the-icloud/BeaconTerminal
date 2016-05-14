
import UIKit
import Material
import ChameleonFramework
import Pulsator
import Spring
import IBAnimatable
import PageMenu

class RootController: UIViewController {
    
    var shouldPresentScanner  = true
    
    var isExpanded : Bool = false
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: UI
    @IBOutlet weak var toolbarView: ToolbarView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    
    
    // MARK: UIVIEWCONTROLLER METHODS
    
    
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
    
    // MARK: IBAction
    
    @IBAction func testCritterChange(sender: AnyObject) {
        
        let random = Int(arc4random_uniform(10) + 1)
        LOG.debug("random critter \(random)")
        
        let realmDB = DataManager.sharedInstance.realm
        _ = realmDB?.objects(Critter)
        let foundCritter = realmDB?.objects(Critter).filter("index = \(random)")[0] as Critter!
        //
        LOG.debug("\(foundCritter)")
        
        let speciesColor = UIColor.init(hex: foundCritter.color)

        self.toolbarView.updateToolbarColors(speciesColor)
        self.toolbarView.updateProfileImage(foundCritter.index)
        //update toolbar and tabbar
        
    }
    
    @IBAction func unwindToHereFromScannerView(segue: UIStoryboardSegue) {
        // And we are back
        let svc = segue.sourceViewController as! ScannerViewController
        
        let speciesIndex = svc.selectedSpeciesIndex
        
        LOG.debug("UNWINDED TO ROOT INDEX \(speciesIndex)")
        // use svc to get mood, action, and place
    }
    
    
}

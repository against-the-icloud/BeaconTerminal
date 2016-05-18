import UIKit
import Material
import ChameleonFramework
import Pulsator
import Spring
import RAMAnimatedTabBarController
import MobileCoreServices
import Photos

class RootController: UIViewController, UINavigationControllerDelegate {

    var shouldPresentScanner = true

    var isExpanded: Bool = false

    var statusBarColor: UIStatusBarStyle = UIStatusBarStyle.LightContent

    let imagePicker = UIImagePickerController()

    var currentlySelectedEcosystem = 0
    var currentlySelectedSpecies = 0

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }



    // MARK: UI
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var toolbarView: ToolbarView!

    @IBOutlet weak var contributionsView: UIView!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: UIVIEWCONTROLLER METHODS


    override func viewDidLoad() {
        super.viewDidLoad()
        //setupMenu()
        prepareView()
        prepareCamera()
        //startBackgroundViewAnimation()



        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(startPulsor), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }

    func startBackgroundViewAnimation() {
   
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

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return statusBarColor
    }

    // MARK: IBAction

    @IBAction func photoAlbumAction(sender: FabButton) {

        self.imagePicker.allowsEditing = true
        self.imagePicker.sourceType = .PhotoLibrary
        self.imagePicker.modalPresentationStyle = .Popover
        presentViewController(imagePicker, animated: true, completion: nil)

        let popPC = self.imagePicker.popoverPresentationController

        popPC!.sourceView = sender

        popPC!.permittedArrowDirections = UIPopoverArrowDirection.Any


    }

    @IBAction func cameraAction(sender: AnyObject) {
    }


    func changeSpecies(index: Int) {
        
        self.contributionsView.hidden = false

        self.startLabel.hidden = true
        //self.toolbarView.promoteProfileView()

        var speciesIndex = 0

        if index == -1 {
            speciesIndex = Int(arc4random_uniform(10) + 1)
            LOG.debug("random critter \(speciesIndex)")
        } else {
            speciesIndex = index
        }

        DataManager.sharedInstance.currentSelectedSpecies = speciesIndex

        let realmDB = DataManager.sharedInstance.realm
        _ = realmDB?.objects(Critter)
        let foundCritter = realmDB?.objects(Critter).filter("index = \(speciesIndex)")[0] as Critter!
        //
        LOG.debug("\(foundCritter)")

        let speciesColor = UIColor.init(hex: foundCritter.color)


        let newTextColor = UIColor(contrastingBlackOrWhiteColorOn:
        speciesColor, isFlat: true);


        if isLightColor(newTextColor) {
            UIApplication.sharedApplication().statusBarStyle = .LightContent
        } else {

            UIApplication.sharedApplication().statusBarStyle = .Default

        }

        self.setNeedsStatusBarAppearanceUpdate()



        self.toolbarView.updateToolbarColors(speciesColor, newTextColor: newTextColor)
        self.toolbarView.updateProfileImage(foundCritter.index)
        self.toolbarView.promoteProfileView()
        //update toolbar and tabbar

    }

    func resetSpecies() {
        self.contributionsView.hidden = true
        self.startLabel.hidden = false

        UIApplication.sharedApplication().statusBarStyle = .LightContent

        self.setNeedsStatusBarAppearanceUpdate()
        self.toolbarView.resetToolbarView()
        self.toolbarView.updateProfileImage(-1)
        self.toolbarView.promoteProfileView()
    }


    // MARK: UNWIND SEGUE

    @IBAction func unwindToHereFromScannerView(segue: UIStoryboardSegue) {
        // And we are back
        let svc = segue.sourceViewController as! ScannerViewController

        let speciesIndex = svc.selectedSpeciesIndex

        LOG.debug("UNWINDED TO ROOT INDEX \(speciesIndex)")
        // use svc to get mood, action, and place
    }

    @IBAction func unwindToHereTestTable(segue: UIStoryboardSegue) {
        // And we are back
        let svc = segue.sourceViewController as! TestUITableViewController

        let simulationIndex = svc.simulationIndex
        let simulationType = svc.simulationType
        self.simulate(simulationIndex, type: simulationType)
        LOG.debug("UNWINDED TO SIMULATION TYPE, INDEX \(simulationIndex) :TYPE: \(simulationType)")


    }

    func simulate(index: Int, type: String) {

        if type == "ECOSYSTEM" {
            switch index {
            case 0 ... 3:
                simulateEcosystem(index)
            case 4:
                disconnectEcosystem()
            default:
                LOG.info("unregonized test choice")
            }

        } else if type == "SPECIES" {
            switch index {
            case 0:
                simulateSpecies(-1)
            case 1:
                disconnectSpecies()
            case 2 ... 11:
                simulateSpecies(index-2)
            default:
                LOG.info("unrecongized test choice")
            }
        }


    }

    func simulateEcosystem(index: Int) {

        //UIViewController *view1 = [[UIViewController alloc] init];

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let ecosystemController = storyboard.instantiateViewControllerWithIdentifier("ecosystemViewController") as! EcosystemViewController
        
//
        var tabs = getAppDelegate().tabController!.viewControllers
        tabs?.append(ecosystemController)
        
        getAppDelegate().tabController!.setViewControllers(tabs, animated: true)
        //getAppDelegate().tabController!.
        //let items = getAppDelegate().tabController!.tabBar.items as! [RAMAnimatedTabBarItem]

    }

    func simulateSpecies(index: Int) {
        changeSpecies(index)
    }

    func disconnectEcosystem() {

    }

    func disconnectSpecies() {
        self.resetSpecies()
    }

    func openCamera() {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(imagePicker, animated: true, completion: nil)
        } else {
            openGallary()
        }
    }

    func openGallary() {
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.presentViewController(imagePicker, animated: true, completion: nil)
        } else {
//            popover=UIPopoverController(contentViewController: picker)
//            popover!.presentPopoverFromRect(btnClickMe.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }

    func isLightColor(color: UIColor) -> Bool {
        var white: CGFloat = 0.0
        color.getWhite(&white, alpha: nil)

        var isLight = false

        LOG.debug("WHITE \(white)")

        if white >= 0.5 {
            isLight = true
        } else {
        }

        return isLight
    }


}

extension RootController {

    // MARK: CAMERA ACTIONS

    func prepareCamera() {
        if isCameraAvailable() == false {
            LOG.debug("CAMERA NOT AVAILABLE")
        } else {
            self.imagePicker.delegate = self
        }
    }

    func isCameraAvailable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.Camera)
    }

    func determineStatus() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .Authorized:
            return true
        case .NotDetermined:
            PHPhotoLibrary.requestAuthorization() {
                _ in }
            return false
        case .Restricted:
            return false
        case .Denied:
            let alert = UIAlertController(
            title: "Need Authorization",
                    message: "Wouldn't you like to authorize this app " +
                            "to use your Photo library?",
                    preferredStyle: .Alert)
            alert.addAction(UIAlertAction(
            title: "No", style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(
            title: "OK", style: .Default, handler: {
                _ in
                let url = NSURL(string: UIApplicationOpenSettingsURLString)!
                UIApplication.sharedApplication().openURL(url)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            return false
        }
    }
}

extension UIImagePickerController {
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Landscape
    }
}

extension RootController: UIImagePickerControllerDelegate {


    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        LOG.debug("ImagePickerCanceled")
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String:AnyObject]) {

        dismissViewControllerAnimated(true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String:AnyObject]?) {

        dismissViewControllerAnimated(true, completion: nil)
    }
}
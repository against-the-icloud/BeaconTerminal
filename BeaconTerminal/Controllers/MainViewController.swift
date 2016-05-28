import UIKit
import ChameleonFramework
import Photos
import Popover
import Pulsator
import Spring
import Material
import MaterialDesignSymbol
import MobileCoreServices



class MainViewController: UIViewController, UINavigationControllerDelegate {

    var shouldPresentScanner = true

    var isExpanded: Bool = false
    var hasTabbar = false
    var hasScanButton = false

    @IBOutlet weak var menuView: MenuView!

    @IBOutlet weak var bottomTabBar: BottomTabBar!
    @IBOutlet weak var scanButton: FabButton!
    var statusBarColor: UIStatusBarStyle = UIStatusBarStyle.LightContent

    let imagePicker = UIImagePickerController()

    var currentlySelectedEcosystem = 0
    var currentlySelectedSpecies = 0
    var pageViewController: PageViewController?

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: UI
    @IBOutlet weak var toolbarView: ToolbarView!
    @IBOutlet weak var contributionsView: UIView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareTabBarItem()
    }

    // MARK: UIVIEWCONTROLLER METHODS


    override func viewDidLoad() {
        super.viewDidLoad()
        //setupMenu()
        self.prepareView()
        self.prepareCamera()
        self.prepareMenuViewExample()

        //self.prepareTabbar()


        //startBackgroundViewAnimation()



        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(startPulsor), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }

    /// Prepare tabBarItem.
    private func prepareTabBarItem() {
        tabBarItem.title = "Species"

        let symbol: MaterialDesignSymbol = MaterialDesignSymbol(text: MaterialDesignIcon.stars24px, size: 25)
        //symbol.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor())
        let iconImage: UIImage = symbol.imageWithSize(CGSizeMake(25, 25))

        tabBarItem.image = iconImage
        tabBarItem.setTitleColor(MaterialColor.grey.base, forState: .Normal)
        tabBarItem.setTitleColor(MaterialColor.white, forState: .Selected)
    }

//    func insertEmptyTabItem(title: String, atIndex: Int) {
//        let vc = UIViewController()
//        vc.tabBarItem = UITabBarItem(title: title, image: nil, tag: 0)
//        vc.tabBarItem.enabled = true
//        
//        self.tabBarController?.viewControllers?.insert(vc, atIndex: atIndex)
//    }
//    
//    func addRaisedButton(buttonImage: UIImage?, highlightImage: UIImage?) {
//        if let buttonImage = buttonImage {
//            let button = UIButton(type: UIButtonType.Custom)
//            button.autoresizingMask = [UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleTopMargin]
//            
//            button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height)
//            button.setBackgroundImage(buttonImage, forState: UIControlState.Normal)
//            button.setBackgroundImage(highlightImage, forState: UIControlState.Highlighted)
//            
//            let heightDifference = buttonImage.size.height - (self.tabBarController?.tabBar.frame.size.height)!
//            
//            if (heightDifference < 0) {
//                button.center = (self.tabBarController?.tabBar.center)!
//            }
//            else {
//                var center = self.tabBarController?.tabBar.center
//                center!.y -= heightDifference / 2.0
//                
//                button.center = center!
//            }
//            
//            button.addTarget(self, action: #selector(MainViewController.onRaisedButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//            self.view.addSubview(button)
//        }
//    }

//    func onRaisedButton(sender: UIButton!) {
//            LOG.debug("HELO RAISED")
//    }



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
        // Insert empty tab item at center index. In this case we have 5 tabs.
//        self.insertEmptyTabItem("", atIndex: 2)

        // Raise the center button with image


    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }


    /// Prepares view.
    private func prepareView() {
        view.backgroundColor = UIColor.whiteColor()
        if hasScanButton {
            scanButton.hidden = false
        } else {
            scanButton.hidden = true
        }
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
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .Camera
                imagePicker.cameraCaptureMode = .Photo
                presentViewController(imagePicker, animated: true, completion: {})
            } else {

            }
        } else {

        }
    }


    func changeSpecies(index: Int) {

//        self.contributionsView.hidden = false
//        self.contributionsView.setNeedsLayout()
//        self.contributionsView.setNeedsDisplay()

        //self.startLabel.hidden = true



        var speciesIndex = 0

        if index == -1 {
            speciesIndex = Int(arc4random_uniform(10) + 1)
            LOG.debug("random critter \(speciesIndex)")
        } else {
            speciesIndex = index
        }

        DataManager.sharedInstance.currentSelectedSpecies = speciesIndex
        pageViewController?.classContributionsCollectionViewController?.currentSelectedSpecies = index
        pageViewController?.classContributionsCollectionViewController?.refreshVotes()
        //self.toolbarView.promoteProfileView()

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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if "pageViewSegue" == segue.identifier {
            pageViewController = segue.destinationViewController as? PageViewController

        }
    }

    func simulate(index: Int, type: String) {

        if type == "ECOSYSTEM" {
            switch index {
            case 0 ... 3:
                print("not")
                //simulateEcosystem(index)
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
                simulateSpecies(index - 2)
            default:
                LOG.info("unrecongized test choice")
            }
        }


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



//    func prepareTabbar() {
//        if hasTabbar {
//            bottomTabBar.hidden = false
//            let videoItem: UITabBarItem = UITabBarItem(title: "Video", image: MaterialIcon.cm.videocam, selectedImage: nil)
//            videoItem.setTitleColor(MaterialColor.grey.base, forState: .Normal)
//            videoItem.setTitleColor(MaterialColor.teal.base, forState: .Selected)
//
//            let photoItem: UITabBarItem = UITabBarItem(title: "Photo", image: MaterialIcon.cm.photoCamera, selectedImage: nil)
//            photoItem.setTitleColor(MaterialColor.grey.base, forState: .Normal)
//            photoItem.setTitleColor(MaterialColor.teal.base, forState: .Selected)
//
//            let libraryItem: UITabBarItem = UITabBarItem(title: "Library", image: MaterialIcon.cm.photoLibrary, selectedImage: nil)
//            libraryItem.setTitleColor(MaterialColor.grey.base, forState: .Normal)
//            libraryItem.setTitleColor(MaterialColor.teal.base, forState: .Selected)
//
//            bottomTabBar.setItems([videoItem, photoItem, libraryItem], animated: true)
//            bottomTabBar.tintColor = MaterialColor.teal.base // Sets the image color when highlighted.
//            bottomTabBar.itemPositioning = .Automatic // Sets the alignment of the UITabBarItems.
//            bottomTabBar.selectedItem = videoItem
//
//        } else {
//            bottomTabBar.hidden = true
//        }
//    }

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

extension MainViewController {

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

    @IBAction func onBurger() {
        sideNavigationController?.toggleLeftView()
    }

}

extension UIImagePickerController {
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Landscape
    }
}

extension MainViewController: UIImagePickerControllerDelegate {


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


extension MainViewController {
    /// Handle the menuView touch event.
    internal func handleMenu() {
        if menuView.menu.opened {
            menuView.menu.close()
            (menuView.menu.views?.first as? MaterialButton)?.animate(MaterialAnimation.rotate(rotation: 0))
        } else {
            menuView.menu.open() {
                (v: UIView) in
                (v as? MaterialButton)?.pulse()
            }
            (menuView.menu.views?.first as? MaterialButton)?.animate(MaterialAnimation.rotate(rotation: 0.125))
        }
    }

    internal func handleSpeciesSelect(sender:AnyObject) {
       LOG.debug("SPECIES SELECT \(sender.tag)")

        let fb = sender as! FabButton

        let speciesIndex = sender.tag

        self.changeSpecies(speciesIndex)


        let storyboard = UIStoryboard(name: "CollectionBoard", bundle: nil)
        let addContributionViewController = storyboard.instantiateViewControllerWithIdentifier("addContributionViewController") as! AddContributionViewController
        addContributionViewController.speciesIndex = speciesIndex
        addContributionViewController.modalPresentationStyle = .Popover


        self.presentViewController(addContributionViewController, animated:true, completion:nil)
        if let pop = addContributionViewController.popoverPresentationController {
            pop.sourceView = fb
            pop.sourceRect = fb.bounds
            addContributionViewController.preferredContentSize = CGSizeMake(1000,588)
        }
    }



    /// Handle the menuView touch event.
    @objc(handleButton:)
    internal func handleButton(button: UIButton) {
        print("Hit Button \(button)")
    }

    /// Prepares the MenuView example.
    private func prepareMenuViewExample() {

        /// Diameter for FabButtons.
        let diameter: CGFloat = 70.0

        /// Diameter for FabButtons.
        let speciesDiameter: CGFloat = diameter - 10.0


        var buttons = [UIView]()

        //create add button
        let symbol: MaterialDesignSymbol = MaterialDesignSymbol(text: MaterialDesignIcon.add48px, size: 48)

        let image: UIImage = symbol.imageWithSize(CGSizeMake(48, 48)).imageWithRenderingMode(.AlwaysTemplate)

        let addButton: FabButton = FabButton()
        addButton.depth = .None

        addButton.tintColor = MaterialColor.white
        addButton.borderColor = MaterialColor.blue.accent3
        addButton.backgroundColor = MaterialColor.green.base

        addButton.setImage(image, forState: .Normal)
        addButton.setImage(image, forState: .Highlighted)

        addButton.addTarget(self, action: #selector(handleMenu), forControlEvents: .TouchUpInside)
        addButton.width = diameter
        addButton.height = diameter

        addButton.shadowColor = MaterialColor.black
        addButton.shadowOpacity = 0.5
        addButton.shadowOffset =  CGSize(width: 1.0, height: 0.0)


        menuView.addSubview(addButton)
        buttons.append(addButton)


        for index in 0 ... 10 {

            var fileIndex = ""
            var imageName = ""

            if index < 10 {
                fileIndex = "0\(index)"
                imageName = "species_\(fileIndex).png"
            } else {
                fileIndex = "\(index)"
                imageName = "species_\(fileIndex).png"
            }

            let speciesImage: UIImage? = UIImage(named: imageName)

            //let speciesButton: FabButton = FabButton(frame: CGRectMake(0, 0, diameter, diameter))
            let speciesButton: FabButton = FabButton()

            speciesButton.tag = index
            speciesButton.depth = .None
            //speciesButton.tintColor = MaterialColor.white
            //speciesButton.borderColor = MaterialColor.black
            speciesButton.backgroundColor = UIColor.clearColor()

            speciesButton.setImage(speciesImage, forState: .Normal)
            speciesButton.setImage(speciesImage, forState: .Highlighted)


//            speciesButton.shadowColor = MaterialColor.black
//            speciesButton.shadowOpacity = 1.0
//            speciesButton.shadowOffset =  CGSize(width: 1.0, height: 0.0)


            speciesButton.addTarget(self, action: #selector(handleSpeciesSelect), forControlEvents: .TouchUpInside)
            menuView.addSubview(speciesButton)
            buttons.append(speciesButton)
        }

        // Initialize the menu and setup the configuration options.
        menuView.menu.direction = .Up
        menuView.menu.baseSize = CGSizeMake(diameter, diameter)
        menuView.menu.itemSize = CGSizeMake(speciesDiameter, speciesDiameter)
        menuView.menu.views = buttons

        view.addSubview(menuView)
        MaterialLayout.size(view, child: menuView, width: diameter, height: diameter)
        MaterialLayout.alignFromBottomLeft(view, child: menuView, bottom: 16, left: (view.bounds.width - diameter) / 2)
    }
}
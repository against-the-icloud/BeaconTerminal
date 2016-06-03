import UIKit
import ChameleonFramework
import Photos
import Pulsator
import Spring
import Material
import MobileCoreServices
import SwiftState

enum ApplicationState: StateType {
    case START, PLACE_TERMINAL, PLACE_GROUP, OBJECT_GROUP
}

enum ToolType: String {
    case PHOTO_LIB, CAMERA, SCREENSHOT, SCANNER, TRASH
}

class MainViewController: UIViewController, UINavigationControllerDelegate {

    var shouldPresentScanner = true

    var isExpanded: Bool = false
    var hasTabbar = false
    var hasScanButton = false

    var statusBarColor: UIStatusBarStyle = UIStatusBarStyle.LightContent

    let imagePicker = UIImagePickerController()

    var currentlySelectedEcosystem = 0
    var currentlySelectedSpecies = 0
    var pageViewController: PageViewController?

    var machine: StateMachine<ApplicationState, NoEvent>!


    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    @IBOutlet weak var speciesMenuView: MenuView!

    @IBOutlet weak var toolsMenuView: MenuView!


    // MARK: UI
    @IBOutlet weak var toolbarView: ToolbarView!

    var scanButton: FabButton?


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initStateMachine()
    }

    // MARK: UIVIEWCONTROLLER METHODS

    func initStateMachine() {
        machine = StateMachine<ApplicationState, NoEvent>(state: .START) {
            machine in
            machine.addRoute(.Any => .START) {
                context in

                LOG.debug("INITIAL STATE MAINVIEWCONTROLLER")
                LOG.debug("state \(context.toState)")
            }

            machine.addRoute(.Any => .PLACE_GROUP) {
                context in
                LOG.debug("route \(context.toState)")
            }

            machine.addRoute(.Any => .PLACE_TERMINAL) {
                context in
                LOG.debug("route \(context.toState)")
            }

            machine.addRoute(.Any => .OBJECT_GROUP) {
                context in
                LOG.debug("route \(context.toState)")
            }
        }
        machine <- .START
    }

    func changeApplicationState(state: ApplicationState) {
        switch state {
        case .PLACE_GROUP:
            machine <- .PLACE_GROUP
        case .PLACE_TERMINAL:
            machine <- .PLACE_TERMINAL
        case .OBJECT_GROUP:
            machine <- .OBJECT_GROUP
        default:
            machine <- .PLACE_GROUP
        }
    }

    func doApplicationState() {
        switch machine.state {
        case .PLACE_GROUP:
            self.prepareTabBarItem()
            self.prepareToolsMenu([.PHOTO_LIB, .CAMERA, .SCREENSHOT])
            self.prepareView()
            self.prepareToolbar("PLACE GROUP TABLET", hasGroup: true)
            self.prepareCamera()
            self.prepareSpeciesMenu()
        case .PLACE_TERMINAL:
            self.prepareToolbar("PLACE TERMINAL", hasGroup: false)
            self.prepareView()
        case .OBJECT_GROUP:
            self.prepareTabBarItem()
            self.prepareToolsMenu([.SCANNER, .PHOTO_LIB, .CAMERA, .SCREENSHOT])
            self.prepareToolbar("PLACE OBJECT GROUP", hasGroup: true)
            self.prepareView()
            self.prepareCamera()
            self.prepareSpeciesMenu()
        default:
            print("")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.doApplicationState()

        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(startPulsor), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }

    /// Prepare tabBarItem.
    private func prepareTabBarItem() {
        tabBarItem.title = "Species"

        //let symbol: MaterialDesignSymbol = MaterialDesignSymbol(text: MaterialDesignIcon.stars24px, size: 25)


        let iconImage = UIImage(named: "ic_lightbulb_white")!

        //symbol.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor())

        tabBarItem.image = iconImage
        tabBarItem.setTitleColor(MaterialColor.grey.base, forState: .Normal)
        tabBarItem.setTitleColor(MaterialColor.white, forState: .Selected)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let scannerViewController = self.storyboard?.instantiateViewControllerWithIdentifier("scannerViewController")
        scannerViewController!.modalPresentationStyle = .OverFullScreen


        if shouldPresentScanner {

            //performSegueWithIdentifier("scannerViewSegue", sender: nil)
            self.shouldPresentScanner = false
            LOG.debug("Presented Scanner")
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

    private func prepareToolbar(toolbarTitle: String, hasGroup: Bool) {
        self.toolbarView.groupLabel.hidden = !hasGroup
        self.toolbarView.classLabel.hidden = !hasGroup
        self.toolbarView.titleLabel.text = toolbarTitle
    }

    func changeSpecies(index: Int) {

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


        if Utility.isLightColor(newTextColor) {
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
        UIApplication.sharedApplication().statusBarStyle = .LightContent

        self.setNeedsStatusBarAppearanceUpdate()
        self.toolbarView.resetToolbarView()
        self.toolbarView.updateProfileImage(-1)
        self.toolbarView.promoteProfileView()
    }

    //
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

    // MARK: Actions

    @IBAction func sideMenuAction(sender: UIButton) {
        sideNavigationController?.toggleLeftView()
    }

    // MARK: Photo Related

    @IBAction func photoAlbumAction(sender: UIButton) {

        self.imagePicker.allowsEditing = true
        self.imagePicker.sourceType = .PhotoLibrary
        self.imagePicker.modalPresentationStyle = .Popover
        presentViewController(imagePicker, animated: true, completion: nil)

        let popPC = self.imagePicker.popoverPresentationController

        popPC!.sourceView = sender

        popPC!.permittedArrowDirections = UIPopoverArrowDirection.Any
    }

    @IBAction func cameraAction(sender: UIButton) {
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

    @IBAction func screenShotAction(sender: UIButton) {
        if let wnd = self.view {

            var v = UIView(frame: wnd.bounds)
            v.backgroundColor = UIColor.whiteColor()
            v.alpha = 1

            wnd.addSubview(v)
            UIView.animateWithDuration(1, animations: {
                v.alpha = 0.0
            }, completion: {
                (finished: Bool) in

                v.removeFromSuperview()
                let v = self.view
                UIGraphicsBeginImageContextWithOptions(v.bounds.size, true, 1.0)
                v.drawViewHierarchyInRect(v.bounds, afterScreenUpdates: true)
                let img = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
            })
        }


    }

    @IBAction func scanAction(sender: UIButton) {
        self.performSegueWithIdentifier("scannerSegue", sender: sender)
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
    internal func handleSpeciesMenuSelection() {
        if speciesMenuView.menu.opened {
            speciesMenuView.menu.close()
            (speciesMenuView.menu.views?.first as? MaterialButton)?.animate(MaterialAnimation.rotate(rotation: 0))
        } else {
            speciesMenuView.menu.open() {
                (v: UIView) in
                (v as? MaterialButton)?.pulse()
            }
            (speciesMenuView.menu.views?.first as? MaterialButton)?.animate(MaterialAnimation.rotate(rotation: 0.125))
        }
    }

    /// Handle the menuView touch event.
    internal func handleToolsMenuSelection() {
        if toolsMenuView.menu.opened {
            toolsMenuView.menu.close()
            (toolsMenuView.menu.views?.first as? MaterialButton)?.animate(MaterialAnimation.rotate(rotation: 0))
        } else {
            toolsMenuView.menu.open() {
                (v: UIView) in
                (v as? MaterialButton)?.pulse()
            }
            (toolsMenuView.menu.views?.first as? MaterialButton)?.animate(MaterialAnimation.rotate(rotation: 0.125))
        }
    }

    internal func handleSpeciesSelect(sender: FabButton) {
        LOG.debug("SPECIES SELECT \(sender.tag)")

        let fb = sender

        let speciesIndex = sender.tag

        self.changeSpecies(speciesIndex)


        let storyboard = UIStoryboard(name: "CollectionBoard", bundle: nil)
        let relationshipContributionViewController = storyboard.instantiateViewControllerWithIdentifier("relationshipsContributionViewController") as! RelationshipsContributionViewController
        relationshipContributionViewController.speciesIndex = speciesIndex
        relationshipContributionViewController.title = "RELATIONSHIPS"

        let navigationController = UINavigationController(rootViewController: relationshipContributionViewController)
        navigationController.navigationBar.barTintColor = UIColor.whiteColor()
        navigationController.navigationBar.shadowColor = UIColor.whiteColor()
        navigationController.navigationBar.shadowOffset = CGSize(width: 0, height: 0)

//        let img = UIImage()
//        navigationController.navigationBar.shadowImage = img
//        navigationController.navigationBar.setBackgroundImage(img, forBarMetrics: UIBarMetrics.Default)

        navigationController.navigationBar.translucent = false
        navigationController.modalPresentationStyle = .Popover


        self.presentViewController(navigationController, animated: true, completion: nil)
        if let pop = navigationController.popoverPresentationController {
            pop.sourceView = fb
            pop.sourceRect = fb.bounds
            navigationController.preferredContentSize = CGSizeMake(1000, 625)
        }
    }

    /// Prepares the MenuView example.
    private func prepareSpeciesMenu() {

        /// Diameter for FabButtons.
        let diameter: CGFloat = 70.0

        /// Diameter for FabButtons.
        let speciesDiameter: CGFloat = diameter - 5.0


        var buttons = [UIView]()

        //create add button

        var image: UIImage? = UIImage(named: "tb_add_white")!
        image = image!.resizeToSize(CGSize(width: diameter / 2, height: diameter / 2))


        let addButton: FabButton = FabButton()
        addButton.depth = .None

        addButton.tintColor = MaterialColor.white
        addButton.borderColor = MaterialColor.blue.accent3
        addButton.backgroundColor = MaterialColor.green.base
//
        addButton.setImage(image, forState: .Normal)
        addButton.setImage(image, forState: .Highlighted)

        addButton.addTarget(self, action: #selector(handleSpeciesMenuSelection), forControlEvents: .TouchUpInside)
        addButton.width = diameter
        addButton.height = diameter

        addButton.shadowColor = MaterialColor.black
        addButton.shadowOpacity = 0.5
        addButton.shadowOffset = CGSize(width: 1.0, height: 0.0)


        speciesMenuView.addSubview(addButton)
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
            speciesButton.backgroundColor = UIColor.clearColor()

            speciesButton.setImage(speciesImage, forState: .Normal)
            speciesButton.setImage(speciesImage, forState: .Highlighted)

            speciesButton.addTarget(self, action: #selector(handleSpeciesSelect), forControlEvents: .TouchUpInside)
            speciesMenuView.addSubview(speciesButton)
            buttons.append(speciesButton)
        }

        // Initialize the menu and setup the configuration options.
        speciesMenuView.menu.direction = .Up
        speciesMenuView.menu.baseSize = CGSizeMake(diameter, diameter)
        speciesMenuView.menu.itemSize = CGSizeMake(speciesDiameter, speciesDiameter)
        speciesMenuView.menu.views = buttons

        view.addSubview(speciesMenuView)
    }

    /// Prepares the MenuView example.
    private func prepareToolsMenu(tools: [ToolType]) {

        /// Diameter for FabButtons.
        let diameter: CGFloat = 70.0

        /// Diameter for FabButtons.
        let toolsButtonDiameter: CGFloat = diameter - 5.0


        var buttons = [UIView]()


        //create add button

        var image: UIImage? = UIImage(named: "tb_tools_wrench_white")!

        image = image!.resizeToSize(CGSize(width: diameter / 2, height: diameter / 2))!

        let toolsButton: FabButton = FabButton()
        toolsButton.depth = .None

        toolsButton.tintColor = MaterialColor.white
        toolsButton.borderColor = MaterialColor.blue.accent3
        toolsButton.backgroundColor = MaterialColor.red.base

        toolsButton.setImage(image, forState: .Normal)
        toolsButton.setImage(image, forState: .Highlighted)


        toolsButton.addTarget(self, action: #selector(handleToolsMenuSelection), forControlEvents: .TouchUpInside)
        toolsButton.width = diameter
        toolsButton.height = diameter

        toolsButton.shadowColor = MaterialColor.black
        toolsButton.shadowOpacity = 0.5
        toolsButton.shadowOffset = CGSize(width: 1.0, height: 0.0)

        toolsMenuView.addSubview(toolsButton)

        buttons.append(toolsButton)

        for tool in tools {
            switch tool {
            case .SCANNER:
                var image = UIImage(named: "ic_wifi_white")!
                image = image.resizeToSize(CGSize(width: toolsButtonDiameter / 2, height: toolsButtonDiameter / 2))!


                let scanButton: FabButton = FabButton()
                scanButton.depth = .None

                scanButton.tintColor = MaterialColor.white
                scanButton.borderColor = MaterialColor.blue.accent3
                scanButton.backgroundColor = MaterialColor.blue.base

                scanButton.setImage(image, forState: .Normal)
                scanButton.setImage(image, forState: .Highlighted)

                scanButton.addTarget(self, action: #selector(scanAction), forControlEvents: .TouchUpInside)
                scanButton.width = diameter
                scanButton.height = diameter

                scanButton.shadowColor = MaterialColor.black
                scanButton.shadowOpacity = 0.5
                scanButton.shadowOffset = CGSize(width: 1.0, height: 0.0)

                toolsMenuView.addSubview(scanButton)

                buttons.append(scanButton)
            case .CAMERA:
                var cameraButton: FabButton = FabButton()
                image = UIImage(named: "tb_camera_white")
                image = image!.resizeToSize(CGSize(width: toolsButtonDiameter / 2, height: toolsButtonDiameter / 2))!


                cameraButton.depth = .None

                cameraButton.tintColor = MaterialColor.white
                cameraButton.borderColor = MaterialColor.blue.accent3
                cameraButton.backgroundColor = MaterialColor.blue.base

                cameraButton.setImage(image, forState: .Normal)
                cameraButton.setImage(image, forState: .Highlighted)

                cameraButton.addTarget(self, action: #selector(cameraAction), forControlEvents: .TouchUpInside)
                cameraButton.width = diameter
                cameraButton.height = diameter

                cameraButton.shadowColor = MaterialColor.black
                cameraButton.shadowOpacity = 0.5
                cameraButton.shadowOffset = CGSize(width: 1.0, height: 0.0)

                toolsMenuView.addSubview(cameraButton)

                buttons.append(cameraButton)
            case .PHOTO_LIB:
                //photolibrary button

                var image = UIImage(named: "tb_photo_library_white")!
                image = image.resizeToSize(CGSize(width: toolsButtonDiameter / 2, height: toolsButtonDiameter / 2))!
//

                let photoLibButton: FabButton = FabButton()
                photoLibButton.depth = .None

                photoLibButton.tintColor = MaterialColor.white
                photoLibButton.borderColor = MaterialColor.blue.accent3
                photoLibButton.backgroundColor = MaterialColor.blue.base

                photoLibButton.setImage(image, forState: .Normal)
                photoLibButton.setImage(image, forState: .Highlighted)

                photoLibButton.addTarget(self, action: #selector(photoAlbumAction), forControlEvents: .TouchUpInside)
                photoLibButton.width = diameter
                photoLibButton.height = diameter

                photoLibButton.shadowColor = MaterialColor.black
                photoLibButton.shadowOpacity = 0.5
                photoLibButton.shadowOffset = CGSize(width: 1.0, height: 0.0)

                buttons.append(photoLibButton)


                toolsMenuView.addSubview(photoLibButton)
            case .SCREENSHOT:
                var image = UIImage(named: "ic_flash_on_white")!
                image = image.resizeToSize(CGSize(width: toolsButtonDiameter / 2, height: toolsButtonDiameter / 2))!


                let screenShotButton: FabButton = FabButton()

                screenShotButton.depth = .None

                screenShotButton.tintColor = MaterialColor.white
                screenShotButton.borderColor = MaterialColor.blue.accent3
                screenShotButton.backgroundColor = MaterialColor.blue.base

                screenShotButton.setImage(image, forState: .Normal)
                screenShotButton.setImage(image, forState: .Highlighted)

                screenShotButton.addTarget(self, action: #selector(screenShotAction), forControlEvents: .TouchUpInside)
                screenShotButton.width = diameter
                screenShotButton.height = diameter

                screenShotButton.shadowColor = MaterialColor.black
                screenShotButton.shadowOpacity = 0.5
                screenShotButton.shadowOffset = CGSize(width: 1.0, height: 0.0)

                toolsMenuView.addSubview(screenShotButton)

                buttons.append(screenShotButton)


            case .TRASH:
                print("not yet")
            default:
                print("nothing")
            }
        }

        // Initialize the menu and setup the configuration options.
        toolsMenuView.menu.direction = .Up
        toolsMenuView.menu.baseSize = CGSizeMake(diameter, diameter)
        toolsMenuView.menu.itemSize = CGSizeMake(toolsButtonDiameter, toolsButtonDiameter)
        toolsMenuView.menu.views = buttons

        view.addSubview(toolsMenuView)

    }
}
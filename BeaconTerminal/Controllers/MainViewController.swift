import UIKit
import ChameleonFramework
import Photos
import Pulsator
import Spring
import Material
import MobileCoreServices
import SwiftState
import ALCameraViewController

enum ApplicationState: StateType {
    case START, PLACE_TERMINAL, PLACE_GROUP, OBJECT_GROUP
}

enum ToolTypes: String {
    case PHOTO_LIB, CAMERA, SCREENSHOT, SCANNER, TRASH
}

enum ToolMenuActions: String {
    case OPEN, CLOSE, BRING_FRONT
}

protocol ToolMenuDelegate {
    func onImageViewPresented(sender: UIImageView)
    func onImageViewDismissed(sender: UIImageView)
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

    var toolMenuButtons = [UIView]()
    var speciesMenuButtons = [UIView]()

    var passThroughImageView : UIImageView?
    
    var popoverNavigationController: UINavigationController?

    var blurEffectView : UIView?

    //var relationshipContributionViewController : RelationshipsContributionViewController?


    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: UI
    @IBOutlet weak var toolbarView: ToolbarView!

    var toolsMenuView : MenuView = MenuView()
    var speciesMenuView : MenuView = MenuView()

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

//                LOG.debug("INITIAL STATE MAINVIEWCONTROLLER")
                LOG.debug("state \(context.toState)")
            }

            machine.addRoute(.Any => .PLACE_GROUP) {
                context in
//                LOG.debug("route \(context.toState)")
            }

            machine.addRoute(.Any => .PLACE_TERMINAL) {
                context in
//                LOG.debug("route \(context.toState)")
            }

            machine.addRoute(.Any => .OBJECT_GROUP) {
                context in
//                LOG.debug("route \(context.toState)")
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
//            LOG.debug("Presented Scanner")
        }

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.bringSubviewToFront(speciesMenuView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }


    /// Prepares view.
    private func prepareView() {
        view.backgroundColor = UIColor.whiteColor()
        if blurEffectView != nil {
            blurEffectView!.removeFromSuperview()
        }
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

        let foundCritter = DataManager.findSpecies(speciesIndex)
        //
        LOG.debug("\(foundCritter)")

        let speciesColor = foundCritter!.convertHexColor()


        let newTextColor = UIColor(contrastingBlackOrWhiteColorOn:
        speciesColor, isFlat: true);


        if Utility.isLightColor(newTextColor) {
            UIApplication.sharedApplication().statusBarStyle = .LightContent
        } else {

            UIApplication.sharedApplication().statusBarStyle = .Default

        }

        self.setNeedsStatusBarAppearanceUpdate()

        self.toolbarView.updateToolbarColors(speciesColor, newTextColor: newTextColor)
        self.toolbarView.updateProfileImage(foundCritter!.index)
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

    @IBAction func unwindToHereFromSpeciesDone(segue: UIStoryboardSegue) {
        //remove blur after popover

        if blurEffectView != nil {
            UIView.animateWithDuration(0.3, animations: {
                self.blurEffectView!.alpha = 1.0
            }, completion: { finished in
                self.setTabBarVisible(true, duration: 0.3, animated: true)
                self.blurEffectView!.removeFromSuperview()
                self.blurEffectView = nil
                self.handleSpeciesMenuSelection()
            })

        }

    }

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

//        self.imagePicker.allowsEditing = true
//        self.imagePicker.sourceType = .PhotoLibrary
//        self.imagePicker.modalPresentationStyle = .OverFullScreen
//        self.imagePicker.modalTransitionStyle = .CrossDissolve
//        self.imagePicker.delegate = self
//        presentViewController(imagePicker, animated: true, completion: nil)


        let libraryViewController = CameraViewController.imagePickerViewController(true) { image, asset in

            if let imageView = self.passThroughImageView {
                imageView.image = image

            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }

        presentViewController(libraryViewController, animated: true, completion: nil)
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

            let v = UIView(frame: wnd.bounds)
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

        dismissViewControllerAnimated(true, completion: {
            if let imageView = self.passThroughImageView {
                imageView.image = image
            }
        })
    }
}

extension MainViewController: ToolMenuDelegate {
    func onImageViewPresented(sender: UIImageView) {

        self.view.bringSubviewToFront(self.toolsMenuView)
        self.passThroughImageView = sender
//        for v in self.view.subviews {
//            if ((v as? UIVisualEffectView) != nil) {
//                self.view.bringSubviewToFront(self.toolsMenuView)
//            }
//        }
        if toolsMenuView.menu.opened == false {
            self.handleToolsMenuSelection()
        }
    }

    func onImageViewDismissed(sender: UIImageView) {
        //self.toolsMenuView.superview?.bringSubviewToFront(self.toolsMenuView)

    }
}

extension MainViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return false
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

        var allPassthroughViews = [UIView]()
        allPassthroughViews += self.speciesMenuButtons[0...speciesMenuButtons.count-1]
        //all species except the + button

        _ = UIScreen.mainScreen().bounds.size

        let createPopover = {
            (speciesIndex: Int) -> UINavigationController in
            let storyboard = UIStoryboard(name: "CollectionBoard", bundle: nil)
            let relationshipContributionViewController = storyboard.instantiateViewControllerWithIdentifier("relationshipsContributionViewController") as? RelationshipsContributionViewController
            relationshipContributionViewController?.speciesIndex = speciesIndex
            relationshipContributionViewController?.title = "RELATIONSHIPS"
            relationshipContributionViewController?.toolMenuDelegate = self

            let navController = UINavigationController(rootViewController: relationshipContributionViewController!)
            navController.navigationBar.barTintColor = UIColor.whiteColor()
            navController.navigationBar.shadowColor = UIColor.whiteColor()
            navController.navigationBar.shadowOffset = CGSize(width: 0, height: 0)


            navController.navigationBar.translucent = false
            navController.modalTransitionStyle = .CrossDissolve
            navController.modalPresentationStyle = .Popover
            return navController
        }


        if  blurEffectView == nil {
            blurEffectView = self.view.createBlurForView(.Light)
            blurEffectView?.alpha = 0
            self.view.addSubview(blurEffectView!)
            self.view.bringSubviewToFront(self.speciesMenuView)
            self.setTabBarVisible(false, duration: 0.3, animated: true)
            UIView.animateWithDuration(0.3, animations: {
                self.blurEffectView?.alpha = 1
            }, completion: {
                finished in

                self.popoverNavigationController = createPopover(speciesIndex)
                self.presentViewController(self.popoverNavigationController!, animated: true, completion: nil)

                if let pop = self.popoverNavigationController!.popoverPresentationController {
                    pop.sourceView = fb
                    pop.sourceRect = fb.bounds
                    pop.delegate = self
                    pop.passthroughViews = allPassthroughViews
                    self.popoverNavigationController!.preferredContentSize = CGSizeMake(1000, 625)
                }
            })
        } else {

            self.dismissViewControllerAnimated(true, completion: {
                self.popoverNavigationController = createPopover(speciesIndex)
                self.presentViewController(self.popoverNavigationController!, animated: true, completion: nil)

                if let pop = self.popoverNavigationController!.popoverPresentationController {
                    pop.sourceView = fb
                    pop.sourceRect = fb.bounds
                    pop.delegate = self
                    pop.passthroughViews = allPassthroughViews
                    self.popoverNavigationController!.preferredContentSize = CGSizeMake(1000, 625)
                }
            })

        }

    }

    /// Prepares the MenuView example.
    private func prepareSpeciesMenu() {

        /// Diameter for FabButtons.
        let diameter: CGFloat = 70.0

        /// Diameter for FabButtons.
        let speciesDiameter: CGFloat = diameter - 5.0

        speciesMenuButtons = [UIView]()


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
        speciesMenuButtons.append(addButton)


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
            speciesMenuButtons.append(speciesButton)
        }

        // Initialize the menu and setup the configuration options.
        speciesMenuView.menu.direction = .Up
        speciesMenuView.menu.baseSize = CGSizeMake(diameter, diameter)
        speciesMenuView.menu.itemSize = CGSizeMake(speciesDiameter, speciesDiameter)
        speciesMenuView.menu.views = speciesMenuButtons


        //speciesMenuView.center = CGPoint(x: 16, y: 1022)

//        var tabView : (UIView) = self.tabBarController!.view
//        var btnPoint : CGPoint = recordButton.center;
//        var btnRect : CGPoint = recordButton.convertPoint(btnPoint, toView: tabView)
//        self.tabBarController?.view.addSubview(recordButton)
//        recordButton.frame.origin = btnRect


      //  if self.tabBarIsVisible() {
//            var tabView = self.tabBarController!.view
//        var btnPoint : CGPoint = speciesMenuView2.center
//        var btnRect : CGPoint = speciesMenuView2.convertPoint(btnPoint, toView: tabView)
//        self.tabBarController?.view.addSubview(speciesMenuView2)
//        speciesMenuView2.frame.origin = btnRect

//        recordButton.frame.origin = btnRect
//        } else {
           // speciesMenuView.frame.origin = CGPoint(x: 16, y: 1022)
            speciesMenuView.zPosition = 0
            view.addSubview(speciesMenuView)
            MaterialLayout.size(view, child: speciesMenuView, width: diameter, height: diameter)
            MaterialLayout.alignFromBottomLeft(view, child: speciesMenuView, bottom: 50, left: 10)
//
//        // Print out the dimensions of the labels.
//            view.layoutIfNeeded()

    }

    /// Prepares the MenuView example.
    private func prepareToolsMenu(tools: [ToolTypes]) {

        /// Diameter for FabButtons.
        let diameter: CGFloat = 70.0

        /// Diameter for FabButtons.
        let toolsButtonDiameter: CGFloat = diameter - 5.0


         toolMenuButtons = [UIView]()


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

        toolMenuButtons.append(toolsButton)

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

                toolMenuButtons.append(scanButton)
            case .CAMERA:
                let cameraButton: FabButton = FabButton()
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

                toolMenuButtons.append(cameraButton)
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

                toolMenuButtons.append(photoLibButton)


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

                toolMenuButtons.append(screenShotButton)


            case .TRASH:
                print("not yet")         
            }
        }

        // Initialize the menu and setup the configuration options.
        toolsMenuView.menu.direction = .Up
        toolsMenuView.menu.baseSize = CGSizeMake(diameter, diameter)
        toolsMenuView.menu.itemSize = CGSizeMake(toolsButtonDiameter, toolsButtonDiameter)
        toolsMenuView.menu.views = toolMenuButtons

        

        view.addSubview(toolsMenuView)

        MaterialLayout.size(view, child: toolsMenuView, width: diameter, height: diameter)
        MaterialLayout.alignFromBottomRight(view, child: toolsMenuView, bottom: 50, right: 10)
        UIApplication.sharedApplication().keyWindow?.bringSubviewToFront(toolsMenuView)

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
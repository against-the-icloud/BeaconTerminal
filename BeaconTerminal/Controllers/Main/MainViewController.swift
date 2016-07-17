import UIKit
import Photos
import Spring
import Material
import MobileCoreServices
import SwiftState
//import ALCameraViewController

//enum ApplicationState: StateType {
//    case START, PLACE_TERMINAL, PLACE_GROUP, OBJECT_GROUP
//}

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

    //var machine: StateMachine<ApplicationState, NoEvent>!

    var toolMenuButtons = [UIView]()
    var speciesMenuButtons = [UIView]()

    var passThroughImageView: UIImageView?
    
    var popoverNavigationController: UINavigationController?

    var blurEffectView: UIView?
    
    
    let sideMenuButtonSpacing: CGFloat = 10.0
    
    var sideMenuButtonDiameter: CGFloat {
        
        get {
            
            let screenHeight = CGRectGetHeight(UIScreen.mainScreen().bounds)
            let numButtons: CGFloat = 12.0
            
            
            //button size
            let buttonSize = (screenHeight - (numButtons * sideMenuButtonSpacing)) / numButtons
            
            return floor(buttonSize)
        }
    
    }
    
    var speciesMenuButtonCenter: CGPoint {
        get {
            //lower left
            let screenHeight = CGRectGetHeight(UIScreen.mainScreen().bounds)
            
            let x: CGFloat = 10
            let y: CGFloat = screenHeight - (sideMenuButtonDiameter + 10)
            
            return CGPointMake(x, y)
        }
    }
    
    var toolsMenuButtonCenter: CGPoint {
        get {
            //lower right
            let screenHeight = CGRectGetHeight(UIScreen.mainScreen().bounds)
            let screenWidth = CGRectGetWidth(UIScreen.mainScreen().bounds)

            let x: CGFloat = screenWidth - (sideMenuButtonDiameter + 10)
            let y: CGFloat = screenHeight - (sideMenuButtonDiameter + 10)
            
            return CGPointMake(x, y)
        }
    }
    
    

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    var toolsMenuView : MenuView = MenuView()
    var speciesMenuView : MenuView = MenuView()

    var scanButton: FabButton?

    // MARK: UIVIEWCONTROLLER METHODS
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
 
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationDrawerController?.enabled = true
        let scannerViewController = self.storyboard?.instantiateViewControllerWithIdentifier("scannerViewController")
        scannerViewController!.modalPresentationStyle = .OverFullScreen
        
        
        if shouldPresentScanner {
            
            //performSegueWithIdentifier("scannerViewSegue", sender: nil)
            self.shouldPresentScanner = false
            //            LOG.debug("Presented Scanner")
        }
        
    }
    
    // MARK: Preparations
    
    // check the state of the system and draw that
    func prepareViews() {
        let state = getAppDelegate().checkApplicationState()
        switch state {
        case .PLACE_GROUP:
            prepareTabBarItem()
            prepareSpeciesMenu()
            prepareToolsMenu([.PHOTO_LIB, .CAMERA, .SCREENSHOT, .SCANNER, .TRASH])
        case .PLACE_TERMINAL:
            print()
        case .OBJECT_GROUP:
            prepareTabBarItem()
            prepareSpeciesMenu()
            prepareToolsMenu([.PHOTO_LIB, .CAMERA, .SCREENSHOT, .SCANNER, .TRASH])
        default:
            break
        }
    }
    
    /// Prepare tabBarItem.
    private func prepareTabBarItem() {
        tabBarItem.title = "Species"
        let iconImage = UIImage(named: "ic_lightbulb_white")!
        tabBarItem.image = iconImage
        tabBarItem.setTitleColor(MaterialColor.grey.base, forState: .Normal)
        tabBarItem.setTitleColor(MaterialColor.white, forState: .Selected)
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

        let speciesBeaconDetail = svc.selectedBeaconDetail

        LOG.debug("UNWINDED TO ROOT INDEX \(speciesBeaconDetail?.asSimpleDescription)")
        
        
        let changeNavigationColor = { (hexColor: String) -> Void in
            
            let nav = self.navigationController?.navigationBar
            nav?.backgroundColor = UIColor(hex: hexColor)

            nav?.tintColor = UIColor.whiteColor()
            nav?.topItem?.titleLabel.textColor = UIColor.whiteColor()
            
            self.navigationController?.navigationBar.layer.zPosition = -1;
        }
        
        changeNavigationColor(speciesBeaconDetail!.hexColor)
        
//        self.navigationBar.tintColor = MaterialColor.white
//        self.navigationBar.backgroundColor = UIColor(hex: speciesBeaconDetail!.hexColor)
        
        // use svc to get mood, action, and place
    }

    @IBAction func unwindToHereTestTable(segue: UIStoryboardSegue) {
        // And we are back
        let svc = segue.sourceViewController as! TestUITableViewController

        let simulationIndex = svc.simulationIndex
        let simulationType = svc.simulationType
//        self.simulate(simulationIndex, type: simulationType)
        LOG.debug("UNWINDED TO SIMULATION TYPE, INDEX \(simulationIndex) :TYPE: \(simulationType)")
    }

    // MARK: Photo Related

    @IBAction func photoAlbumAction(sender: UIButton) {

//        self.imagePicker.allowsEditing = true
//        self.imagePicker.sourceType = .PhotoLibrary
//        self.imagePicker.modalPresentationStyle = .OverFullScreen
//        self.imagePicker.modalTransitionStyle = .CrossDissolve
//        self.imagePicker.delegate = self
//        presentViewController(imagePicker, animated: true, completion: nil)


//        let libraryViewController = CameraViewController.imagePickerViewController(true) { image, asset in
//
//            if let imageView = self.passThroughImageView {
//                imageView.image = image
//
//            }
//            self.dismissViewControllerAnimated(true, completion: nil)
//        }
//
//        presentViewController(libraryViewController, animated: true, completion: nil)
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
     

        /// Diameter for FabButtons.
        let speciesDiameter: CGFloat = sideMenuButtonDiameter - 1.0

        speciesMenuButtons = [UIView]()


        //create add button

        var image: UIImage? = UIImage(named: "tb_add_white")!
        image = image!.resizeToSize(CGSize(width: sideMenuButtonDiameter / 2, height: sideMenuButtonDiameter / 2))


        let addButton: FabButton = FabButton()
        addButton.depth = .None

        addButton.tintColor = MaterialColor.white
        addButton.borderColor = MaterialColor.blue.accent3
        addButton.backgroundColor = MaterialColor.green.base
//
        addButton.setImage(image, forState: .Normal)
        addButton.setImage(image, forState: .Highlighted)

        addButton.addTarget(self, action: #selector(handleSpeciesMenuSelection), forControlEvents: .TouchUpInside)
        addButton.width = sideMenuButtonDiameter
        addButton.height = sideMenuButtonDiameter

        addButton.shadowColor = MaterialColor.black
        addButton.shadowOpacity = 0.5
        addButton.shadowOffset = CGSize(width: 1.0, height: 0.0)
        addButton.layer.zPosition = CGFloat(FLT_MAX)


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
        speciesMenuView.menu.spacing = sideMenuButtonSpacing
        speciesMenuView.menu.baseSize = CGSizeMake(speciesDiameter, speciesDiameter)
        speciesMenuView.menu.itemSize = CGSizeMake(sideMenuButtonDiameter, sideMenuButtonDiameter)
        speciesMenuView.menu.views = speciesMenuButtons




        speciesMenuView.center = speciesMenuButtonCenter
        getAppDelegate().window?.addSubview(speciesMenuView)
    }

    /// Prepares the MenuView example.
    private func prepareToolsMenu(tools: [ToolTypes]) {

        /// Diameter for FabButtons.
        

        /// Diameter for FabButtons.
        let toolsButtonDiameter: CGFloat = sideMenuButtonDiameter - 5.0


         toolMenuButtons = [UIView]()


        //create add button

        var image: UIImage? = UIImage(named: "tb_tools_wrench_white")!

        image = image!.resizeToSize(CGSize(width: sideMenuButtonDiameter / 2, height: sideMenuButtonDiameter / 2))!

        let toolsButton: FabButton = FabButton()
        toolsButton.depth = .None

        toolsButton.tintColor = MaterialColor.white
        toolsButton.borderColor = MaterialColor.blue.accent3
        toolsButton.backgroundColor = MaterialColor.red.base

        toolsButton.setImage(image, forState: .Normal)
        toolsButton.setImage(image, forState: .Highlighted)


        toolsButton.addTarget(self, action: #selector(handleToolsMenuSelection), forControlEvents: .TouchUpInside)
        toolsButton.width = sideMenuButtonDiameter
        toolsButton.height = sideMenuButtonDiameter

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
                scanButton.width = sideMenuButtonDiameter
                scanButton.height = sideMenuButtonDiameter

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
                cameraButton.width = sideMenuButtonDiameter
                cameraButton.height = sideMenuButtonDiameter

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
                photoLibButton.width = sideMenuButtonDiameter
                photoLibButton.height = sideMenuButtonDiameter

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
                screenShotButton.width = sideMenuButtonDiameter
                screenShotButton.height = sideMenuButtonDiameter

                screenShotButton.shadowColor = MaterialColor.black
                screenShotButton.shadowOpacity = 0.5
                screenShotButton.shadowOffset = CGSize(width: 1.0, height: 0.0)

                toolsMenuView.addSubview(screenShotButton)

                toolMenuButtons.append(screenShotButton)


            case .TRASH:
                break
            }
        }

        // Initialize the menu and setup the configuration options.
        toolsMenuView.menu.direction = .Up
        toolsMenuView.menu.baseSize = CGSizeMake(sideMenuButtonDiameter, sideMenuButtonDiameter)
        toolsMenuView.menu.itemSize = CGSizeMake(toolsButtonDiameter, toolsButtonDiameter)
        toolsMenuView.menu.views = toolMenuButtons


        toolsMenuView.center = toolsMenuButtonCenter
        getAppDelegate().window?.addSubview(toolsMenuView)

//        view.addSubview(toolsMenuView)
//
//        Layout.size(view, child: toolsMenuView, width: sideMenuButtonDiameter, height: sideMenuButtonDiameter)
//        Layout.bottomRight(view, child: toolsMenuView, bottom: 50, right: 10)
//        UIApplication.sharedApplication().keyWindow?.bringSubviewToFront(toolsMenuView)

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
import UIKit
import Photos
import Material
import MobileCoreServices
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
    func onImageViewPresented(_ sender: UIImageView)
    func onImageViewDismissed(_ sender: UIImageView)
}

class MainViewController: UIViewController, UINavigationControllerDelegate {

    var shouldPresentScanner = true

    var isExpanded: Bool = false
    var hasTabbar = false
    var hasScanButton = false

    var statusBarColor: UIStatusBarStyle = UIStatusBarStyle.lightContent

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
            let screenHeight = UIScreen.main.bounds.height
            let numButtons: CGFloat = 12.0
            
            //button size
            let buttonSize = (screenHeight - (numButtons * sideMenuButtonSpacing)) / numButtons
            
            return floor(buttonSize)
        }
    
    }
    
    var speciesMenuButtonCenter: CGPoint {
        get {
            //lower left
            let screenHeight = UIScreen.main.bounds.height
            
            let x: CGFloat = 10
            let y: CGFloat = screenHeight - (sideMenuButtonDiameter + 10)
            
            return CGPoint(x: x, y: y)
        }
    }
    
    var toolsMenuButtonCenter: CGPoint {
        get {
            //lower right
            let screenHeight = UIScreen.main.bounds.height
            let screenWidth = UIScreen.main.bounds.width

            let x: CGFloat = screenWidth - (sideMenuButtonDiameter + 10)
            let y: CGFloat = screenHeight - (sideMenuButtonDiameter + 10)
            
            return CGPoint(x: x, y: y)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    var toolsMenuView : Menu = Menu()

    var scanButton: FabButton?

    // MARK: UIVIEWCONTROLLER METHODS
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
 
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationDrawerController?.isEnabled = true
        let scannerViewController = self.storyboard?.instantiateViewController(withIdentifier: "scannerViewController")
        scannerViewController!.modalPresentationStyle = .overFullScreen
        
        
        if shouldPresentScanner {
            //performSegueWithIdentifier("scannerViewSegue", sender: nil)
            self.shouldPresentScanner = false
        }
        
        
        prepareMenus()
    }
    
    
    
    // MARK: Preparations
    
    // check the state of the system and draw that
    func prepareViews() {
        let state = getAppDelegate().checkApplicationState()
        switch state {
        case .placeGroup:
            prepareTabBarItem()
            //prepareNavigationItem(withTitle: "Place-Group")
        case .placeTerminal:
            print()
            break
        case .objectGroup:
            prepareTabBarItem()
            
        default:
            break
        }
    }
    
    func prepareMenus() {
        let state = getAppDelegate().checkApplicationState()
        switch state {
        case .placeGroup:
            speciesMenu(shouldShow: true)
        case .placeTerminal:
            speciesMenu(shouldShow: false)
            break
        case .objectGroup:
            speciesMenu(shouldShow: true)
        default:
            break
        }
    }
    
    func speciesMenu(shouldShow: Bool) {
        if shouldShow {
            getAppDelegate().speciesViewController?.prepareSpeciesMenu()
            getAppDelegate().speciesViewController?.showMenu()
        } else {
            getAppDelegate().speciesViewController?.removeSpeciesMenu()
        }
      
    }
    
    
    /// Prepare tabBarItem.
    private func prepareTabBarItem() {
        tabBarItem.title = Tabs.species.rawValue
        let iconImage = UIImage(named: "ic_lightbulb_white")!
        tabBarItem.image = iconImage
        Util.prepareTabBar(with: tabBarItem)
    }
    
    private func prepareNavigationItem(withTitle title: String) {
        let nav = self.navigationController?.navigationBar
        nav?.backgroundColor = Util.flatBlack
        nav?.topItem?.titleLabel.text = title
        nav?.topItem?.titleLabel.textColor = UIColor.white
        
        navigationItem.titleLabel.text = "hello"
        self.title = "Hello"
    }

    func openCamera() {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            openGallary()
        }
    }

    func openGallary() {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.present(imagePicker, animated: true, completion: nil)
        } else {
//            popover=UIPopoverController(contentViewController: picker)
//            popover!.presentPopoverFromRect(btnClickMe.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }

    // MARK: UNWIND SEGUE

    @IBAction func unwindToHereFromSpeciesDone(_ segue: UIStoryboardSegue) {
        //remove blur after popover

        if blurEffectView != nil {
            UIView.animate(withDuration: 0.3, animations: {
                self.blurEffectView!.alpha = 1.0
            }, completion: { finished in
                self.setTabBarVisible(true, duration: 0.3, animated: true)
                self.blurEffectView!.removeFromSuperview()
                self.blurEffectView = nil
                //self.handleSpeciesMenuSelection()
            })

        }

    }

    @IBAction func unwindToHereFromScannerView(_ segue: UIStoryboardSegue) {
        // And we are back
//        let svc = segue.sourceViewController as! ScannerViewController
//
//        let speciesBeaconDetail = svc.selectedBeaconDetail
//
//        LOG.debug("UNWINDED TO ROOT INDEX \(speciesBeaconDetail?.asSimpleDescription)")
//        
//        
//        let changeNavigationColor = { (hexColor: String) -> Void in
//            
//            let nav = self.navigationController?.navigationBar
//            //nav?.backgroundColor = UIColor(hex: hexColor)
//
//            nav?.tintColor = UIColor.whiteColor()
//            nav?.topItem?.titleLabel.textColor = UIColor.whiteColor()
//            
//            self.navigationController?.navigationBar.layer.zPosition = -1;
//        }
//        
//        changeNavigationColor(speciesBeaconDetail!.hexColor)
        
//        self.navigationBar.tintColor = Color.white
//        self.navigationBar.backgroundColor = UIColor(hex: speciesBeaconDetail!.hexColor)
        
        // use svc to get mood, action, and place
    }

    @IBAction func unwindToHereTestTable(_ segue: UIStoryboardSegue) {
        // And we are back
//        let svc = segue.source as! TestUITableViewController
//
//        let simulationIndex = svc.simulationIndex
//        let simulationType = svc.simulationType
//        self.simulate(simulationIndex, type: simulationType)
        //LOG.debug("UNWINDED TO SIMULATION TYPE, INDEX \(simulationIndex) :TYPE: \(simulationType)")
    }

    // MARK: Photo Related

    @IBAction func photoAlbumAction(_ sender: UIButton) {

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

    @IBAction func cameraAction(_ sender: UIButton) {
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .camera
                imagePicker.cameraCaptureMode = .photo
                present(imagePicker, animated: true, completion: {})
            } else {

            }
        } else {

        }
    }

    @IBAction func screenShotAction(_ sender: UIButton) {
        if let wnd = self.view {

            let v = UIView(frame: wnd.bounds)
            v.backgroundColor = UIColor.white()
            v.alpha = 1

            wnd.addSubview(v)
            UIView.animate(withDuration: 1, animations: {
                v.alpha = 0.0
            }, completion: {
                (finished: Bool) in

                v.removeFromSuperview()
                let v = self.view
                UIGraphicsBeginImageContextWithOptions((v?.bounds.size)!, true, 1.0)
                v?.drawHierarchy(in: (v?.bounds)!, afterScreenUpdates: true)
                let img = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                UIImageWriteToSavedPhotosAlbum(img!, nil, nil, nil)
            })
        }
    }
    
    // Mark: Scanner Action
    
    @IBAction func scanAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "scannerSegue", sender: sender)
    }
    
    // Mark: ShowMap Action
    
    func showMap(gesture: UITapGestureRecognizer) {
        tabBarController?.selectedIndex = 2
        getAppDelegate().bottomNavigationController?.selectedIndex = 2
        getAppDelegate().bottomNavigationController?.checkBadges(with: Tabs.maps.rawValue)
        
        
    }
    
    // Mark: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap" {
            _ = segue.destination as? MapViewController
///            mapController
        }
    }
}

extension UIImagePickerController {
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .landscape
        }
    }
    
}

extension MainViewController: UIImagePickerControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        LOG.debug("ImagePickerCanceled")
    }

    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String:AnyObject]) {
        dismiss(animated: true, completion: nil)
    }

    
}

extension MainViewController: ToolMenuDelegate {
    func onImageViewPresented(_ sender: UIImageView) {

        self.view.bringSubview(toFront: self.toolsMenuView)
        self.passThroughImageView = sender
//        for v in self.view.subviews {
//            if ((v as? UIVisualEffectView) != nil) {
//                self.view.bringSubviewToFront(self.toolsMenuView)
//            }
//        }
        if toolsMenuView.isOpened == false {
            self.handleToolsMenuSelection()
        }
    }

    func onImageViewDismissed(_ sender: UIImageView) {
        //self.toolsMenuView.superview?.bringSubviewToFront(self.toolsMenuView)

    }
}

extension MainViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return false
    }
}

extension MainViewController {

    /// Handle the menuView touch event.
    internal func handleToolsMenuSelection() {
//        if toolsMenuView.menu.opened {
//            toolsMenuView.menu.close()
//            (toolsMenuView.menu.views?.first as? MaterialButton)?.animate(MaterialAnimation.rotate(rotation: 0))
//        } else {
//            toolsMenuView.menu.open() {
//                (v: UIView) in
//                (v as? MaterialButton)?.pulse()
//            }
//            (toolsMenuView.menu.views?.first as? MaterialButton)?.animate(MaterialAnimation.rotate(rotation: 0.125))
//        }
    }

    /// Prepares the MenuView example.
    private func prepareToolsMenu(_ tools: [ToolTypes]) {

        /// Diameter for FabButtons.
        

        /// Diameter for FabButtons.
        let toolsButtonDiameter: CGFloat = sideMenuButtonDiameter - 5.0


         toolMenuButtons = [UIView]()


        //create add button

        var image: UIImage? = UIImage(named: "tb_tools_wrench_white")!

        image = image!.resizeToSize(CGSize(width: sideMenuButtonDiameter / 2, height: sideMenuButtonDiameter / 2))!

        let toolsButton: FabButton = FabButton()
        

        toolsButton.tintColor = Color.white
        toolsButton.borderColor = Color.blue.accent3
        toolsButton.backgroundColor = Color.red.base

        toolsButton.setImage(image, for: .normal)
        toolsButton.setImage(image, for: .highlighted)


        toolsButton.addTarget(self, action: #selector(handleToolsMenuSelection), for: .touchUpInside)
        toolsButton.width = sideMenuButtonDiameter
        toolsButton.height = sideMenuButtonDiameter

        toolsButton.shadowColor = Color.black
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
                

                scanButton.tintColor = Color.white
                scanButton.borderColor = Color.blue.accent3
                scanButton.backgroundColor = Color.blue.base

                scanButton.setImage(image, for: .normal)
                scanButton.setImage(image, for: .highlighted)

                scanButton.addTarget(self, action: #selector(scanAction), for: .touchUpInside)
                scanButton.width = sideMenuButtonDiameter
                scanButton.height = sideMenuButtonDiameter

                scanButton.shadowColor = Color.black
                scanButton.shadowOpacity = 0.5
                scanButton.shadowOffset = CGSize(width: 1.0, height: 0.0)

                toolsMenuView.addSubview(scanButton)

                toolMenuButtons.append(scanButton)
            case .CAMERA:
                let cameraButton: FabButton = FabButton()
                image = UIImage(named: "tb_camera_white")
                image = image!.resizeToSize(CGSize(width: toolsButtonDiameter / 2, height: toolsButtonDiameter / 2))!
                cameraButton.tintColor = Color.white
                cameraButton.borderColor = Color.blue.accent3
                cameraButton.backgroundColor = Color.blue.base

                cameraButton.setImage(image, for: .normal)
                cameraButton.setImage(image, for: .highlighted)

                cameraButton.addTarget(self, action: #selector(cameraAction), for: .touchUpInside)
                cameraButton.width = sideMenuButtonDiameter
                cameraButton.height = sideMenuButtonDiameter

                cameraButton.shadowColor = Color.black
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
                

                photoLibButton.tintColor = Color.white
                photoLibButton.borderColor = Color.blue.accent3
                photoLibButton.backgroundColor = Color.blue.base

                photoLibButton.setImage(image, for: .normal)
                photoLibButton.setImage(image, for: .highlighted)

                photoLibButton.addTarget(self, action: #selector(photoAlbumAction), for: .touchUpInside)
                photoLibButton.width = sideMenuButtonDiameter
                photoLibButton.height = sideMenuButtonDiameter

                photoLibButton.shadowColor = Color.black
                photoLibButton.shadowOpacity = 0.5
                photoLibButton.shadowOffset = CGSize(width: 1.0, height: 0.0)

                toolMenuButtons.append(photoLibButton)


                toolsMenuView.addSubview(photoLibButton)
            case .SCREENSHOT:
                var image = UIImage(named: "ic_flash_on_white")!
                image = image.resizeToSize(CGSize(width: toolsButtonDiameter / 2, height: toolsButtonDiameter / 2))!


                let screenShotButton: FabButton = FabButton()

                

                screenShotButton.tintColor = Color.white
                screenShotButton.borderColor = Color.blue.accent3
                screenShotButton.backgroundColor = Color.blue.base

                screenShotButton.setImage(image, for: .normal)
                screenShotButton.setImage(image, for: .highlighted)

                screenShotButton.addTarget(self, action: #selector(screenShotAction), for: .touchUpInside)
                screenShotButton.width = sideMenuButtonDiameter
                screenShotButton.height = sideMenuButtonDiameter

                screenShotButton.shadowColor = Color.black
                screenShotButton.shadowOpacity = 0.5
                screenShotButton.shadowOffset = CGSize(width: 1.0, height: 0.0)

                toolsMenuView.addSubview(screenShotButton)

                toolMenuButtons.append(screenShotButton)


            case .TRASH:
                break
            }
        }

        // Initialize the menu and setup the configuration options.
        toolsMenuView.direction = .up
        toolsMenuView.baseSize = CGSize(width: sideMenuButtonDiameter, height: sideMenuButtonDiameter)
        toolsMenuView.itemSize = CGSize(width: toolsButtonDiameter, height: toolsButtonDiameter)
        toolsMenuView.views = toolMenuButtons


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
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    func determineStatus() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization() {
                _ in }
            return false
        case .restricted:
            return false
        case .denied:
            let alert = UIAlertController(
                    title: "Need Authorization",
                    message: "Wouldn't you like to authorize this app " +
                            "to use your Photo library?",
                    preferredStyle: .alert)
            alert.addAction(UIAlertAction(
                    title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(
                    title: "OK", style: .default, handler: {
                _ in
                let url = URL(string: UIApplicationOpenSettingsURLString)!
                UIApplication.shared.openURL(url)
            }))
            self.present(alert, animated: true, completion: nil)
            return false
        }
    }

}

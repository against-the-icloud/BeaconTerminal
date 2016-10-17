//
//  MainContainerController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 9/8/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Photos
import MobileCoreServices
import Material
import RealmSwift

@objc protocol TopToolbarDelegate {
    func changeAppearance(withColor color: UIColor)
}

class MainContainerController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet var containerViews: [UIView]!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var topTabbar: TabSegmentedControl!
    @IBOutlet weak var topPanel: UIView!
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var tabContainterView: UIView!
    
    var TERMINAL_INDEX = 0
    
    var notificationTokens = [NotificationToken]()
    var runtimeResults: Results<Runtime>?
    var terminalRuntimeResults: Results<Runtime>?
    var runtimeNotificationToken: NotificationToken? = nil
    var terminalRuntimeNotificationToken: NotificationToken? = nil
    var tabViews = [UIView]()
    var tabControllers = [WebViewController]()
    
    //menu items
    var toolMenuTypes: [ToolMenuType] = [ToolMenuType]()
    var toolMenuItems: [UIView] = [UIView]()
    
    deinit {
        for notificationToken in notificationTokens {
            notificationToken.stop()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topTabbar.initUI()
        prepareNotifications()
        
        if needsTerminal {
            prepareTerminalNotifications()
        } else {
            
        }
        
        prepareToolMenu()
        prepareTabs()
    }
    
    func prepareTabs() {
        if let channels = UserDefaults.standard.array(forKey: "channelList") {
            for (index,item) in channels.enumerated() {
                if let c = item as? [String:String], let name = c["name"]?.replacingOccurrences(of: "-", with: " ").uppercased(), let url = c["url"], c["name"] != "species-notes" {
                    
                    
                    if index == 1 {
                        topTabbar.setTitle(name, forSegmentAt: index)
                    }else {
                        topTabbar.insertSegment(withTitle: name, at: index, animated: true)
                    }
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    
                    if let webViewController = storyboard.instantiateViewController(withIdentifier: "webViewController") as? WebViewController {
                        webViewController.src = url
                        self.addChildViewController(webViewController)
                        webViewController.view.frame = self.tabContainterView.frame
                        webViewController.view.isHidden = true
                        webViewController.view.alpha = 0.0
                        tabContainterView.addSubview(webViewController.view)
                        webViewController.didMove(toParentViewController: self)
                        tabViews.append(webViewController.view)
                        tabControllers.append(webViewController)
                    }
                }
            }
        }
    }
    
    func  prepareToolMenu() {
        if !toolMenuTypes.isEmpty {
            toolMenuItems.append(prepareAddButton())
            
            for type in toolMenuTypes {
                switch type {
                case .CAMERA:
                    let item = prepareMenuItem(withTitle: "CAMERA",withImage: Icon.cm.photoCamera!)
                    item.button.addTarget(self, action: #selector(cameriaAction), for: .touchUpInside)
                    toolMenuItems.append(item)
                case .PHOTO_LIB:
                    let item = prepareMenuItem(withTitle: "PHOTO LIBRARY",withImage: Icon.cm.photoLibrary!)
                    item.button.addTarget(self, action: #selector(photoAlbumAction), for: .touchUpInside)
                    toolMenuItems.append(item)
                case .SCREENSHOT:
                    let item = prepareMenuItem(withTitle: "TAKE SCREENSHOT",withImage: UIImage(named: "ic_flash_on_white")!)
                    item.button.addTarget(self, action: #selector(screenShotAction), for: .touchUpInside)
                    toolMenuItems.append(item)
                case .SCANNER:
                    let item = prepareMenuItem(withTitle: "SCANNER", withImage: UIImage(named: "ic_wifi_white")!)
                    item.button.addTarget(self, action: #selector(scannerAction), for: .touchUpInside)
                    toolMenuItems.append(item)
                }
            }
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepareMenuController()
    }
    
    //Mark: Notifications
    
    func prepareNotifications() {
        runtimeResults = realmDataController.getRealm().objects(Runtime.self)
        
        
        // Observe Notifications
        runtimeNotificationToken = runtimeResults?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            
            guard let mainController = self else { return }
            switch changes {
            case .initial(let runtimeResults):
                //we have nothing
                if runtimeResults.isEmpty {
                    //mainController.showLogin()
                } else {
                    mainController.updateHeader()
                    //mainController.showLogin()
                }
                break
            case .update( _, _, _, _):
                LOG.debug("UPDATE Runtime -- TERMINAL")
                mainController.updateHeader()
                //terminalController.updateUI(withRuntimeResults: runtimeResults)
                break
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                LOG.error("\(error)")
                break
            }
        }
    }
    
    func prepareTerminalNotifications() {
        terminalRuntimeResults = realmDataController.getRealm(withRealmType: RealmType.terminalDB).objects(Runtime.self)
        
        
        // Observe Notifications
        terminalRuntimeNotificationToken = terminalRuntimeResults?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            
            guard let mainController = self else { return }
            switch changes {
            case .initial(let terminalRuntimeResults):
                //we have nothing
                if terminalRuntimeResults.isEmpty {
                    //mainController.showLogin()
                } else {
                    mainController.updateTabs(terminalRuntimeResults: terminalRuntimeResults)
                }
                break
            case .update(let terminalRuntimeResults, _, _, _):
                LOG.debug("UPDATE terminal Runtime -- TERMINAL RESULTS")
                mainController.updateTabs(terminalRuntimeResults: terminalRuntimeResults)
                //TerminalCellController.updateUI(withRuntimeResults: runtimeResults)
                break
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                LOG.error("\(error)")
                break
            }
        }
    }
    
    //Mark: Update
    
    func updateHeader() {
        if let sectionName = realmDataController.getRealm().runtimeSectionName() {
            sectionLabel.text = "\(sectionName.uppercased())"
        }
        
        if let groupIndex = realmDataController.getRealm().runtimeGroupIndex(), let sectionName = realmDataController.getRealm().runtimeSectionName(), let group = realmDataController.getRealm().group(withSectionName: sectionName, withGroupIndex: groupIndex), let _ = group.name {
            topTabbar.setTitle("SPECIES", forSegmentAt: 0)
            groupLabel.text = "TEAM \(groupIndex + 1)"
            
        }
        
        
        switch getAppDelegate().checkApplicationState() {
        case .objectGroup:
            badgeImageView.image = UIImage(named: "objectGroup")
        case .cloudGroup:
            badgeImageView.image = UIImage(named: "cloudGroup")
        default:
            badgeImageView.image = UIImage(named: "placeGroup")
        }
        colorizeSelectedSegment()
    }
    
    func updateTabs(terminalRuntimeResults: Results<Runtime>) {
        if let terminalRuntime = terminalRuntimeResults.first, let speciesIndex = terminalRuntime.currentSpeciesIndex.value, let _ = terminalRuntime.currentSectionName, let action = terminalRuntime.currentAction {
            
            if let atype = ActionType(rawValue: action) {
                switch atype {
                case .entered:
                    
                    _ = RealmDataController.generateImageForSpecies(speciesIndex, isHighlighted: true)
                    
                    
                    if let species = realmDataController.getRealm().speciesWithIndex(withIndex: speciesIndex) {
                        
                        let title = "\(species.name.uppercased())"
                        
                        for v in topTabbar.subviews {
                            v.backgroundColor = #colorLiteral(red: 0.01405510586, green: 0.6088837981, blue: 0.6111404896, alpha: 1)
                        }
                        
                        if TERMINAL_INDEX == 0 {
                            topTabbar.insertSegment(withTitle: title, at: topTabbar.numberOfSegments, animated: true)
                            TERMINAL_INDEX = topTabbar.numberOfSegments - 1
                            topTabbar.selectedSegmentIndex = TERMINAL_INDEX
                        } else {
                            topTabbar.setTitle(title, forSegmentAt: TERMINAL_INDEX)
                            topTabbar.selectedSegmentIndex = TERMINAL_INDEX
                            
                        }
                        
                        colorizeSelectedSegment()
                        topTabbar.setNeedsLayout()
                        topTabbar.setNeedsDisplay()
                        
                        changeTab(withControl: topTabbar)
                        realmDataController.queryNutellaAllNotes(withType: .species, withRealmType: RealmType.terminalDB)
                    }
                case .exited:
                    topTabbar.removeSegment(at: TERMINAL_INDEX, animated: true)
                    topTabbar.selectedSegmentIndex = 0
                    colorizeSelectedSegment()
                    changeTab(withControl: topTabbar)
                }
                
            }
            
        }
    }
    
    func showLogin() {
        let storyboard = UIStoryboard(name: "Popover", bundle: nil)
        let loginNavigationController = storyboard.instantiateViewController(withIdentifier: "loginNavigationController") as! UINavigationController
        
        self.present(loginNavigationController, animated: true, completion: {})
    }
    
    
    func changeTab(withControl tabbar: UISegmentedControl) {
        
        switch tabbar.selectedSegmentIndex {
        case 0:
            switchContainerTab(withIndex: 0)
        case TERMINAL_INDEX:
            switchContainerTab(withIndex: 1)
        default:
            for containerView in containerViews {
                containerView.isHidden = true
                
                containerView.fadeOut(0.0) {_ in
                }
                
            }
            
            let adjustedIndex = tabbar.selectedSegmentIndex - 1
            
            for (index,tabView) in tabViews.enumerated() {
                if index == adjustedIndex {
                    tabView.isHidden = false
                    
                    tabView.fadeIn(toAlpha: 1.0) {_ in
                        let wc = self.tabControllers[adjustedIndex]
                        wc.reload()
                    }
                } else {
                    
                    tabView.fadeOut(0.0) {_ in
                        tabView.isHidden = true
                    }
                }
            }
        }
        
    }
    
    func switchContainerTab(withIndex showIndex: Int) {
        for tabView in tabViews {
            tabView.fadeOut(0.0) {_ in
                tabView.isHidden = true
            }
        }
        
        let showView = containerViews[showIndex]
        for (index,containerView) in containerViews.enumerated() {
            if index == showIndex {
                containerView.isHidden = false
                containerView.fadeIn(toAlpha: 1.0) {_ in
                    
                }
            } else {
                containerView.isHidden = true
                containerView.fadeOut(0.0) {_ in
                }
            }
        }
        showView.fadeIn(toAlpha: 1.0) {_ in
        }
        
    }
    
    
    @IBAction func showSidebar(_ sender: Any) {
        navigationDrawerController?.openLeftView()
    }
    
    @IBAction func tabChanged(_ sender: UISegmentedControl) {
        colorizeSelectedSegment()
        changeTab(withControl: sender)
    }
    
    func colorizeSelectedSegment() {
        let sortedViews = topTabbar.subviews.sorted( by: { $0.frame.origin.x < $1.frame.origin.x } )
        
        for (index, view) in sortedViews.enumerated() {
            if index == topTabbar.selectedSegmentIndex {
                
                view.backgroundColor = UIColor.black
                
                
            } else {
                
                view.backgroundColor = #colorLiteral(red: 0.01405510586, green: 0.6088837981, blue: 0.6111404896, alpha: 1)
                
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "speciesPageContainerController":
            return true
        case "terminalSegue":
            return needsTerminal
        default:
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else {
            return
        }
        switch id {
        case "speciesPageContainerController":
            if segue.destination is SpeciePageContainerController {
            }
        case "terminalSegue": break
            // if let tvc = segue.destination as? TerminalMainViewController {
            
        //}
        default:
            break
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //Mark: Toolbar menu
    
    /// Handle the menu toggle event.
    internal func handleToggleMenu(button: Any?) {
        guard let mc = menuController as? ToolMenuController else {
            return
        }
        if mc.menu.isOpened {
            mc.closeMenu { (view) in
                (view as? MenuItem)?.hideTitleLabel()
            }
        } else {
            mc.openMenu { (view) in
                (view as? MenuItem)?.showTitleLabel()
            }
        }
    }
    
    /// Prepares the addButton.
    private func prepareAddButton() -> FabButton {
        let addButton = FabButton(image: Icon.cm.add, tintColor: Color.white)
        addButton.backgroundColor = Color.red.base
        addButton.addTarget(self, action: #selector(handleToggleMenu), for: .touchUpInside)
        return addButton
    }
    
    /// Prepares the audioLibraryButton.
    private func prepareMenuItem(withTitle title: String, withImage image: UIImage) -> MenuItem {
        let menuItem = MenuItem()
        menuItem.button.image = image
        menuItem.button.backgroundColor = Color.red.base
        menuItem.title = title
        return menuItem
    }
    
    /// Prepares the menuController.
    private func prepareMenuController() {
        guard let mc = menuController as? ToolMenuController else {
            return
        }
        mc.menu.delegate = self
        mc.menu.views = toolMenuItems
    }
    
    // Mark: Action
    
     @IBAction func unwindToMainFromScanner(segue: UIStoryboardSegue) {
        
        if let scannerViewController =  segue.source as? ScannerViewController {
            if let speciesIndex = scannerViewController.scannedSpecies, let beaconId = scannerViewController.scannedBeaconId {
                
                
                let condition = getAppDelegate().checkApplicationState().rawValue
                realmDataController.syncSpeciesObservations(withSpeciesIndex: speciesIndex, withCondition: condition, withActionType: "enter", withPlace: "species:\(speciesIndex)")
                realmDataController.clearInViewTerminal(withCondition: condition)
                realmDataController.updateInViewTerminal(withSpeciesIndex: speciesIndex, withCondition: "artifact", withPlace: beaconId.asString)
                
                
            }
        }
        
    }
    
    func cameriaAction(sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .camera
        
        imagePickerController.delegate = self
        
        imagePickerController.modalPresentationStyle = UIModalPresentationStyle.popover
        imagePickerController.popoverPresentationController?.sourceView = sender
        
        // Make sure ViewController is notified when the user picks an image.
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func screenShotAction(sender: UIButton) {
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
    
    func scannerAction(sender: UIButton) {
        handleToggleMenu(button: nil)
        realmDataController.clearInViewTerminal(withCondition: "artifact")
        self.performSegue(withIdentifier: "scannerSegue", sender: sender)
    }
    
    func photoAlbumAction(sender: UIButton) {
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        
        imagePickerController.delegate = self
        
        imagePickerController.modalPresentationStyle = UIModalPresentationStyle.popover
        imagePickerController.popoverPresentationController?.sourceView = sender
        
        // Make sure ViewController is notified when the user picks an image.
        self.present(imagePickerController, animated: true, completion: nil)
        //present(imagePickerController, animated: true, completion: nil)
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
}

//Mark: ToolMenu

extension MainContainerController: MenuDelegate {
    func menu(menu: Menu, tappedAt point: CGPoint, isOutside: Bool) {
        guard isOutside else {
            return
        }
        
        guard let mc = menuController as? ToolMenuController else {
            return
        }
        
        mc.closeMenu { (view) in
            (view as? MenuItem)?.hideTitleLabel()
        }
    }
    
    
}

extension MainContainerController: UIImagePickerControllerDelegate {
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
        
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        UIImageWriteToSavedPhotosAlbum(chosenImage, self,
                                       #selector(MainContainerController.image(image:didFinishSavingWithError:contextInfo:)), nil)
        dismiss(animated:true, completion: nil)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafeRawPointer) {
        if error != nil {
            
        }
    }
    
    
}



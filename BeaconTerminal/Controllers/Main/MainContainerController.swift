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

class MainContainerController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet var containerViews: [UIView]!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var topTabbar: TabSegmentedControl!
    @IBOutlet weak var topPanel: UIView!
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var tabContainterView: UIView!
    
    
    
    @IBOutlet var beaconProfileImageViews: [UIImageView]!
    
    @IBOutlet weak var beaconBarStatusLabel: UILabel!
    
    
    var TERMINAL_INDEX = -1
    
    var notificationTokens = [NotificationToken]()
    var runtimeResults: Results<Runtime>?
    var terminalRuntimeResults: Results<Runtime>?
    var channelResults: Results<Channel>?
    var runtimeNotificationToken: NotificationToken? = nil
    var terminalRuntimeNotificationToken: NotificationToken? = nil
    var channelNotificationToken: NotificationToken? = nil
    var tabViews = [UIView]()
    var tabControllers = [UIViewController]()
    
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
    //    var  monitoringManager = ESTMonitoringManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topTabbar.initUI()
        
        topTabbar.removeSegment(at: 0, animated: false)
        prepareNotifications()
        
        if needsTerminal {
            prepareTerminalNotifications()
        } else {
            
        }
        prepareToolMenu()
        prepareTabs()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepareMenuController()
    }
    
    func prepareTabs() {
        
        realmDataController.updateChannel(withId: "species-notes", url: "", name: "Species Notes")
        
        topTabbar.setTitle("Species Notes", forSegmentAt: 0)
        topTabbar.selectedSegmentIndex = 0
        colorizeSelectedSegment()
        
        if let channels = UserDefaults.standard.array(forKey: "channelList") {
            for (index,item) in channels.enumerated() {
                if let c = item as? [String:String], let url = c["url"], let id = c["name"] {
                    
                    let adjIndex = index
                    
                    //if id != "species-notes" {
                    switch index {
                    case 0:
                        break
                    default:
                        topTabbar.insertSegment(withTitle: id, at: index, animated: true)
                    }
                    
                    switch index {
                    case 0:
                        break
                    case 1...10:
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        
                        realmDataController.updateChannel(withId: id, url: url, name: "")
                        
                        
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
                            webViewController.loadAddress()
                        }
                    default:
                        print("")
                    }
                }
            }
        }
    }
    
    func prepareToolMenu() {
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
    
    
    // MARK: Notifications
    
    func prepareNotifications() {
        //
        NotificationCenter.default.addObserver(self, selector: #selector(updateBeaconBar(_:)), name: NSNotification.Name(rawValue: beaconNotificationKey), object: nil)
        
        
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
        
        if let r = runtimeNotificationToken {
            notificationTokens.append(r)
        }
        
        channelResults = realmDataController.getRealm().objects(Channel.self)
        
        // Observe Notifications
        channelNotificationToken = channelResults?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            
            guard let mainController = self else { return }
            switch changes {
            case .initial(let channelResults):
                //we have nothing
                if channelResults.isEmpty {
                    
                } else {
                    mainController.updateChannels(withResults: channelResults)
                }
                break
            case .update(let channelResults, _, _, _):
                LOG.debug("UPDATE Channels -- TERMINAL")
                
                mainController.updateChannels(withResults: channelResults)
                
                break
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                LOG.error("\(error)")
                break
            }
        }
        
        if let r = channelNotificationToken {
            notificationTokens.append(r)
        }
        
    }
    
    func updateChannels(withResults channelResults: Results<Channel>) {
        
        if topTabbar.numberOfSegments > 0 {
            
            let max = topTabbar.numberOfSegments - 1
            
            for i in 0...max {
                if let id = topTabbar.titleForSegment(at: i) {
                    
                    if let found = channelResults.filter("id = '\(id)'").first, let name = found.name, name != "" {
                        topTabbar.setTitle(name, forSegmentAt: i)
                    }
                }
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
    
    //MARK: Update
    
    func updateBeaconBar(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo,
            let speciesIndex  = userInfo["speciesIndex"] as? NSNumber,
            let action     = userInfo["action"]    as? ActionType else {
                print("No userInfo found in notification")
                return
        }
        
        let si = speciesIndex.intValue
        
        switch action {
        case .exited:
            beaconProfileImageViews[si].image = nil
        default:
            beaconProfileImageViews[si].image = RealmDataController.generateImageForSpecies(si, isHighlighted: true)
        }
    }
    
    func updateHeader() {
        if let sectionName = realmDataController.getRealm().runtimeSectionName() {
            sectionLabel.text = "\(sectionName.uppercased())"
        }
        
        if let groupIndex = realmDataController.getRealm().runtimeGroupIndex(), let sectionName = realmDataController.getRealm().runtimeSectionName(), let group = realmDataController.getRealm().group(withSectionName: sectionName, withGroupIndex: groupIndex), let _ = group.name {
            //topTabbar.setTitle("SPECIES", forSegmentAt: 0)
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
                        
                       
                        
                        
                        if TERMINAL_INDEX == -1 {
                            
                            if terminalRuntime.channels.isEmpty {
                                TERMINAL_INDEX = 1

                            } else {
                                TERMINAL_INDEX = topTabbar.numberOfSegments

                            }
                            
                            topTabbar.insertSegment(withTitle: title, at: TERMINAL_INDEX, animated: true)
                        } else {
                            
                            if TERMINAL_INDEX < topTabbar.numberOfSegments {
                                
                                if topTabbar.titleForSegment(at: TERMINAL_INDEX) == nil {
                                    TERMINAL_INDEX = topTabbar.numberOfSegments
                                    topTabbar.insertSegment(withTitle: title, at: TERMINAL_INDEX, animated: true)
                                } else {
                                    topTabbar.setTitle(title, forSegmentAt: TERMINAL_INDEX)
                                }
                                
                            }
                        }
                        
                        topTabbar.selectedSegmentIndex = TERMINAL_INDEX
                        
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
                        if let wc = self.tabControllers[adjustedIndex] as? WebViewController {
                            //wc.reload()
                        }
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
            break
        case "terminalSegue": break
            break
        default:
            break
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: Toolbar menu
    
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
    
    // MARK: Action
    
    
    @IBAction func badgeTapAction(_ sender: Any) {
        getAppDelegate().resetConnection()
    }
    
    @IBAction func unwindToMainFromScanner(segue: UIStoryboardSegue) {
        
        //        if let scannerViewController =  segue.source as? ScannerViewController {
        //            if let speciesIndex = scannerViewController.scannedSpecies, let beaconId = scannerViewController.scannedBeaconId {
        //
        //
        //                if getAppDelegate().checkApplicationState().rawValue != nil {
        //
        //                    let condition = getAppDelegate().checkApplicationState().rawValue
        //                    //realmDataController.clearInViewTerminal(withCondition: condition)
        //                    realmDataController.syncSpeciesObservations(withSpeciesIndex: speciesIndex, withCondition: condition, withActionType: "enter", withPlace: "species:\(speciesIndex)")
        //                    realmDataController.updateInViewTerminal(withSpeciesIndex: speciesIndex, withCondition: "artifact", withPlace: beaconId.asString)
        //                } else {
        //                    print("no condition")
        //                }
        //
        //
        //
        //
        //
        //            }
        //        }
        
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
        //realmDataController.clearInViewTerminal(withCondition: "artifact")
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

//MARK: ToolMenu

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



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

class MainContainerController: UIViewController{
    @IBOutlet var containerViews: [UIView]!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var topTabbar: TabSegmentedControl!
    @IBOutlet weak var topPanel: UIView!
    @IBOutlet weak var badgeImageView: UIImageView!
    
    var notificationTokens = [NotificationToken]()
    var runtimeResults: Results<Runtime>?
    var terminalRuntimeResults: Results<Runtime>?
    var runtimeNotificationToken: NotificationToken? = nil
    var terminalRuntimeNotificationToken: NotificationToken? = nil
    var needsTerminal = false
    var mainColor: UIColor?
    var terminalTabColor: UIColor?
    
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
        }
        
        prepareToolMenu()
        
        
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
                default:
                    break
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
                //terminalController.updateUI(withRuntimeResults: runtimeResults)
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
        
        if let groupIndex = realmDataController.getRealm().runtimeGroupIndex(), let sectionName = realmDataController.getRealm().runtimeSectionName(), let group = realmDataController.getRealm().group(withSectionName: sectionName, withGroupIndex: groupIndex), let groupName = group.name {
            topTabbar.setTitle("\(groupName.uppercased()) SPECIES ACCOUNTS", forSegmentAt: 0)
        }
        
        switch getAppDelegate().checkApplicationState() {
        case .objectGroup:
            badgeImageView.image = UIImage(named: "objectGroup")
        default:
            badgeImageView.image = UIImage(named: "placeGroup")
        }
        colorizeSelectedSegment()
    }
    
    func updateTabs(terminalRuntimeResults: Results<Runtime>) {
        if let terminalRuntime = terminalRuntimeResults.first, let speciesIndex = terminalRuntime.currentSpeciesIndex.value, let sectionName = terminalRuntime.currentSectionName, let action = terminalRuntime.currentAction {
            
            if let atype = ActionType(rawValue: action) {
                switch atype {
                case ActionType.entered:
                    topTabbar.insertSegment(withTitle: "\(sectionName.uppercased()) SPECIES \(speciesIndex)", at: 2, animated: true)
                    
                    terminalTabColor = UIColor.speciesColor(forIndex: speciesIndex, isLight: true)
                    for v in topTabbar.subviews {
                        v.backgroundColor = mainColor
                    }
                    
                    topTabbar.subviews.first?.backgroundColor = terminalTabColor
                   
                    topTabbar.selectedSegmentIndex = 2
                    
                    tabChanged(topTabbar)
                    
                    realmDataController.queryNutellaAllNotes(withType: "species", withRealmType: RealmType.terminalDB)
                default:
                    topTabbar.removeSegment(at: 2, animated: true)
                }
                
            }
            
        }
    }
    
    func showLogin() {
        let storyboard = UIStoryboard(name: "Popover", bundle: nil)
        let loginNavigationController = storyboard.instantiateViewController(withIdentifier: "loginNavigationController") as! UINavigationController
        
        self.present(loginNavigationController, animated: true, completion: {})
    }
    
    @IBAction func tabChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex < containerViews.count {
            
            let showView = containerViews[sender.selectedSegmentIndex]
            for (index,containerView) in containerViews.enumerated() {
                if index == sender.selectedSegmentIndex {
                    
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
                //            for tap in self.tapCollection {
                //                tap.isEnabled = false
                
            }
        }
    }
    
    func colorizeSelectedSegment() {
        let selectedSegmented = topTabbar.selectedSegmentIndex
        
        for (index, view) in topTabbar.subviews.enumerated() {
            
            
            if let terminalTabColor = terminalTabColor, index == 0 {
                view.backgroundColor = terminalTabColor
            } else {
                
                if index != selectedSegmented {
                    view.backgroundColor = mainColor?.lighterColor
                }else {
                    view.backgroundColor = mainColor

                }
            }
          
        
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else {
            return
        }
        switch id {
        case "speciesPageContainerController":
            if let svc = segue.destination as? SpeciePageContainerController {
                svc.topToolbarDelegate = self
            }
            break
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
    
    //Mark: Action
    func cameriaAction(sender: UIButton) {
        let imagePicker = UIImagePickerController()
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        
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
        self.performSegue(withIdentifier: "scannerSegue", sender: sender)
    }
    
    func photoAlbumAction(sender: UIButton) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.modalPresentationStyle = .overFullScreen
        imagePicker.modalTransitionStyle = .crossDissolve
        //imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
}

//Mark: TopToolbar

extension MainContainerController: TopToolbarDelegate {
    func changeAppearance(withColor color: UIColor) {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.mainColor = color
            self.topTabbar.backgroundColor = self.mainColor
            self.topPanel.backgroundColor = self.mainColor
            }, completion: nil)
            self.colorizeSelectedSegment()
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


//
//  ToolMenuViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 9/22/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Material

class ToolMenuViewController: UIViewController {

    enum ToolTypes: String {
        case PHOTO_LIB, CAMERA, SCREENSHOT, SCANNER, TRASH
        static let allTypes = [PHOTO_LIB, CAMERA, SCREENSHOT, SCANNER, TRASH]
    }
    
    enum ToolMenuActions: String {
        case OPEN, CLOSE, BRING_FRONT
    }
    
    let sideMenuButtonSpacing: CGFloat = 10.0
    
    var openAction = {}
    
    let speciesMenuTag = 69
    
    var toolMenuView: Menu?
    var toolMenuButtons = [UIView]()

    var sideMenuButtonDiameter: CGFloat {
        get {
            let screenHeight = UIScreen.main.bounds.height
            let numButtons: CGFloat = 12.0
            
            
            //button size
            let buttonSize = (screenHeight - (numButtons * sideMenuButtonSpacing)) / numButtons
            
            return floor(buttonSize)
        }
        
    }
    
   
    
    var toolMenuButtonCenter: CGPoint {
        get {
            //lower right
            let screenWidth = UIScreen.main.bounds.width
            
            let x: CGFloat = 10
            let y: CGFloat = screenWidth - (sideMenuButtonDiameter + 10)
            
            return CGPoint(x: x, y: y)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    internal func handleToolsMenuSelection() {
//                if toolsMenuView.menu.opened {
//                    toolsMenuView.menu.close()
//                    (toolsMenuView.menu.views?.first as? MaterialButton)?.animate(MaterialAnimation.rotate(rotation: 0))
//                } else {
//                    toolsMenuView.menu.open() {
//                        (v: UIView) in
//                        (v as? MaterialButton)?.pulse()
//                    }
//                    (toolsMenuView.menu.views?.first as? MaterialButton)?.animate(MaterialAnimation.rotate(rotation: 0.125))
//                }
    }
    
    func prepareToolMenu() {
        
        /// Diameter for FabButtons.
        let toolsButtonDiameter: CGFloat = sideMenuButtonDiameter - 5.0
        
        if let sv = toolMenuView {
            sv.removeFromSuperview()
            toolMenuView = Menu()
        } else {
            toolMenuView = Menu()
        }
        
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
        
        toolMenuView?.addSubview(toolsButton)
        
        toolMenuButtons.append(toolsButton)
        
        for tool in ToolTypes.allTypes {
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
                
//                scanButton.addTarget(self, action: #selector(scanAction), for: .touchUpInside)
                scanButton.width = sideMenuButtonDiameter
                scanButton.height = sideMenuButtonDiameter
                
                scanButton.shadowColor = Color.black
                scanButton.shadowOpacity = 0.5
                scanButton.shadowOffset = CGSize(width: 1.0, height: 0.0)
                
                toolMenuView?.addSubview(scanButton)
                
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
                
//                cameraButton.addTarget(self, action: #selector(cameraAction), for: .touchUpInside)
                cameraButton.width = sideMenuButtonDiameter
                cameraButton.height = sideMenuButtonDiameter
                
                cameraButton.shadowColor = Color.black
                cameraButton.shadowOpacity = 0.5
                cameraButton.shadowOffset = CGSize(width: 1.0, height: 0.0)
                
                toolMenuView?.addSubview(cameraButton)
                
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
                
//                photoLibButton.addTarget(self, action: #selector(photoAlbumAction), for: .touchUpInside)
                photoLibButton.width = sideMenuButtonDiameter
                photoLibButton.height = sideMenuButtonDiameter
                
                photoLibButton.shadowColor = Color.black
                photoLibButton.shadowOpacity = 0.5
                photoLibButton.shadowOffset = CGSize(width: 1.0, height: 0.0)
                
                toolMenuButtons.append(photoLibButton)
                
                
                toolMenuView?.addSubview(photoLibButton)
            case .SCREENSHOT:
                var image = UIImage(named: "ic_flash_on_white")!
                image = image.resizeToSize(CGSize(width: toolsButtonDiameter / 2, height: toolsButtonDiameter / 2))!
                
                
                let screenShotButton: FabButton = FabButton()
                
                
                
                screenShotButton.tintColor = Color.white
                screenShotButton.borderColor = Color.blue.accent3
                screenShotButton.backgroundColor = Color.blue.base
                
                screenShotButton.setImage(image, for: .normal)
                screenShotButton.setImage(image, for: .highlighted)
                
//                screenShotButton.addTarget(self, action: #selector(screenShotButton), for: .touchUpInside)
                screenShotButton.width = sideMenuButtonDiameter
                screenShotButton.height = sideMenuButtonDiameter
                
                screenShotButton.shadowColor = Color.black
                screenShotButton.shadowOpacity = 0.5
                screenShotButton.shadowOffset = CGSize(width: 1.0, height: 0.0)
                
                toolMenuView?.addSubview(screenShotButton)
                
                toolMenuButtons.append(screenShotButton)
                
                
            case .TRASH:
                break
            }
        }
        
        // Initialize the menu and setup the configuration options.
        toolMenuView?.direction = .up
        toolMenuView?.baseSize = CGSize(width: sideMenuButtonDiameter, height: sideMenuButtonDiameter)
        toolMenuView?.itemSize = CGSize(width: toolsButtonDiameter, height: toolsButtonDiameter)
        toolMenuView?.views = toolMenuButtons
        
        
        toolMenuView?.center = toolMenuButtonCenter
    }
    
    func removeSpeciesMenu() {
        for sv in UIApplication.shared.keyWindow!.subviews {
            if sv.tag == speciesMenuTag {
                sv.removeFromSuperview()
            }
        }
    }
    
    
}

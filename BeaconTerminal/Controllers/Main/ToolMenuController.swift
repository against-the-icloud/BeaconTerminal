//
//  ToolMenuController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 9/25/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Material

enum ToolMenuType: String {
    case PHOTO_LIB
    case CAMERA
    case SCREENSHOT
    case SCANNER
    
    static let allTypes = [PHOTO_LIB, CAMERA, SCREENSHOT, SCANNER]
    
    static let defaultTypes = [PHOTO_LIB, CAMERA, SCREENSHOT]
    
}

class ToolMenuController: MenuController {
    /// Menu diameter.
    private let baseSize = CGSize(width: 56, height: 56)
    
    /// Menu bottom inset.
    private let bottomInset: CGFloat = 24
    
    /// Menu right inset.
    private let rightInset: CGFloat = 24
    
    open override func prepare() {
        super.prepare()
        view.backgroundColor = Color.black
        
        prepareMenu()
    }
    
    open override func openMenu(completion: ((UIView) -> Void)? = nil) {
        super.openMenu(completion: completion)
        menu.views.first?.animate(animation: Animation.rotate(angle: 45))
    }
    
    open override func closeMenu(completion: ((UIView) -> Void)? = nil) {
        super.closeMenu(completion: completion)
        menu.views.first?.animate(animation: Animation.rotate(angle: 0))
    }
    
    /// Prepares the menuView.
    private func prepareMenu() {
        menu.baseSize = baseSize
        
        view.layout(menu)
            .size(baseSize)
            .bottom(bottomInset)
            .right(rightInset)
    }
}

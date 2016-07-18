//
//  ToolViews.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 7/17/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Material

class SpeciesMenu {
    
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
    
    
    var speciesMenuButtons = [UIView]()
    
    var speciesMenuButtonCenter: CGPoint {
        get {
            //lower left
            let screenHeight = CGRectGetHeight(UIScreen.mainScreen().bounds)
            
            let x: CGFloat = 10
            let y: CGFloat = screenHeight - (sideMenuButtonDiameter + 10)
            
            return CGPointMake(x, y)
        }
    }
    
    var speciesMenuView : MenuView = MenuView()
    
    init() {
        prepareSpeciesMenu()
    }
  
    /// Prepares the MenuView example.
    func prepareSpeciesMenu() {
        
        let speciesDiameter: CGFloat = sideMenuButtonDiameter - 1.0
        
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
//        addButton.shadowOpacity = 0.5
//        addButton.shadowOffset = CGSize(width: 1.0, height: 0.0)
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
            
            speciesButton.addTarget(self, action: #selector(self.handleSpeciesSelect), forControlEvents: .TouchUpInside)
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
    
    @objc internal func handleSpeciesMenuSelection() {
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
    
    @objc func handleSpeciesSelect(sender: FabButton) {
        LOG.debug("SPECIES SELECT \(sender.tag)")
        
    }
    
}
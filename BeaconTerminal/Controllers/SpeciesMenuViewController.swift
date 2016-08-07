//
//  speciesMenuView!Controller.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 7/18/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Material
import RealmSwift

class SpeciesMenuViewController: UIViewController {
    
    var dropTargets = [RelationshipDropView]()
    var speciesMenuButtons = [UIView]()
    let sideMenuButtonSpacing: CGFloat = 10.0
    var openAction = {}
    var allSpecies: Results<Species>?
    var fromSpecies: Species?
    
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
    
    var speciesMenuView: MenuView?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// Prepares the MenuView example.
    func prepareSpeciesMenu() {
        
        allSpecies = realm!.allObjects(ofType: Species.self)
        
        if let sv = speciesMenuView {
            sv.removeFromSuperview()
            speciesMenuView = MenuView()
        } else {
            speciesMenuView = MenuView()
        }
        
        /// Diameter for FabButtons.
        let speciesDiameter: CGFloat = sideMenuButtonDiameter - 1.0
        
        speciesMenuButtons = [UIView]()
        
        
        //create add button
        
        var image: UIImage? = UIImage(named: "tb_add_white")!
        image = image!.resizeToSize(CGSize(width: sideMenuButtonDiameter / 2, height: sideMenuButtonDiameter / 2))
        
        
        let addButton: FabButton = FabButton()
    
        
        addButton.tintColor = Color.white
        addButton.borderColor = Color.blue.accent3
        addButton.backgroundColor = Color.blue.base
        //
        addButton.setImage(image, for: .normal)
        addButton.setImage(image, for: .highlighted)
        
        addButton.addTarget(self, action: #selector(menuHandler), for: .touchUpInside)
        addButton.width = sideMenuButtonDiameter
        addButton.height = sideMenuButtonDiameter
        
        addButton.shadowColor = Color.black
        addButton.shadowOpacity = 0.5
        addButton.shadowOffset = CGSize(width: 1.0, height: 0.0)
        addButton.layer.zPosition = CGFloat(FLT_MAX)
        
        speciesMenuView!.addSubview(addButton)
        speciesMenuButtons.append(addButton)
        
        for index in 0 ... 10 {
            
            let species = allSpecies![index]
            
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
            
            let draggableImageView = DraggableSpeciesImageView(frame: CGRect(x: 0, y: 0, width: speciesDiameter, height: speciesDiameter))
            draggableImageView.isUserInteractionEnabled = true
            draggableImageView.image = speciesImage
            draggableImageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.dragSpecies(_:))))
            draggableImageView.species = species
            speciesMenuView!.addSubview(draggableImageView)
            speciesMenuButtons.append(draggableImageView)
        }
        
        
        // Initialize the menu and setup the configuration options.
        speciesMenuView!.menu.direction = .up
        speciesMenuView!.menu.interimSpace = sideMenuButtonSpacing
        speciesMenuView!.menu.baseSize = CGSize(width: speciesDiameter, height: speciesDiameter)
        speciesMenuView!.menu.itemSize = CGSize(width: sideMenuButtonDiameter, height: sideMenuButtonDiameter)
        speciesMenuView!.menu.views = speciesMenuButtons
        speciesMenuView!.backgroundColor = UIColor.blue
        
        speciesMenuView!.center = speciesMenuButtonCenter
        UIApplication.shared.keyWindow!.addSubview(speciesMenuView!)
        speciesMenuView?.isHidden = true
    }
    
    
    var dragAndDropView: UIView?
    var copyImageView: DraggableSpeciesImageView?
    var startCenter: CGPoint?
    var dragScaleFactor : CGFloat = 1.6
    var dragAlpha : CGFloat = 0.8
    var found = false
    
    func dragSpecies(_ gesture: UIPanGestureRecognizer) {
        _ = gesture.view!
        switch gesture.state {
        case .began:
            if dragAndDropView != nil {
                dragAndDropView?.removeFromSuperview()
                dragAndDropView = nil
            } else {
                
                dragAndDropView = UIView(frame: UIApplication.shared.keyWindow!.frame)
                dragAndDropView?.backgroundColor = UIColor.clear
                //dragAndDropView?.alpha = 0.5
                
                UIApplication.shared.keyWindow!.addSubview(dragAndDropView!)
                
                if let targetView = gesture.view as? UIImageView {
                    
                    copyImageView = (targetView as! DraggableSpeciesImageView).clone()
                    
                    
                    UIApplication.shared.keyWindow!.addSubview(copyImageView!)
                    dragAndDropView?.addSubview(copyImageView!)
                    
                    dragAndDropView?.isUserInteractionEnabled = true
                    
                    let location = gesture.location(in: dragAndDropView)
                    startCenter = location
                    copyImageView?.center = location;
                    
                    DragUtil.animateView(copyImageView!, scale: self.dragScaleFactor, alpha: self.dragAlpha, duration: 0.3)
                    
                    copyImageView?.smoothJiggle()
                }
            }
        case .changed:
            let translation = gesture.translation(in: dragAndDropView)
            
            //LOG.debug("TRANSLATE  \(translation) TARGET \(targetView)")
            
            
            copyImageView!.center = CGPoint(x: startCenter!.x + translation.x, y: startCenter!.y + translation.y)
            
            //LOG.debug("copy  \(copyImageView!.center)")
            found = false
            for t in dropTargets {
                let tPoint = gesture.location(in: t)
                if t.frame.contains(tPoint) {
                    t.highlight()
                    found = true
                } else {
                    t.unhighlight()
                }
            }
        case .ended:
            if found == false {
                //if we are NOT inside dropzone
                //snapback and remove
                //LOG.debug("WE ARE NOT COPYING NOT INSIDE")
                UIView.animate(withDuration: 0.4, animations: {
                    
                    self.copyImageView!.center = self.startCenter!
                    
                    self.copyImageView!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    self.copyImageView!.alpha = 1.0
                    
                    }, completion: {
                        (finished:Bool) in
                        self.copyImageView!.removeFromSuperview()
                        self.dragAndDropView?.removeFromSuperview()
                        self.found = false
                        
                })
            } else {
                //                let endpoint = gesture.locationInView(dragAndDropView)
                //                let endcenter = copyImageView!.center
                
                copyImageView?.stopJiggling()
                
                
                for t in dropTargets {
                    let tPoint = gesture.location(in: t)
                    if t.frame.contains(tPoint) {
                        
                        t.unhighlight()
                        
                        //LOG.debug("GOT IT \(t)")
                        
                        copyImageView!.center = tPoint
                        
                        self.found = false
                        
                        self.copyImageView!.removeFromSuperview()
                        
                        if t.addDraggableView(self.copyImageView!) {
                            DragUtil.animateViewWithCompletion(copyImageView!, scale: 1.0, alpha: 1.0, duration: 0.3, completion: {
                                self.dragAndDropView?.removeFromSuperview()
                                self.dragAndDropView = nil
                                self.found = false
                            })
                        } else {
                            
                            let location = gesture.location(in: dragAndDropView)
                            self.copyImageView?.center = location
                            dragAndDropView?.addSubview(self.copyImageView!)
                            UIView.animate(withDuration: 0.4, animations: {
                                
                                self.copyImageView!.center = self.startCenter!
                                self.copyImageView!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                self.copyImageView!.alpha = 1.0
                                
                                }, completion: {
                                    (finished:Bool) in
                                    self.copyImageView!.removeFromSuperview()
                                    self.copyImageView = nil
                                    self.dragAndDropView?.removeFromSuperview()
                                    self.dragAndDropView = nil
                                    self.found = false
                            })
                            
                        }
  
                    }
                }
            }
            break
        default:
            break
        }
    }
    
    func enableSpecies(_ speciesIndex: Int, isEnabled: Bool) {
        //+1 to the species index because of the add button
        let speciesView = speciesMenuButtons[speciesIndex+1]
        speciesView.isUserInteractionEnabled = isEnabled
    }
    
    func showMenu() {
        if let sv = speciesMenuView {
            sv.isHidden = false
        }
    }
    
    func isOpen() -> Bool {
        return speciesMenuView!.menu.isOpened
    }
    
    func openMenu() {
        if !speciesMenuView!.menu.isOpened {
            speciesMenuView!.open(completion: {
                (self.speciesMenuView!.menu.views?.first as? Button)?.backgroundColor = Color.green.base
            })
            
            (speciesMenuView!.menu.views?.first as? Button)?.animate(animation: Animation.rotate(rotation: 0.125))
        }
    }
    
    func closeMenu() {
        if speciesMenuView!.menu.isOpened {
            speciesMenuView!.close(completion: {
                (self.speciesMenuView!.menu.views?.first as? Button)?.backgroundColor = Color.blue.base
                (self.speciesMenuView!.menu.views?.first as? Button)?.animate(animation: Animation.rotate(rotation: 0))
            })
            
            
        }
    }
    
    func menuHandler() {
        if speciesMenuView!.menu.isOpened {
            closeMenu()
            openAction()
        } else {
            openMenu()
            openAction()
            
        }
        
    }
    
    
    /// Handle the menuView touch event.
    func handleSpeciesMenuSelection() {
        if speciesMenuView!.menu.isOpened {
            speciesMenuView!.menu.close()
            (speciesMenuView!.menu.views?.first as? Button)?.animate(animation: Animation.rotate(rotation: 0))
        } else {
            speciesMenuView!.menu.open() {
                (v: UIView) in
                (v as? Button)?.pulse()
            }
            (speciesMenuView!.menu.views?.first as? Button)?.animate(animation: Animation.rotate(rotation: 0.125))
        }
    }
    
    
}

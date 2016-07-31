//
//  CoverFlowViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 6/7/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

let CORNER_RADIUS = 10.0

class CoverFlowViewController: UIViewController {
    // MARK: IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    var notificationToken: NotificationToken? = nil
    
    var dataArray: [String] = []
    var currentGroup: Group = Group()
    let groupId = 0
    var allSpecies: Results<Species>?
    var selectedCell: CoverFlowCell?
    
    
    deinit {
        if notificationToken != nil {
            notificationToken?.stop()
        }
    }
    
    var species: Results<Species>?
    
    // Mark: Style properties
    
    
    var coverFlowLayout: UICollectionViewFlowLayout {
        return self.collectionView?.collectionViewLayout as! CenterCellCollectionViewFlowLayout
    }
    
    private struct StoryBoard {
        static let CellIdentifier = "CoverFlowCell"
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
  
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup() {
        //load test group
        let groups: Results<Group> = (realmDataController?.realm.allObjects(ofType: Group.self))!
        if groups.count > 0 {
            currentGroup = groups[groupId]
        }
        
        //        notificationToken = realmDataController?.realm.addNotificationBlock {
        //            notification in
        //            let groups: Results<Group> = (realmDataController?.realm.objects(Group.self))!
        //            if groups.count > 0 {
        //                self.currentGroup = groups[self.groupId]
        //            }
        //            LOG.debug("GROUP HAS BEEN UPDATED UI COLLECTION VIEW")
        //            self.collectionView.reloadData()
        //        }
        
        getAppDelegate().speciesViewController.openAction = {
            let centeredIndexPath = self.findCenterIndexPath()
            self.collectionView.scrollToItem(at: centeredIndexPath!, at: .centeredHorizontally, animated: true)
            let cell = self.collectionView.cellForItem(at: centeredIndexPath!) as! CoverFlowCell
            
            
            cell.expandButton.sendActions(for: .touchUpInside)
            LOG.debug("found \(cell.titleLabel.text)")
            
            self.makeCenteredCellStyle()
        }
        
    }
    
    
    func readSpeciesAndUpdate() {
        self.allSpecies = realm!.allObjects(ofType: Species.self)
        self.collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = IndexPath.init(item: 0, section: 0)
        
        //collectionView.scrollToItemAtIndexPath(secondItem, atScrollPosition: .CenteredHorizontally, animated: false)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setup()
        prepareCollectionViewCells()
        
        allSpecies = realm!.allObjects(ofType: Species.self)
        
        let nib = UINib(nibName: "CoverFlowCell", bundle: nil)
        
        collectionView.register(nib, forCellWithReuseIdentifier: "CoverFlowCell")
    }
    
    //let INSET : CGFloat = 0.0
    
    func prepareCollectionViewCells() {
        coverFlowLayout.minimumInteritemSpacing = 10
        coverFlowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        readSpeciesAndUpdate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    func findCenterIndexPath() -> IndexPath? {
        let centerPoint = CGPoint(x: self.collectionView.center.x + self.collectionView.contentOffset.x,
                                      y: self.collectionView.center.y + self.collectionView.contentOffset.y);
        if let centerCellIndexPath = self.collectionView.indexPathForItem(at: centerPoint) {
            //let index = collectionView!.indexPathForItemAtPoint(centerPoint)
            print((centerCellIndexPath as NSIndexPath).item)
            return centerCellIndexPath
        }
        return nil
    }
    
    func makeDraggingCellStyle() {
        let paths = self.collectionView.indexPathsForVisibleItems()
        for p in paths {
            if let cell = self.collectionView.cellForItem(at: p) {
                cell.borderColor = UIColor.white()
                cell.borderWidth = 1.0
            }
        }
    }
    
    func makeCenteredCellStyle() {
        if let centerIndexPath = findCenterIndexPath() {
            let paths = self.collectionView.indexPathsForVisibleItems()
            for p in paths {
                
                if let cell = self.collectionView.cellForItem(at: p) {
                    if p == centerIndexPath {
                        cell.borderColor = UIColor.blue()
                        cell.borderWidth = 1.0
                    } else {
                        cell.borderColor = UIColor.white()
                        cell.borderWidth = 1.0
                    }
                }
                
                
            }
            
        }
    }
    
}


extension CoverFlowViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = collectionView.frame.width
        
        if totalWidth > 1024 {
            return CGSize(width: 1024, height: 800)
        } else {
            return CGSize(width: 800, height: 600)
        }
    }
    
}

//MARK: UICollectionViewDataSource

extension CoverFlowViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let allSpecies = self.allSpecies {
            return allSpecies.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
  
        LOG.debug("SELECTED \(indexPath.item)")
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryBoard.CellIdentifier, for: indexPath) as! CoverFlowCell
        
        //use index to find species, then use group to find group and the latest entries for that species
        
        //initialize the cell
        
        cell.relationshipViews.forEach({
            (relationshipView: RelationshipsUIView) -> Void in
            relationshipView.dropView.subviews.forEach({ $0.removeFromSuperview() })
        }) // this gets things done
        
        
        
        if currentGroup.speciesObservations.count > 0 {
            let fromSpecies = self.allSpecies![indexPath.row]
            
            
            let speciesObservations: Results<SpeciesObservation> = currentGroup.speciesObservations.filter(using: "fromSpecies.index = \(fromSpecies.index)")
            
            
            //            LOG.debug("CELL fromSpecies: \(fromSpecies) speciesObservations: \(speciesObservations.count)")
            
            if !fromSpecies.name.isEmpty {
                cell.titleLabel.text = fromSpecies.name
            } else {
                cell.titleLabel.text = "Species \((indexPath as NSIndexPath).row)"
            }
            
            if !speciesObservations.isEmpty {
                cell.prepareCell(speciesObservations.first!, fromSpecies: fromSpecies)
                cell.expandButton.addTarget(self, action: #selector(CoverFlowViewController.expandCell(_:)), for: UIControlEvents.touchUpInside)
            }
            
            for rv in cell.relationshipViews {
                //add delegate
                rv.dropView.delegate = self       
            }
            
            cell.delegate = self
        }
        return cell
    }
    
    func minimizeCell(_ sender: UIButton) {
        
        //if it is  open
        if getAppDelegate().speciesViewController.isOpen() {
            getAppDelegate().speciesViewController.closeMenu()
        }
        
        
        //remove minimize cell target
        sender.removeTarget(self, action: #selector(CoverFlowViewController.minimizeCell(_:)), for: .touchUpInside)
        //add expand cell target
        sender.addTarget(self, action: #selector(CoverFlowViewController.expandCell(_:)), for: .touchUpInside)
        
        
        if let indexPathExpanded = findCenterIndexPath() {
            
            getAppDelegate().speciesViewController.dropTargets.removeAll()
            
            let cell = self.collectionView.cellForItem(at: indexPathExpanded) as! CoverFlowCell
            LOG.debug("MINI \(cell.titleLabel.text)")
            makeCenteredCellStyle()
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseIn, animations: ({
                
                cell.expandButton.transform = cell.expandButton.transform.rotate(CGFloat(M_PI));
                getAppDelegate().speciesViewController.enableSpecies((cell.fromSpecies?.index)!, isEnabled: true)
                
                cell.frame = cell.previousSize!
                self.collectionView.isScrollEnabled = true
                cell.isFullscreen = false
                
                
                //style
                cell.cornerRadius = CORNER_RADIUS
                
                self.coverFlowLayout.invalidateLayout()
                self.collectionView.layoutIfNeeded()
                
            }), completion: {
                (finished: Bool) -> Void in
                print("hey")
                //show species menu
            })
        }
        
    }

    
    func expandCell(_ sender: UIButton) {
        
        //if it is not open
        if !getAppDelegate().speciesViewController.isOpen() {
            getAppDelegate().speciesViewController.openMenu()
        }
        
        //remove expand cell target
        sender.removeTarget(self, action: #selector(CoverFlowViewController.expandCell(_:)), for: .touchUpInside)
        //add minimized cell target
        sender.addTarget(self, action: #selector(CoverFlowViewController.minimizeCell(_:)), for: .touchUpInside)
        
        
        let point = sender.convert(CGPoint.zero, to: collectionView)
        if let indexPathExpanded = collectionView.indexPathForItem(at: point) {
            UIView.animate(withDuration: 0.5, animations: {
                
                self.collectionView.scrollToItem(at: indexPathExpanded, at: .centeredHorizontally, animated: false)
                
                }, completion: {
                    (finished: Bool) -> Void in
                    let cell = self.collectionView.cellForItem(at: indexPathExpanded) as! CoverFlowCell
                    
                    LOG.debug("EXPANDING \(cell.titleLabel.text)")
                    
                    //add droptargets
                    
                    for rv in cell.relationshipViews {
                        getAppDelegate().speciesViewController.dropTargets.append(rv.dropView)
                        //add delegate
                        rv.dropView.delegate = self
                    }
               
                    if !cell.isFullscreen {
                        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: ({
                            getAppDelegate().speciesViewController.enableSpecies((cell.fromSpecies?.index)!, isEnabled: false)
                            cell.expandButton.transform = cell.expandButton.transform.rotate(CGFloat(M_PI));
                            cell.previousSize = cell.frame
                            cell.frame = self.collectionView.bounds
                            self.collectionView.isScrollEnabled = false
                            cell.isFullscreen = true
                            cell.superview?.bringSubview(toFront: cell)
                            
                            //style
                            cell.cornerRadius = 0.0
                            
                            self.coverFlowLayout.invalidateLayout()
                            self.collectionView.layoutIfNeeded()
                            
                        }), completion: {
                            (finished: Bool) -> Void in
                            print("hey")
                            //show species menu
                        })
                    }
            })
            
        }
    }
}

extension CoverFlowViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        makeDraggingCellStyle()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        makeCenteredCellStyle()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        makeCenteredCellStyle()
    }
}

extension CoverFlowViewController: PreferenceEditDelegate {
    
    func preferenceEdit(_ speciesObservation: SpeciesObservation, sender: UIButton) {
        let storyboard = UIStoryboard(name: "Preferences", bundle: nil)
        let navController = storyboard.instantiateViewController(withIdentifier: "preferencesNavigationController") as! UINavigationController
        
        if let pvc = navController.viewControllers.first as? PreferencesViewController {
            pvc.speciesObservation = speciesObservation
        }
        
   
     
      
 
        let tintColor =  UIColor.init(rgba: speciesObservation.fromSpecies!.color)
        navController.navigationBar.barTintColor = tintColor
        let contrast = tintColor.fullContrastColorAdjusted
                
        if contrast.isLight {
            navController.navigationBar.barStyle = .black
            navController.navigationBar.tintColor = contrast
        } else {
            navController.navigationBar.barStyle = .default
            navController.navigationBar.tintColor = contrast
        }
//
        navController.navigationBar.hideBottomHairline()
        navController.setToolbarHidden(false, animated: true)
        navController.toolbar.barTintColor = tintColor
        navController.toolbar.clipsToBounds = true
        navController.modalPresentationStyle = .popover
//        editNavigationController?.view.borderColor = tintColor
//        editNavigationController?.view.borderWidth = 3.0
//        
        if let items = navController.toolbar.items {
            for item in items {
                item.tintColor =  contrast
            }
            
        }
//
        self.present(navController, animated: true, completion: nil)
        
        if let pop = navController.popoverPresentationController {
            
            pop.sourceView = sender
            pop.sourceRect = sender.bounds
            pop.backgroundColor = tintColor
            pop.delegate = self
            //pop.passthroughViews = allPassthroughViews
            pop.permittedArrowDirections = .any
            navController.preferredContentSize = CGSize(width: 700, height: 425)
        }
    }

}

extension CoverFlowViewController: SpeciesRelationshipDetailDelegate {
    
    func presentRelationshipDetailView(_ sender: DraggableSpeciesImageView, relationship: Relationship, speciesObservation: SpeciesObservation) {
        
        if let species = sender.species {
            let storyboard = UIStoryboard(name: "CoverFlow", bundle: nil)
            let relationshipDetailViewController = storyboard.instantiateViewController(withIdentifier: "relationshipDetailViewController") as? RelationshipDetailViewController
            relationshipDetailViewController?.speciesObservation = speciesObservation
            relationshipDetailViewController?.sourceView = sender
            relationshipDetailViewController?.relationship = relationship 
            relationshipDetailViewController?.title = { ()->String in
    
                var rType = ""
                switch relationship.relationshipType {
                case "producer":
                    //left side mid
                    rType = "IS EATEN BY"
                case "consumer":
                    //left side mid
                    rType = "EATS"
                case "competes":
                    //left side mid
                    rType = "DEPENDS ON"
                default:
                    //nothing
                    print()
                }

                return "\(speciesObservation.fromSpecies!.name) \(rType) \(relationship.toSpecies!.name)"
            }()
            
            let navController = UINavigationController(rootViewController: relationshipDetailViewController!)
            let tintColor =  UIColor.init(rgba: species.color)
            navController.navigationBar.barTintColor = tintColor
            let contrast = tintColor.fullContrastColorAdjusted
            
            LOG.debug("contrast color \(contrast)")
            
            if contrast.isLight {
                navController.navigationBar.barStyle = .black
                navController.navigationBar.tintColor = contrast
            } else {
                navController.navigationBar.barStyle = .default
                navController.navigationBar.tintColor = contrast
            }
            
            navController.navigationBar.hideBottomHairline()
            navController.setToolbarHidden(false, animated: true)
            navController.toolbar.barTintColor = tintColor
            navController.toolbar.clipsToBounds = true
            navController.modalPresentationStyle = .popover
            relationshipDetailViewController?.view.borderColor = tintColor
            relationshipDetailViewController?.view.borderWidth = 3.0
            
            if let items = navController.toolbar.items {
                for item in items {
                    item.tintColor =  contrast
                }
                
            }
            
            self.present(navController, animated: true, completion: nil)
            
            if let pop = navController.popoverPresentationController {
                
                pop.sourceView = sender
                pop.sourceRect = sender.bounds
                pop.backgroundColor = tintColor
                pop.delegate = self
                //pop.passthroughViews = allPassthroughViews
                pop.permittedArrowDirections = .any
                navController.preferredContentSize = CGSize(width: 700, height: 425)
            }
        }
        
    }
}

extension CoverFlowViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        let navController: UINavigationController = popoverPresentationController.presentedViewController as! UINavigationController
        
        if navController.viewControllers.first is RelationshipDetailViewController {
            let relationshipDetailController: RelationshipDetailViewController = navController.viewControllers.first as! RelationshipDetailViewController
            relationshipDetailController.save()
        }
        
        return true
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    

}





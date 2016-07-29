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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func setup() {
        //load test group
        let groups: Results<Group> = (realmDataController?.realm.objects(Group))!
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
            self.collectionView.scrollToItemAtIndexPath(centeredIndexPath!, atScrollPosition: .CenteredHorizontally, animated: true)
            let cell = self.collectionView.cellForItemAtIndexPath(centeredIndexPath!) as! CoverFlowCell
            
            
            cell.expandButton.sendActionsForControlEvents(.TouchUpInside)
            LOG.debug("found \(cell.titleLabel.text)")
            
            self.makeCenteredCellStyle()
        }
        
    }
    
    
    func readSpeciesAndUpdate() {
        self.allSpecies = realm!.objects(Species.self)
        self.collectionView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        _ = NSIndexPath.init(forItem: 0, inSection: 0)
        
        //collectionView.scrollToItemAtIndexPath(secondItem, atScrollPosition: .CenteredHorizontally, animated: false)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setup()
        prepareCollectionViewCells()
        
        allSpecies = realm!.objects(Species.self)
        
        let nib = UINib(nibName: "CoverFlowCell", bundle: nil)
        
        collectionView.registerNib(nib, forCellWithReuseIdentifier: "CoverFlowCell")
    }
    
    //let INSET : CGFloat = 0.0
    
    func prepareCollectionViewCells() {
        coverFlowLayout.minimumInteritemSpacing = 10
        coverFlowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        readSpeciesAndUpdate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    func findCenterIndexPath() -> NSIndexPath? {
        let centerPoint = CGPointMake(self.collectionView.center.x + self.collectionView.contentOffset.x,
                                      self.collectionView.center.y + self.collectionView.contentOffset.y);
        if let centerCellIndexPath = self.collectionView.indexPathForItemAtPoint(centerPoint) {
            //let index = collectionView!.indexPathForItemAtPoint(centerPoint)
            print(centerCellIndexPath.item)
            return centerCellIndexPath
        }
        return nil
    }
    
    func makeDraggingCellStyle() {
        let paths = self.collectionView.indexPathsForVisibleItems()
        for p in paths {
            if let cell = self.collectionView.cellForItemAtIndexPath(p) {
                cell.borderColor = UIColor.whiteColor()
                cell.borderWidth = 1
            }
        }
    }
    
    func makeCenteredCellStyle() {
        if let centerIndexPath = findCenterIndexPath() {
            let paths = self.collectionView.indexPathsForVisibleItems()
            for p in paths {
                
                if let cell = self.collectionView.cellForItemAtIndexPath(p) {
                    if p == centerIndexPath {
                        cell.borderColor = UIColor.blueColor()
                        cell.borderWidth = 1
                    } else {
                        cell.borderColor = UIColor.whiteColor()
                        cell.borderWidth = 1
                    }
                }
                
                
            }
            
        }
    }
    
}


extension CoverFlowViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let totalWidth = CGRectGetWidth(collectionView.frame)
        
        if totalWidth > 1024 {
            return CGSizeMake(1024, 800)
        } else {
            return CGSizeMake(800, 600)
        }
    }
    
}

//MARK: UICollectionViewDataSource

extension CoverFlowViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let allSpecies = self.allSpecies {
            return allSpecies.count
        }
        return 0
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        LOG.debug("SELECTED \(indexPath.item)")
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StoryBoard.CellIdentifier, forIndexPath: indexPath) as! CoverFlowCell
        
        //use index to find species, then use group to find group and the latest entries for that species
        
        //initialize the cell
        
        cell.relationshipViews.forEach({
            (relationshipView: RelationshipsUIView) -> Void in
            relationshipView.dropView.subviews.forEach({ $0.removeFromSuperview() })
        }) // this gets things done
        
        
        
        if currentGroup.speciesObservations.count > 0 {
            let fromSpecies = self.allSpecies![indexPath.row]
            
            
            let speciesObservations: Results<SpeciesObservation> = currentGroup.speciesObservations.filter("fromSpecies.index = \(fromSpecies.index)")
            
            
            //            LOG.debug("CELL fromSpecies: \(fromSpecies) speciesObservations: \(speciesObservations.count)")
            
            if !fromSpecies.name.isEmpty {
                cell.titleLabel.text = fromSpecies.name
            } else {
                cell.titleLabel.text = "Species \(indexPath.row)"
            }
            
            if !speciesObservations.isEmpty {
                cell.prepareCell(speciesObservations.first!, fromSpecies: fromSpecies)
                cell.expandButton.addTarget(self, action: #selector(CoverFlowViewController.expandCell(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }
            
            for rv in cell.relationshipViews {
                //add delegate
                rv.dropView.delegate = self       
            }

            
        }
        return cell
    }
    
    func minimizeCell(sender: UIButton) {
        
        //if it is  open
        if getAppDelegate().speciesViewController.isOpen() {
            getAppDelegate().speciesViewController.closeMenu()
        }
        
        
        //remove minimize cell target
        sender.removeTarget(self, action: #selector(CoverFlowViewController.minimizeCell(_:)), forControlEvents: .TouchUpInside)
        //add expand cell target
        sender.addTarget(self, action: #selector(CoverFlowViewController.expandCell(_:)), forControlEvents: .TouchUpInside)
        
        
        if let indexPathExpanded = findCenterIndexPath() {
            
            getAppDelegate().speciesViewController.dropTargets.removeAll()
            
            let cell = self.collectionView.cellForItemAtIndexPath(indexPathExpanded) as! CoverFlowCell
            LOG.debug("MINI \(cell.titleLabel.text)")
            makeCenteredCellStyle()
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseIn, animations: ({
                
                cell.expandButton.transform = CGAffineTransformRotate(cell.expandButton.transform, CGFloat(M_PI));
                getAppDelegate().speciesViewController.enableSpecies((cell.fromSpecies?.index)!, isEnabled: true)
                
                cell.frame = cell.previousSize!
                self.collectionView.scrollEnabled = true
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
    
    
    func expandCell(sender: UIButton) {
        
        //if it is not open
        if !getAppDelegate().speciesViewController.isOpen() {
            getAppDelegate().speciesViewController.openMenu()
        }
        
        //remove expand cell target
        sender.removeTarget(self, action: #selector(CoverFlowViewController.expandCell(_:)), forControlEvents: .TouchUpInside)
        //add minimized cell target
        sender.addTarget(self, action: #selector(CoverFlowViewController.minimizeCell(_:)), forControlEvents: .TouchUpInside)
        
        
        let point = sender.convertPoint(CGPointZero, toView: collectionView)
        if let indexPathExpanded = collectionView.indexPathForItemAtPoint(point) {
            UIView.animateWithDuration(0.5, animations: {
                
                self.collectionView.scrollToItemAtIndexPath(indexPathExpanded, atScrollPosition: .CenteredHorizontally, animated: false)
                
                }, completion: {
                    (finished: Bool) -> Void in
                    let cell = self.collectionView.cellForItemAtIndexPath(indexPathExpanded) as! CoverFlowCell
                    
                    LOG.debug("EXPANDING \(cell.titleLabel.text)")
                    
                    //add droptargets
                    
                    for rv in cell.relationshipViews {
                        getAppDelegate().speciesViewController.dropTargets.append(rv.dropView)
                        //add delegate
                        rv.dropView.delegate = self
                    }
               
                    if !cell.isFullscreen {
                        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: ({
                            getAppDelegate().speciesViewController.enableSpecies((cell.fromSpecies?.index)!, isEnabled: false)
                            cell.expandButton.transform = CGAffineTransformRotate(cell.expandButton.transform, CGFloat(M_PI));
                            cell.previousSize = cell.frame
                            cell.frame = self.collectionView.bounds
                            self.collectionView.scrollEnabled = false
                            cell.isFullscreen = true
                            cell.superview?.bringSubviewToFront(cell)
                            
                            //style
                            cell.cornerRadius = 0
                            
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
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        makeDraggingCellStyle()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        makeCenteredCellStyle()
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        makeCenteredCellStyle()
    }
}

extension CoverFlowViewController: SpeciesRelationshipDetailDelegate {
    
    func presentRelationshipDetailView(sender: DraggableSpeciesImageView, relationship: Relationship, speciesObservation: SpeciesObservation) {
        
        if let species = sender.species {
            let storyboard = UIStoryboard(name: "CoverFlow", bundle: nil)
            let relationshipDetailViewController = storyboard.instantiateViewControllerWithIdentifier("relationshipDetailViewController") as? RelationshipDetailViewController
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
                navController.navigationBar.barStyle = .Black
                navController.navigationBar.tintColor = contrast
            } else {
                navController.navigationBar.barStyle = .Default
                navController.navigationBar.tintColor = contrast
            }
            
            navController.navigationBar.hideBottomHairline()
            navController.setToolbarHidden(false, animated: true)
            navController.toolbar.barTintColor = tintColor
            navController.toolbar.clipsToBounds = true
            navController.modalPresentationStyle = .Popover
            relationshipDetailViewController?.view.borderColor = tintColor
            relationshipDetailViewController?.view.borderWidth = 3.0
            
            if let items = navController.toolbar.items {
                for item in items {
                    item.tintColor =  contrast
                }
                
            }
            
            self.presentViewController(navController, animated: true, completion: nil)
            
            if let pop = navController.popoverPresentationController {
                
                pop.sourceView = sender
                pop.sourceRect = sender.bounds
                pop.backgroundColor = tintColor
                pop.delegate = self
                //pop.passthroughViews = allPassthroughViews
                pop.permittedArrowDirections = .Any
                navController.preferredContentSize = CGSizeMake(700, 425)
            }
        }
        
    }
}

extension CoverFlowViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
        let navController: UINavigationController = popoverPresentationController.presentedViewController as! UINavigationController
        let relationshipDetailController: RelationshipDetailViewController = navController.viewControllers.first as! RelationshipDetailViewController
        relationshipDetailController.save()
        return true
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    

}





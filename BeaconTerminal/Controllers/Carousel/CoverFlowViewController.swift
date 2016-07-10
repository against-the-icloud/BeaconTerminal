//
//  CoverFlowViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 6/7/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Spring
import RealmSwift

class CoverFlowViewController: UIViewController {
    // MARK: IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    var notificationToken: NotificationToken? = nil
    
    var dataArray: [String] = []
    var currentGroup: Group = Group()
    let groupId = 0
    var allSpecies : Results<Species>?
    
    deinit {
        if notificationToken != nil {
            notificationToken?.stop()
        }
    }
    
    var species: Results<Species>?
    
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
        let groups : Results<Group> = (getAppDelegate().realmDataController?.realm.objects(Group))!
        if groups.count > 0 {
            currentGroup = groups[groupId]
        }
        
        notificationToken = getAppDelegate().realmDataController?.realm.addNotificationBlock {
            notification in
            let groups : Results<Group> = (getAppDelegate().realmDataController?.realm.objects(Group.self))!
            if groups.count > 0 {
                self.currentGroup = groups[self.groupId]
            }
            self.collectionView.reloadData()
        }
    }
    
    
    func readDBAndUpdateUI() {
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
        
        // LOG.debug("estimated size \(coverFlowLayout.estimatedItemSize) \(coverFlowLayout.itemSize) ")
        
        //        let screenWidth = CGRectGetWidth(UIScreen.mainScreen().bounds);
        //        LOG.debug("screen width \(screenWidth) est size \(coverFlowLayout.estimatedItemSize)")
        //        coverFlowLayout.estimatedItemSize = CGSizeMake(screenWidth - 200.0, 500);
        
        //        notificationToken = groups?[0].speciesObservations.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
        //            guard let collectionView = self?.collectionView else { return }
        //            switch changes {
        //            case .Initial:
        //                // Results are now populated and can be accessed without blocking the UI
        //                collectionView.reloadData()
        //                break
        //            case .Update(_, _, let _, _):
        //                // Query results have changed, so apply them to the UITableView
        //                //add update methods
        //                break
        //            case .Error(let error):
        //                // An error occurred while opening the Realm file on the background worker thread
        //                fatalError("\(error)")
        //                break
        //            }
        //        }
        
        
    }
    
    //let INSET : CGFloat = 0.0
    
    func prepareCollectionViewCells() {
        
//        coverFlowLayout.minimumInteritemSpacing = 0.0
//        
//        //space between cells
//        //coverFlowLayout.minimumLineSpacing = 60.0
//        //        coverFlowLayout.sectionInset = UIEdgeInsetsZero
//        //        collectionView.contentInset = UIEdgeInsetsMake(INSET, 0.0, INSET, 0.0)
//        
//        //        collectionView.contentInset = UIEdgeInsetsZero
//        collectionView.scrollIndicatorInsets = UIEdgeInsetsZero;
        
        coverFlowLayout.minimumInteritemSpacing = 10
        coverFlowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        readDBAndUpdateUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //LOG.debug("bound \(self.collectionView.bounds.size.width) item size \(coverFlowLayout.itemSize)")
        //        if coverFlowLayout.itemSize.
        //        coverFlowLayout.itemSize = CGSizeMake(self.collectionView.bounds.size.width - (coverFlowLayout.minimumLineSpacing*2), 100);
        
    }
    
    private func findCenterIndexPath() -> NSIndexPath? {
        let centerPoint = CGPointMake(self.collectionView.center.x + self.collectionView.contentOffset.x,
                                      self.collectionView.center.y + self.collectionView.contentOffset.y);
        if let centerCellIndexPath = self.collectionView.indexPathForItemAtPoint(centerPoint) {
            //let index = collectionView!.indexPathForItemAtPoint(centerPoint)
            print(centerCellIndexPath.item)
            
            //            let obs = self.collectionView.cellForItemAtIndexPath(centerCellIndexPath) as? ObservationCollectionViewCell
            //            obs?.borderColor = UIColor.blackColor()
            //            obs?.borderWidth = 4
            return centerCellIndexPath
        }
        
        
        return nil
    }
    
    
    let minimumSize: CGFloat = 800.0 // A cell's width or height won't ever be smaller than this
    
    func cellWidthForViewWidth(viewWidth: CGFloat) -> CGFloat {
        // Determine the largest number of cells that could possibly fit in a row, based on the cell's minimum size
        var numberOfCellsPerRow = Int(viewWidth / minimumSize)
        
        // Adjust for interitem spacing and section insets
        let availableWidth = viewWidth - coverFlowLayout.sectionInset.left - coverFlowLayout.sectionInset.right - coverFlowLayout.minimumInteritemSpacing * CGFloat(numberOfCellsPerRow - 1)
        numberOfCellsPerRow = Int(availableWidth / minimumSize)
        
        return availableWidth / CGFloat(numberOfCellsPerRow) // Make this an integral width if desired
    }
}


extension CoverFlowViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if let fl = collectionViewLayout as? UICollectionViewFlowLayout {
            let aspectRatio: CGFloat = 4.0/3.0
            
            LOG.debug("frame \(collectionView.frame) item size \(fl.itemSize)")
            
            
            let totalWidth = CGRectGetWidth(collectionView.frame)
            
            if totalWidth > 1024 {
                return CGSizeMake(1024, 800)
            } else {
                return CGSizeMake(800, 600)
            }
            
            
        }
//
//            CGRectGetWidth(collectionView.frame)
//            
//             var numberOfCellsPerRow = Int(CGRectGetWidth(collectionView.frame) / minimumSize)
//            
//            // Always use an item count of at least 1
//            let itemsPerRow = CGFloat(max(3, 1))
//            
//            // Calculate the sum of the spacing between cells
//            let totalSpacing = fl.minimumInteritemSpacing * (itemsPerRow - 1.0)
//            
//            // Calculate how wide items should be
//            newItemSize.width = (collectionView.bounds.size.width - totalSpacing) / itemsPerRow
//            
//            // Use the aspect ratio of the current item size to determine how tall the items should be
//            if fl.itemSize.height > 0 {
//                let itemAspectRatio = fl.itemSize.width / fl.itemSize.height
//                newItemSize.height = newItemSize.width / itemAspectRatio
//            }
//            
//            // Set the new item size
//            //fl.itemSize = newItemSize
//            //let cellWidth = cellWidthForViewWidth(CGRectGetWidth(collectionView.frame))
//            
//            
//            
//            //let cellHeight = cellWidth / aspectRatio
//            
//            
////            LOG.debug("cellheight \(cellHeight) cellWidth \(cellWidth) frame \(collectionView.frame) item size \(fl.itemSize)")
//            
//            return newItemSize
//            
//        }
        
       return CGSizeMake(200, 200)
    }
    //
    //
    //
    //        
    ////        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ObservationCollectionViewCell {
    ////            cell.frame = CGRectMake(0, 0, CGRectGetWidth(collectionView.frame), 20);
    ////            // SET YOUR CONTENT
    ////            cell.layoutIfNeeded()
    ////            return cell.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
    ////        } else {
    ////            return CGSizeMake(200, 200)
    ////        }
    //        
    //        if let fl = collectionViewLayout as? UICollectionViewFlowLayout {
    //            
    //            return CGSize(width: coverFlowLayout.itemSize.width, height:coverFlowLayout.itemSize.height * 0.7)
    //            
    //            
    //            LOG.debug("FL bound \(self.collectionView.bounds.size) item size \(coverFlowLayout.itemSize) estimated item size \(coverFlowLayout.estimatedItemSize)")
    //            
    //            //ipad
    //            if self.collectionView.bounds.size.width <= 1024 {
    //                let newSize = CGSizeMake(self.collectionView.bounds.size.width * 0.7, self.collectionView.bounds.size.height * 0.7)
    //                collectionView.contentInset = UIEdgeInsetsMake(INSET, 0.0, 100, 0.0)
    //
    //                return newSize
    //            } else {
    //                return fl.itemSize
    //            }
    //            
    //            
    // 
    //
    //            
    //            return fl.itemSize
    //        }
    //        
    //         return CGSizeMake(200, 200)
    //
    //    }
    ////
    
    
}

extension CoverFlowViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        let paths = self.collectionView.indexPathsForVisibleItems()
        for p in paths {
            
            if let cell = self.collectionView.cellForItemAtIndexPath(p) {
                
                cell.borderColor = UIColor.whiteColor()
                cell.borderWidth = 2
                
            }
            
            
        }
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        if let centerIndexPath = findCenterIndexPath() {
            let paths = self.collectionView.indexPathsForVisibleItems()
            for p in paths {
                
                if let cell = self.collectionView.cellForItemAtIndexPath(p) {
                    if p == centerIndexPath {
                        cell.borderColor = UIColor.redColor()
                        cell.borderWidth = 4
                    } else {
                        cell.borderColor = UIColor.whiteColor()
                        cell.borderWidth = 2
                    }
                }
                
                
            }
            
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
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StoryBoard.CellIdentifier, forIndexPath: indexPath) as! CoverFlowCell
        
        //use index to find species, then use group to find group and the latest entries for that species
        
        
        if currentGroup.speciesObservations.count > 0 {
            let fromSpecies = self.allSpecies![indexPath.row]
            
            let speciesObservations : Results<SpeciesObservation> = currentGroup.speciesObservations.filter("fromSpecies.index = \(fromSpecies.index)")
            
            if !fromSpecies.name.isEmpty {
                
                cell.titleLabel.text = fromSpecies.name
            } else {
                cell.titleLabel.text = "Species \(indexPath.row)"
            }
        
            cell.prepareCell(speciesObservations, fromSpecies: fromSpecies)
        }

        return cell
    }
}






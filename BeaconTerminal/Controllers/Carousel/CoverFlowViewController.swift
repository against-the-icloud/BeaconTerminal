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
        return self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    private struct StoryBoard {
        static let CellIdentifier = "CoverFlowCell"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func setup() {
        //load test group
        let groups : Results<Group> = (realmDataController?.realm.objects(Group))!
        if groups.count > 0 {
            currentGroup = groups[groupId]
        }
        
        notificationToken = realmDataController?.realm.addNotificationBlock {
            notification in
            let groups : Results<Group> = (realmDataController?.realm.objects(Group.self))!
            if groups.count > 0 {
                self.currentGroup = groups[self.groupId]
            }
            LOG.debug("GROUP HAS BEEN UPDATED UI COLLECTION VIEW")
            self.collectionView.reloadData()
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
            let totalWidth = CGRectGetWidth(collectionView.frame)
            
            if totalWidth > 1024 {
                return CGSizeMake(1024, 800)
            } else {
                return CGSizeMake(800, 600)
            }
    }
   
}

extension CoverFlowViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        let paths = self.collectionView.indexPathsForVisibleItems()
        for p in paths {
            
            if let cell = self.collectionView.cellForItemAtIndexPath(p) {
                cell.borderColor = UIColor.whiteColor()
                cell.borderWidth = 1
                
            }
            
            
        }
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
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
        
        //initialize the cell
        
        cell.relationshipViews.forEach({ (relationshipView: RelationshipsUIView) -> Void in
            
            relationshipView.dropView.subviews.forEach({$0.removeFromSuperview()})
            
        }) // this gets things done
        
        
        
        if currentGroup.speciesObservations.count > 0 {
            let fromSpecies = self.allSpecies![indexPath.row]
            
            
            let speciesObservations : Results<SpeciesObservation> = currentGroup.speciesObservations.filter("fromSpecies.index = \(fromSpecies.index)")
            
            
//            LOG.debug("CELL fromSpecies: \(fromSpecies) speciesObservations: \(speciesObservations.count)")
            
            if !fromSpecies.name.isEmpty {
                cell.titleLabel.text = fromSpecies.name
            } else {
                cell.titleLabel.text = "Species \(indexPath.row)"
            }
        
            if !speciesObservations.isEmpty {
                cell.prepareCell(speciesObservations.first!, fromSpecies: fromSpecies)
            }
            
        }

        return cell
    }
}






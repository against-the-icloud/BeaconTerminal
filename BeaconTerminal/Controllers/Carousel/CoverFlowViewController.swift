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
        static let CellIdentifier = "observationCell"
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
    
    let INSET : CGFloat = 0.0
    
    func prepareCollectionViewCells() {
        
        coverFlowLayout.minimumInteritemSpacing = 0.0
        
        //space between cells
        coverFlowLayout.minimumLineSpacing = 60.0
        coverFlowLayout.sectionInset = UIEdgeInsetsZero
        collectionView.contentInset = UIEdgeInsetsMake(INSET, 0.0, INSET, 0.0)

//        collectionView.contentInset = UIEdgeInsetsZero
        collectionView.scrollIndicatorInsets = UIEdgeInsetsZero;

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


}

extension CoverFlowViewController: UICollectionViewDelegate {


}



extension CoverFlowViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
//        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ObservationCollectionViewCell {
//            cell.frame = CGRectMake(0, 0, CGRectGetWidth(collectionView.frame), 20);
//            // SET YOUR CONTENT
//            cell.layoutIfNeeded()
//            return cell.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
//        } else {
//            return CGSizeMake(200, 200)
//        }
        
        if let fl = collectionViewLayout as? UICollectionViewFlowLayout {
            //LOG.debug("FL bound \(self.collectionView.bounds.size) item size \(coverFlowLayout.itemSize) estimated item size \(coverFlowLayout.estimatedItemSize)")
            
            //ipad
            if self.collectionView.bounds.size.width <= 1024 {
                let newSize = CGSizeMake(self.collectionView.bounds.size.width * 0.7, self.collectionView.bounds.size.height * 0.7)
                return newSize
            } else {
                return fl.itemSize
            }
            
            
 

            
            return fl.itemSize
        }
        
         return CGSizeMake(200, 200)

    }
//

}

extension CoverFlowViewController: UIScrollViewDelegate {

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        let paths = self.collectionView.indexPathsForVisibleItems()
        for p in paths {

            if let cell = self.collectionView.cellForItemAtIndexPath(p) {

                cell.borderColor = UIColor.clearColor()
                cell.borderWidth = 0

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
                        cell.borderColor = UIColor.clearColor()
                        cell.borderWidth = 0
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StoryBoard.CellIdentifier, forIndexPath: indexPath) as! ObservationCollectionViewCell

        //use index to find species, then use group to find group and the latest entries for that species


//        
//            var test = currentGroup.speciesObservations.filter("toSpecies.index = \(indexPath.row)")
//            test = (test as? Results<SpeciesObservation>!)!
//            
//            var t = "\(indexPath.row)\n"

//            for v in test {
//                t += "\n"
//                t += "toIndex \(v.toSpecies!.index) fromIndex: \(v.toSpecies!.index) relationship: \(v.relationship) \n"
//            }
           // cell.testTextView.text = t
        


//        let label = dataArray[indexPath.row]

//        if let species = species?[indexPath.row] {
//            cell.species = species
//        }

        return cell
    }

}






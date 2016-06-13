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

    var notificationToken: NotificationToken?

    let WINDOW_WIDTH = UIScreen.mainScreen().bounds.width
    let WINDOW_HEIGHT = UIScreen.mainScreen().bounds.height

    var dataArray: [String] = []

    deinit {
        if notificationToken != nil {
            notificationToken?.stop()
        }
    }

    var species: Results<Critter>?
    
    
    private struct StoryBoard {
        static let CellIdentifier = "observationCell"
    }
    

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {


        // Create the original set of data
        let originalArray  = ["ONE","TWO","THREE","FOUR","FIVE"]


        // Grab references to the first and last items
        // They're typed as id so you don't need to worry about what kind
        // of objects the originalArray is holding

        let firstItem = originalArray.first
        let lastItem = originalArray.last
        var workingArray = originalArray

        // Add the copy of the last item to the beginning
        workingArray.insert(lastItem!, atIndex: 0)
        // Add the copy of the first item to the end
        workingArray.append(firstItem!)
    // Update the collection view's data source property
        self.dataArray = workingArray

        notificationToken = realm!.addNotificationBlock { notification, realm in
            self.species = realm.objects(Critter.self)
            LOG.debug("SPECIES \(self.species)")
            self.collectionView.reloadData()
        }
    }

  

   func readDBAndUpdateUI() {
       self.species = realm!.objects(Critter)
        self.collectionView.reloadData()
   }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let secondItem = NSIndexPath.init(forItem: 0, inSection: 0)
        
        collectionView.scrollToItemAtIndexPath(secondItem, atScrollPosition: .CenteredHorizontally, animated: false)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self

    }
    override func viewWillAppear(animated: Bool) {
        readDBAndUpdateUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
extension CoverFlowViewController : UICollectionViewDelegateFlowLayout {
    
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
                            cell.borderColor = UIColor.blackColor()
                            cell.borderWidth = 4
                        } else {
                            cell.borderColor = UIColor.clearColor()
                            cell.borderWidth = 0
                        }
                    }
                    
                    
                    
                }
            
        }
        
        
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
//        let views = self.collectionView.visibleCells() as? [ObservationCollectionViewCell]
//        LOG.debug("VISIBLE -----")
//        for v in views! {
//                LOG.debug("\(v.testLabel.text)")
//        }
        
//        let cv = self.collectionView.collectionViewLayout as? CenterCellCollectionViewFlowLayout
//        
//        let items = self.collectionView.indexPathsForVisibleItems()
//        
//        for i in items {
//            let result = cv?.indexPathIsCentered(i)
//            LOG.debug("IP \(i) result \(result)")
//        }
    }
}

//MARK: UICollectionViewDataSource
extension CoverFlowViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {


        if species != nil {
            return species!.count
        }
        
        return 0
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StoryBoard.CellIdentifier, forIndexPath: indexPath) as! ObservationCollectionViewCell


//        let label = dataArray[indexPath.row]
        cell.testLabel.text = "\(indexPath.row)"
//        if let species = species?[indexPath.row] {
//            cell.species = species
//        }
        
        return cell
    }

}






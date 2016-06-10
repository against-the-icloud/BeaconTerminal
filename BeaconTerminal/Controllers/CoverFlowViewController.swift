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


    deinit {
        if notificationToken != nil {
            notificationToken?.stop()
        }
    }

    var species: Results<Critter>?
//    var species: Results<Critter> {
//
//        get {
//            //LOG.debug("\(DataManager.sharedInstance.realm!.objects(Critter))")
//            return DataManager.sharedInstance.realm!.objects(Critter)
//        }
//        
//        didSet {
//            species =
//        }
//
//    }
//    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        notificationToken = realm!.addNotificationBlock { notification, realm in
            self.species = realm.objects(Critter.self)
            LOG.debug("SPECIES \(self.species)")
            self.collectionView.reloadData()
        }
    }

    override func viewWillAppear(animated: Bool) {
        readDBAndUpdateUI()
    }


   func readDBAndUpdateUI() {
       self.species = realm!.objects(Critter)
       self.collectionView.reloadData()
   }
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    private struct StoryBoard {
        static let CellIdentifier = "observationCell"
    }
}

//MARK: UICollectionViewDataSource
extension CoverFlowViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        return species!.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StoryBoard.CellIdentifier, forIndexPath: indexPath) as! ObservationCollectionViewCell
        
        if let species = species?[indexPath.row] {
            cell.species = species
        }
        
        return cell
    }

}

extension CoverFlowViewController : UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        let size:CGSize = CGSizeMake(WINDOW_WIDTH, (WINDOW_WIDTH)*1.203460)
        return size

    }

    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
}

//extension CoverFlowViewController: UIScrollViewDelegate {
//    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
//        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
//        var offset = targetContentOffset.memory
//
//        let index = (offset.x + scrollView.contentInset.left)/cellWidthIncludingSpacing
//        let roundedIndex = round(index)
//        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
//        targetContentOffset.memory = offset
//    }
//
//}

//extension InfiniteScrollingViewController : UICollectionViewDelegateFlowLayout {
//    func collectionView(collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//
//        let size:CGSize = CGSizeMake(WINDOW_WIDTH, (WINDOW_WIDTH)*1.203460)
//        return size
//
//    }
//
//    func collectionView(collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//        return UIEdgeInsetsMake(0, 0, 0, 0)
//    }
//
//}

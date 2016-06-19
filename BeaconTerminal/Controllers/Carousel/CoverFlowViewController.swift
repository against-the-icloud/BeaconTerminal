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
    var group: Group?

    deinit {
        if notificationToken != nil {
            notificationToken?.stop()
        }
    }

    var species: Results<Species>?


    private struct StoryBoard {
        static let CellIdentifier = "observationCell"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {

        notificationToken = realm!.addNotificationBlock {
            notification, realm in
            self.species = realm.objects(Species.self)
            LOG.debug("SPECIES \(self.species)")
            self.collectionView.reloadData()
        }
    }


    func readDBAndUpdateUI() {
        self.species = realm!.objects(Species)
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

        _ = realm!.objects(Group.self)
        
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

extension CoverFlowViewController: UICollectionViewDelegateFlowLayout {

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
        if group?.speciesObservations != nil {
            return (group?.speciesObservations.count)!
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






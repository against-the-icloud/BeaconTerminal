
import Foundation
import UIKit
import XLPagerTabStrip
import RealmSwift

class ClassContributionsCollectionViewController: UICollectionViewController, IndicatorInfoProvider {
    
    var itemInfo: IndicatorInfo = "CLASS CONTRIBUTIONS"
    var votes : List<Vote>?
    var currentSelectedSpecies = 0
    
    init(itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.registerNib(UINib(nibName: "VoteCell", bundle: nil), forCellWithReuseIdentifier: "voteCell")

        self.currentSelectedSpecies = DataManager.sharedInstance.currentSelectedSpecies
        self.votes = DataManager.sharedInstance.createVotes(self.currentSelectedSpecies)
        LOG.debug("VOTES \(votes!.count)")
//        self.collectionView!.registerClass(VoteCell.self, forCellWithReuseIdentifier: "voteCell")
    }

    // MARK: - UICollectionView

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
  

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("voteCell", forIndexPath: indexPath) as! VoteCell


        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //

    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return votes!.count
    }
    


    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}


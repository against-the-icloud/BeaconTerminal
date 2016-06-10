
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

       //        self.collectionView!.registerClass(VoteCell.self, forCellWithReuseIdentifier: "voteCell")
        self.refreshVotes()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - UICollectionView

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
  

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("voteCell", forIndexPath: indexPath) as! VoteCell

        let vote = votes![indexPath.row]

        _ = vote.mainCritter!
        let versusSpecies = vote.versusCritter!

        //LOG.debug("VERSUS INDEX \(versusSpecies)")

        cell.mainSpeciesImageView.image = UIImage(named: DataManager.generateImageFileNameFromIndex(currentSelectedSpecies) )
        cell.versusSpeciesImageView.image = UIImage(named: DataManager.generateImageFileNameFromIndex(versusSpecies.index) )
        cell.votesLabel.text = "Votes: \(String(vote.voteCount)) out of 4"

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
    
    func refreshVotes() {
//     refreshVotes   self.currentSelectedSpecies = DataManager.currentSelectedSpecies
//        self.votes?.removeAll()
//        self.votes = DataManager.sharedInstance.createVotes(self.currentSelectedSpecies)
//        LOG.debug("VOTES \(votes!.count)")
//        self.collectionView?.reloadData()

    }


    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}


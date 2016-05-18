

import Foundation
import XLPagerTabStrip

class PageViewController: ButtonBarPagerTabStripViewController {
    
    @IBOutlet weak var shadowView: UIView!
    let blueInstagramColor = UIColor(red: 37/255.0, green: 111/255.0, blue: 206/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        // change selected bar color
        settings.style.buttonBarBackgroundColor = .whiteColor()
        settings.style.buttonBarItemBackgroundColor = .whiteColor()
        settings.style.selectedBarBackgroundColor = blueInstagramColor
        settings.style.buttonBarItemFont = .boldSystemFontOfSize(14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .blackColor()
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .blackColor()
            newCell?.label.textColor = self?.blueInstagramColor
        }
        super.viewDidLoad()
    }
    
    // MARK: - PagerTabStripDataSource
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {

        let storyboard = UIStoryboard(name: "CollectionBoard", bundle: nil)

        // [2] Create an instance of the storyboard's initial view controller.
        let classContributionsCollectionViewController = storyboard.instantiateViewControllerWithIdentifier("voteCollectionViewController") as! ClassContributionsCollectionViewController

        // [3] Display the new view controller.
        let groupContributionViewController = storyboard.instantiateViewControllerWithIdentifier("groupContributionViewController") as! GroupContributionViewController

        return [classContributionsCollectionViewController, groupContributionViewController]
    }

    // MARK: - Custom Action
    
    @IBAction func closeAction(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}






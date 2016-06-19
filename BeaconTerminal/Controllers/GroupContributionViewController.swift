//
//
//import Foundation
//import XLPagerTabStrip
//import Spring
//
//class GroupContributionViewController: UIViewController, IndicatorInfoProvider {
//
//    // MARK: UI
//    @IBOutlet weak var eatsView: SpringView!
//    @IBOutlet weak var getsEatenView: SpringView!
//    @IBOutlet weak var coDependentView: SpringView!
//    @IBOutlet weak var competesWith: SpringView!
//
//    var itemInfo: IndicatorInfo = "YOUR CONTRIBUTION"
//
//    // MARK: Scanner Border
//    let _border = CAShapeLayer()
//
//    init(itemInfo: IndicatorInfo) {
//        self.itemInfo = itemInfo
//        super.init(nibName: nil, bundle: nil)
//
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        renderViews()
//    }
//
//    // MARK: - IndicatorInfoProvider
//
//    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
//        return itemInfo
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
////        _border.path = UIBezierPath(roundedRect: self.eatsView.frame, cornerRadius: 10).CGPath
////        _border.frame = self.eatsView.frame
//    }
//
//    func renderViews() {
//
////        _border.strokeColor = UIColor.blackColor().CGColor
////        _border.fillColor = nil
////        _border.lineDashPattern = [2, 2]
////        _border.lineWidth = 2
////        self.eatsView.layer.addSublayer(_border)
//    }
//}

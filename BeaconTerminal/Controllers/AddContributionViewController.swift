

import Foundation
import UIKit
import Spring
import Material

class AddContributionViewController: UIViewController {

    var speciesIndex = 0

    @IBOutlet weak var observationEditView: ObservationEditView!
    @IBOutlet var dropViews: [ObservationView]!
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTapGesture()
       // self.changeSpecies(speciesIndex)
    }

    func addTapGesture() {
        for dview in dropViews {
            let ob = dview as ObservationView
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddContributionViewController.tapDropView(_:)))
            ob.addGestureRecognizer(tapGesture)
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.view.layoutIfNeeded()
//        self.preferredContentSize = self.view.contentSiz
    }
    
    func tapDropView(sender: UITapGestureRecognizer?) {

        let tappedView = sender!.view
        let tag = tappedView!.tag
        LOG.debug("tapped view \(tappedView!.tag)")
        let topView = UIView(frame: self.view.frame)
        topView.backgroundColor = MaterialColor.grey.base
        topView.alpha = 0.8
//        self.view.addSubview(topView)
//        self.view.bringSubviewToFront(topView)
//
        for dview in dropViews {
            let ob = dview as ObservationView
                ob.animate()
        }
        observationEditView.opacity = 0.0
        observationEditView.hidden = false
        observationEditView.animate()


    }
    func changeSpecies(speciesIndex: Int) {
        let speciesImage = DataManager.sharedInstance.generateImageForSpecies(speciesIndex)
        for dview in dropViews {
            let ob = dview as ObservationView
            ob.mainSpiecesImage.image = speciesImage
        }
    }
    
    
}
  

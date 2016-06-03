

import Foundation
import UIKit
import Spring
import Material

class RelationshipsContributionViewController: UIViewController {

    var speciesIndex = 0

    @IBOutlet var gestureCollection: [UITapGestureRecognizer]!

    @IBOutlet var dropViews: [ObservationView]!
    
    @IBOutlet weak var bottomToolbar: UIToolbar!
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func changeSpecies(speciesIndex: Int) {
        let speciesImage = DataManager.sharedInstance.generateImageForSpecies(speciesIndex)
        for dview in dropViews {
            let ob = dview as ObservationView
            ob.mainSpiecesImage.image = speciesImage
        }
    }

    // MARK: Overrides
    @IBAction func tapGestureTapped(sender: UITapGestureRecognizer) {
        LOG.debug("TABBED")
        self.performSegueWithIdentifier("addContributionSegue", sender: sender)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "addContributionSegue"){

            let addContributionViewController = segue.destinationViewController as? AddContributionViewController
                
                addContributionViewController?.speciesIndex = speciesIndex

                if let gesture = sender as? UIGestureRecognizer {
                    if let observationView = gesture.view as? ObservationView {
                        if let observationId = observationView.observationId {
//                            addContributionViewController!.observationView.text = observationView.viewLabel.text
                            addContributionViewController!.observationId = observationView.viewLabel.text
                        }
                    }
                }


        }
    }

    // MARK: Views
    override func viewWillAppear(animated: Bool) {
        self.view.layoutIfNeeded()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        changeSpecies(self.speciesIndex)
        //bottomToolbar.clipsToBounds = true
    }


    
}

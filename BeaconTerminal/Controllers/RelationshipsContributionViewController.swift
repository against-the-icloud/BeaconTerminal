

import Foundation
import UIKit
import Spring
import Material

class RelationshipsContributionViewController: UIViewController {

    @IBOutlet var gestureCollection: [UITapGestureRecognizer]!

    @IBOutlet var dropViews: [ObservationView]!
    
    @IBOutlet weak var bottomToolbar: UIToolbar!

    var toolMenuDelegate: ToolMenuDelegate?
    var dropViewIndex = 0
    var speciesIndex = 0

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func changeSpecies(speciesIndex: Int) {
        let speciesImage = DataManager.generateImageForSpecies(speciesIndex)
        var i = 0
        for dview in dropViews {
            let ob = dview as ObservationView
            ob.mainSpiecesImage.image = speciesImage
            ob.observationDropView.tag = i
            i += 1
        }
    }

    // MARK: Overrides
    @IBAction func tapGestureTapped(sender: UITapGestureRecognizer) {
        LOG.debug("TABBED")
        self.performSegueWithIdentifier("addContributionSegue", sender: sender)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "addContributionSegue"){
            //navigationItem.backBarButtonItem?.title = ""
            let addContributionViewController = segue.destinationViewController as? AddContributionViewController
                
                addContributionViewController?.speciesIndex = speciesIndex
                addContributionViewController?.toolMenuDelegate =  toolMenuDelegate
                addContributionViewController?.dropViewIndex =  ((sender as? UITapGestureRecognizer)!.view?.tag)!
                if let gesture = sender as? UIGestureRecognizer {
                    if let observationView = gesture.view as? ObservationView {
                        if observationView.observationId != nil {
//                            addContributionViewController!.observationView.text = observationView.viewLabel.text
                            addContributionViewController!.title = "'\(observationView.viewLabel.text!)' \(self.title!)"
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
        self.navigationController?.navigationItem.backBarButtonItem?.title = ""

        changeSpecies(self.speciesIndex)
        //bottomToolbar.clipsToBounds = true
    }


    
}

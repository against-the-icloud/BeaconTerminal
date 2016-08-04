//
// Created by Anthony Perritano on 5/16/16.
// Copyright (c) 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit

class TestUITableViewController: UITableViewController, UINavigationControllerDelegate {

    var navigationControllerPreferredContentSize:CGSize?

    //"ECOSYSTEM" "SPECIES"
    var simulationType = ""
    var simulationIndex = -1

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        LOG.debug("\(indexPath.row)")
        LOG.debug("\(indexPath.section)")

        if (indexPath as NSIndexPath).section == 0 {
            simulationType = "ECOSYSTEM"
            simulationIndex = (indexPath as NSIndexPath).row
        } else if (indexPath as NSIndexPath).section == 1 {
            simulationType = "SPECIES"
            simulationIndex = (indexPath as NSIndexPath).row
        }

        self.performSegue(withIdentifier: "unwindTestTableSegue", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = self
        let frame = self.navigationController?.navigationBar.frame

        if let frame = frame {
            if self.navigationController != nil {
                if var contentSize = self.navigationController?.preferredContentSize {
                    contentSize.height -= frame.height;
                    self.navigationControllerPreferredContentSize = contentSize
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        print("super viewWillAppear table content size \(tableView.contentSize)")
        if self.navigationController != nil {
            self.navigationController?.preferredContentSize = calculatePreferredContentSize()
        }
    }

    func calculatePreferredContentSize() -> CGSize {
        let windowSize = UIApplication.shared.windows.first?.frame.size
        var height = tableView.contentSize.height
        if let windowSize = windowSize{
            if  height > windowSize.height * 0.60 {
                height = windowSize.height * 0.60
            }
        }

        let size = CGSize(width: self.tableView.contentSize.width, height: height)
        preferredContentSize = size
        self.tableView.flashScrollIndicators()
//        print("table content size \(tableView.contentSize)")
//        print("preferred content size \(preferredContentSize)")
        return size;

    }

//    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//        calculatePreferredContentSize()
//    }
}

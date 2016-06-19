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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        LOG.debug("\(indexPath.row)")
        LOG.debug("\(indexPath.section)")

        if indexPath.section == 0 {
            simulationType = "ECOSYSTEM"
            simulationIndex = indexPath.row
        } else if indexPath.section == 1 {
            simulationType = "SPECIES"
            simulationIndex = indexPath.row
        }

        self.performSegueWithIdentifier("unwindTestTableSegue", sender: self)
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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        print("super viewWillAppear table content size \(tableView.contentSize)")
        if self.navigationController != nil {
            self.navigationController?.preferredContentSize = calculatePreferredContentSize()
        }
    }

    func calculatePreferredContentSize() -> CGSize {
        let windowSize = UIApplication.sharedApplication().windows.first?.frame.size
        var height = tableView.contentSize.height
        if let windowSize = windowSize{
            if  height > windowSize.height * 0.60 {
                height = windowSize.height * 0.60
            }
        }

        let size = CGSizeMake(self.tableView.contentSize.width, height)
        preferredContentSize = size
        self.tableView.flashScrollIndicators()
//        print("table content size \(tableView.contentSize)")
//        print("preferred content size \(preferredContentSize)")
        return size;

    }

    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        calculatePreferredContentSize()
    }
}

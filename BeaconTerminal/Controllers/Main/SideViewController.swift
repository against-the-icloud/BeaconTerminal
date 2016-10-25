//
// Created by Anthony Perritano on 5/17/16.
// Copyright (c) 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Material
import RealmSwift

class SideViewController: UITableViewController {
    
    @IBOutlet weak var exitZoneText: UITextField!
    @IBOutlet weak var enterZoneText: UITextField!
    
    // MARK: View Methods
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = UIColor.white()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
    }
    
    // MARK: table
    
    /// Select item at row in tableView.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        for cell in tableView.visibleCells {
            cell.selectionStyle = .default
        }
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.selectionStyle = .blue
        }
                
        switch indexPath.section {
        case 0:
        
           
                self.navigationDrawerController?.closeLeftView()
                //do manual
                getAppDelegate().manualLogin()
        
            
            break
        case 1:
            self.navigationDrawerController?.closeLeftView()
            break
        case 2:
            if indexPath.row == 3 {
                getAppDelegate().checkReachability(withOk: true)
            }
            
            self.navigationDrawerController?.closeLeftView()
            break
        default:
            break
        }
    }
    
    func showSelectedCell(with applicationState: ApplicationType) {
        
        var indexPath: IndexPath?
        
        switch applicationState {
        case .objectGroup:
            indexPath = IndexPath(row: 0, section: 1)
            break
        case .placeTerminal:
            indexPath = IndexPath(row: 1, section: 0)
            break
        case .placeGroup:
            indexPath = IndexPath(row: 0, section: 0)
            break
        default:
            break
        }
        
        if let indexPath = indexPath {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.contentView.backgroundColor = Color.blueGrey.base
            // cell?.selectedBackgroundView?.backgroundColor = Color.blueGrey.base
            cell?.selectionStyle = .blue
        }
        
    }
    @IBAction func changeZone(_ sender: UIButton) {
        
        if let text = sender.titleLabel?.text {
            
            let enter = text.contains("ENTER")
            switch enter {
            case true:
                
                realmDataController.updateRuntime(withAction: ActionType.entered.rawValue)
                
                if let zone = enterZoneText.text {
                    
                    let place = "speciesIndex:\(Int(zone)!)"
                    
                    realmDataController.syncSpeciesObservations(withSpeciesIndex: Int(zone)!, withCondition: getAppDelegate().checkApplicationState().rawValue, withActionType: "enter", withPlace: place)
                    realmDataController.deleteAllSpeciesObservations(withRealmType: RealmType.terminalDB)
                    realmDataController.updateRuntime(withSpeciesIndex: Int(zone), withRealmType: RealmType.terminalDB, withAction: ActionType.entered.rawValue)
                }
                //ENTER CONDITION
                break
            default:
                //EXIT CONDITION
                realmDataController.updateRuntime(withAction: ActionType.exited.rawValue)
                break
            }
        }
        
    }
    
    @IBAction func unwindToSideMenu(segue: UIStoryboardSegue) {
        self.navigationDrawerController?.closeLeftView()
    }
    
}

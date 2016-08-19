//
//  TerminalViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/18/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit

class TerminalViewController: UIViewController {
    
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var mutualRelationshipView: UIView!
    @IBOutlet weak var mutualCountLabel: UILabel!
    
    @IBOutlet weak var consumerRelationshipView: UIView!
    @IBOutlet weak var consumerCountLabel: UILabel!
    
    @IBOutlet weak var producerRelationshipView: UIView!
    @IBOutlet weak var producerCountLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    var species: Species?
    var section: Section?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showSpeciesLogin()
    }
    
    func showSpeciesLogin() {
        let storyboard = UIStoryboard(name: "Popover", bundle: nil)
        let loginNavigationController = storyboard.instantiateViewController(withIdentifier: "loginNavigationController") as! UINavigationController
        
        if let loginSectionCollectionViewController = loginNavigationController.viewControllers[0] as? LoginSectionCollectionViewController {
            
            loginSectionCollectionViewController.loginType = LoginType.species
            
        }
        
        self.present(loginNavigationController, animated: true, completion: {})
    }
    
    
    @IBAction func unwindToTerminalView(segue: UIStoryboardSegue) {
        self.navigationDrawerController?.closeLeftView()
        queryDB()
        updateUI()
        
    }
    
    func queryDB() {
        
    }
    
    func updateUI() {
        
        if let species = species {
            profileImageView.image = RealmDataController.generateImageForSpecies(species.index)
            profileLabel.text = species.name
        }
        
        if let section = section {
            sectionLabel.text = section.name
        }
        
    }
    
}

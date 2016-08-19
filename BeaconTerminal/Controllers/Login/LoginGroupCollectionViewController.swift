//
//  LoginGroupCollectionViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/18/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class LoginGroupCollectionViewController: UICollectionViewController {
    
    var groups: List<Group>?
    var selectedSection: Section?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    func constructLabel(with group: Group?) -> String? {
        if let g = group {
            
            if g.members.count > 0 {
                var memberNames = ""
                for member in g.members {
                    if memberNames.isEmpty {
                        memberNames = "\(member.name!)"
                    } else {
                        memberNames = "\(memberNames),\(member.name!)"
                    }
                }
                return "\(memberNames)"
            }
        }
        return nil
    }
    
    // Mark: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
    
    func prepareView() {
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.backItem?.backBarButtonItem?.tintColor = UIColor.white
        navigationController?.toolbar.barTintColor = Util.flatBlack
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {})
        self.performSegue(withIdentifier: "unwindToSideMenu", sender: self)
    }
}

extension LoginGroupCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let groups = self.groups {
            return groups.count
        }
        return 0
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let group = groups![indexPath.row]
        realmDataController?.updateUser(withGroup: group, section: selectedSection!)
        self.performSegue(withIdentifier: "unwindToSideMenu", sender: self)
        
        self.dismiss(animated: true, completion: {})
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoginGroupCell.reuseIdentifier, for: indexPath) as? LoginGroupCell
        
        if groups?[indexPath.row] != nil {
            let group = groups![indexPath.row]
            cell?.groupLabel.text = group.name
            cell?.groupMemberLabel.text = constructLabel(with: group)
            return cell!
        }
        return cell!
    }
}

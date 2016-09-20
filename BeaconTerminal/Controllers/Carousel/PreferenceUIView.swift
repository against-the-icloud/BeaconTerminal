//
//  PreferenceUIView.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/7/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class PreferenceUIView: UIView {
    
    @IBOutlet var preferenceLabels:[PreferenceUILabel]?
    
    var notificationToken: NotificationToken? = nil
    
    // Mark: UIView Methods
    
    var speciesObservation: SpeciesObservation? {
        didSet {
            prepareToken()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareToken() {
        
        let preferences = speciesObservation?.preferences
        
        // Observe Results Notifications
        notificationToken = preferences?.addNotificationBlock { (changes: RealmCollectionChange) in
            switch changes {
            case .initial(let preferences):
                //look up the preference
                for p in preferences {
                    self.updateLabels(preference: p)
                }
                break
            case .update(let preferences, _, _, let modifications):
                if !modifications.isEmpty {
                    for index in modifications {
                        self.updateLabels(preference: preferences[index])
                    }
                }
                break
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
    }
    
    func updateLabels(preference: Preference) {
        if let labels = self.preferenceLabels {
            for label in labels {
                //look up the preference
                if preference.type == label.preferenceType {
                    if let value = preference.value {
                        if value.isEmpty {
                            label.text = "Not ready to report"
                        } else {
                            label.text = value
                        }
                    } else {
                        label.text = "Not ready to report"
                    }
                }
                
            }
        }
        
    }
    
    deinit {
        notificationToken?.stop()
    }
    
}

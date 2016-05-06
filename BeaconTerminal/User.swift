//
//  User.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 4/30/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    
    dynamic var id = ""
    dynamic var username = ""
    dynamic var displayName = ""
    dynamic var tags = ""
    dynamic var userRole = ""
    dynamic var last_modified = NSDate(timeIntervalSince1970: 1)
    dynamic var habitatGroup = ""
    
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}

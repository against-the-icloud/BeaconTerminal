//
//  StringUtil.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/19/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation

class StringUtil {

    class func relationshipString(withType type: RelationshipType) -> String {
        switch type {
        case .consumer:
            return "IS A CONSUMER OF"
        case .producer:
            return "IS A PRODUCER FOR"
        case .mutual:
            return "IS DEPENDENT ON"
        case .competes:
            return "COMPETES WITH"
        default:
            return ""
        }
    }
    
    class func relationshipString(withString string: String) -> String {
        switch string {
        case "consumer":
            return "IS A CONSUMER OF"
        case "producer":
            return "IS A PRODUCER FOR"
        case "mutual":
            return "IS DEPENDENT ON"
        case "competes":
            return "COMPETES WITH"
        default:
            return ""
        }
    }
    
}

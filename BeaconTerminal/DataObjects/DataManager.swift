//
//  DataManager.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 5/13/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class DataManager {
    
    var realm: Realm?
    
    static let sharedInstance = DataManager()
    
    private init(){
        
      
            realm = try! Realm() // Create realm pointing to default file    
        
        
    }
    
    func createDataStructure() {
        
        do {
            let path = NSBundle.mainBundle().pathForResource("wallcology_configuration", ofType: "json")
            let jsonData = NSData(contentsOfFile:path!)
            let json = JSON(data: jsonData!)
            
            let configuration = Configutation()
            
            if let habitats = json["habitats"].array {
                
                var i = 0
                for item in habitats {
                    
                    let habitat = Habitat()
                    
                    habitat.habitatNumber = i
                    
                    if let temp = item["temperature"].int {
                        habitat.temperature = temp
                    }
                    
                    if let pl = item["pipelength"].int {
                        habitat.pipelength = pl
                    }
                    
                    if let ba = item["brickarea"].int {
                        habitat.brickarea = ba
                    }
                    
                    if let name = item["name"].string {
                        habitat.name = name
                    }
                    
                    configuration.habitats.append(habitat)
                    
                    // Persist your data easily
                    try! realm!.write {
                        realm!.add(habitat)
                    }
                    
                    i += 1
                }
            }
            
            if let critters = json["habitatItems"].array {
                for item in critters {
                    
                    let critter = Critter()
                    
                    
                    if let index = item["index"].int {
                        critter.index = index
                    }
                    
                    if let color = item["color"].string {
                        critter.color = color
                    }
                    
                    if let imgUrl = item["imgUrl"].string {
                        critter.imgUrl = imgUrl
                    }
                    
                    
                    configuration.critters.append(critter)
                    
                    // Persist your data easily
                    try! realm!.write {
                        realm!.add(critter)
                    }
                    
                }
                
            }
            try! realm!.write {
                realm!.add(configuration)
            }
            
        } catch {
            //            print("error")
            LOG.debug("error")
            //            print("error")
            LOG.debug("error")
        }
        
    }
    
    
    func createTestCritters() {
        let critter = Critter()
        critter.name = "blue"
        critter.imgUrl = "https://ltg.cs.uic.edu/WC/icons/species_00.svg"
        critter.color = "#FFC91B"
        
        // Save your object
        realm!.beginWrite()
        realm!.add(critter)
        try! realm!.commitWrite()
    }


    
    
}

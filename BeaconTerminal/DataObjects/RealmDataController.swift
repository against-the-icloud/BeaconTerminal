//
//  RealmDataController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 6/13/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class RealmDataController {
    
    let critterNames = ["SquidWard","Sumbrao","Blob","Busheeks","Terminator","#Imgettindizzy","Purple cabbage","Da rock","Miranda Sings","Spotted Ninjas","Majigger"]
    
    
    let realm: Realm!
   
    init(realm: Realm) {
        self.realm = realm
    }
    
    convenience init() {
        self.init(realm: try! Realm())
    }
    
    func add(realmObject: Object) {
        try! realm.write {
            self.realm.add(realmObject)
        }
    }
    
    func createDefaultConfiguration() -> SimulationConfiguration {
        let path = NSBundle.mainBundle().pathForResource("wallcology_configuration", ofType: "json")
        let jsonData = NSData(contentsOfFile:path!)
        let json = JSON(data: jsonData!)
        
        let simulationConfiguration = SimulationConfiguration()
        
        if let habitats = json["habitats"].array {
            
            for (index,item) in habitats.enumerate() {
                
                let habitat = Habitat()
                
                habitat.habitatNumber = index
                
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
                
                simulationConfiguration.habitats.append(habitat)
                
                // Persist your data easily
                try! realm!.write {
                    realm!.add(habitat)
                }
                
            }
        }
        
        if let critters = json["habitatItems"].array {
            for (index,item) in critters.enumerate() {
                
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
                
                critter.name = critterNames[index]
                
                
                simulationConfiguration.critters.append(critter)
                
                // Persist your data easily
                try! realm!.write {
                    realm!.add(critter)
                }
                
            }
            
        }
        
        return simulationConfiguration
    }
    
    func createTestConfiguration() {
        
            try! realm!.write {
                realm!.add(createDefaultConfiguration())
            }
            
     
    }

}
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
import UIKit

class DataManager {
    
    var realm: Realm?
    var currentSelectedSpecies = 0
    
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
    
    func findSpecies(speciesIndex: Int) -> Critter? {
        let foundCritter = realm!.objects(Critter).filter("index = \(speciesIndex)")[0] as Critter!
        return foundCritter
    }

    func createVotes(mainCritterIndex: Int) -> List<Vote> {


        var usedCritterIndexes = [Int]()
        let votes = List<Vote>()
        let randomIndex = Int(arc4random_uniform(10) + 1)

        usedCritterIndexes.append(mainCritterIndex)

        for _ in 0...randomIndex {
            var randomCritterIndex = Int(arc4random_uniform(11) + 1) - 1

            while usedCritterIndexes.contains(randomCritterIndex) == true {
                randomCritterIndex = Int(arc4random_uniform(11) + 1) - 1
            }

            usedCritterIndexes.append(randomCritterIndex)

            let vote = Vote()
            vote.versusCritter = realm!.objects(Critter).filter("index = \(randomCritterIndex)")[0] as Critter!
            vote.mainCritter = realm!.objects(Critter).filter("index = \(mainCritterIndex)")[0] as Critter!
            vote.voteCount = Int(arc4random_uniform(4) + 1)
            votes.append(vote)
        }
        LOG.debug("VOTES \(votes)")
        return votes
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

    func generateImageFileNameFromIndex(index: Int) -> String {
        var imageName = ""
        if index < 10 {
            
            imageName = "species_0\(index).png"
        } else {
            
            imageName = "species_\(index).png"
        }
        return imageName
    }

    func generateImageForSpecies(index: Int) -> UIImage? {
        let imageName = generateImageFileNameFromIndex(index)
        return UIImage(named: imageName)
    }

    
    
}

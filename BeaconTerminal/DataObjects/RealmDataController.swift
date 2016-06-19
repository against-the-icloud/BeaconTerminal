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
    
    let realm: Realm!
   
    init(realm: Realm) {
        self.realm = realm
    }
    
    convenience init() {
        self.init(realm: try! Realm())
    }
    
    func add(realmObject: Object, shouldUpdate: Bool) {
        try! realm.write {
            self.realm.add(realmObject, update: shouldUpdate)
        }
    }

    func findSpecies(speciesIndex: Int) -> Species? {
        let foundSpecies = realm!.objects(Species).filter("index = \(speciesIndex)")[0] as Species!
        return foundSpecies
    }

    func createTestGroup() -> Group {
        let simulationConfiguration = createDefaultConfiguration()

        let group = Group()
        group.id = NSUUID().UUIDString
        group.groupTitle = Randoms.randomFakeGroupName()
        group.last_modified = NSDate()
        group.simulationConfiguration = simulationConfiguration


        let teacher = "Jonna Jet"
        let section = "6DF"


        //four members
        for _ in 0...3 {
            let member = Member()
            member.id = NSUUID().UUIDString
            member.name = Randoms.randomFakeFirstName()
            member.section = section
            member.teacher = teacher
            member.last_modified = NSDate()
            group.members.append(member)
        }
        
        let ecosystems = group.simulationConfiguration!.ecosystems
        let species = group.simulationConfiguration!.species
        
        for speciesFrom in species {
           // var makeRelationship : (String, Group) -> List<SpeciesObservation>
            
            let makeRelationship = {
                (relationshipValue: String, targetGroup: Group) -> List<SpeciesObservation> in
                let obs = List<SpeciesObservation>()
                let numObs = Int.random(2...5)
                for _ in 0...numObs {
                    let x : Species = species[Int.random(0...10)]
                    let s : SpeciesObservation = self.createSpeciesObservation(speciesFrom, toSpecies: x, relationship: relationshipValue)
                    //s.authors = targetGroup
                    s.lastModified = NSDate()
                    let hIndex = Int.random(0...3)
                    //LOG.debug("\(hIndex)")
                    s.ecosystem = ecosystems[hIndex]
                    s.title = ""
                    s.note = ""
                    s.id = NSUUID().UUIDString
                    obs.append(s)
                }
                return obs
            }
            
            group.speciesObservations.appendContentsOf(makeRelationship(SpeciesRelationships.PRODUCER, group))
            group.speciesObservations.appendContentsOf(makeRelationship(SpeciesRelationships.CONSUMER, group))
            group.speciesObservations.appendContentsOf(makeRelationship(SpeciesRelationships.COMPLETES, group))

            
        }
        return group
    }

 



    func createSpeciesObservation(fromSpecies: Species, toSpecies: Species, relationship: String) -> SpeciesObservation {
        let speciesObservation = SpeciesObservation()
        speciesObservation.relationship = relationship
        speciesObservation.toSpecies = toSpecies
        speciesObservation.fromSpecies = fromSpecies

        return speciesObservation
    }

    func createDefaultConfiguration() -> SimulationConfiguration {
        let path = NSBundle.mainBundle().pathForResource("wallcology_configuration", ofType: "json")
        let jsonData = NSData(contentsOfFile:path!)
        let json = JSON(data: jsonData!)
        
        let simulationConfiguration = SimulationConfiguration()
        simulationConfiguration.id = NSUUID().UUIDString
        
        if let ecosystem = json["ecosystems"].array {
            
            for (index,item) in ecosystem.enumerate() {
                
                let ecosystem = Ecosystem()
                
                ecosystem.ecosystemNumber = index
                
                if let temp = item["temperature"].int {
                    ecosystem.temperature = temp
                }
                
                if let pl = item["pipelength"].int {
                    ecosystem.pipelength = pl
                }
                
                if let ba = item["brickarea"].int {
                    ecosystem.brickarea = ba
                }
                
                if let name = item["name"].string {
                    ecosystem.name = name
                }
                
                simulationConfiguration.ecosystems.append(ecosystem)
                
                // Persist your data easily
//                try! realm!.write {
//                    realm!.add(ecosystem)
//                }
                
            }
        }
        
        if let critters = json["ecosystemItems"].array {
            for (index,item) in critters.enumerate() {
                
                let species = Species()
                
                
                if let index = item["index"].int {
                    species.index = index
                }
                
                if let color = item["color"].string {
                    species.color = color
                }
                
                if let imgUrl = item["imgUrl"].string {
                    species.imgUrl = imgUrl
                }
                
                species.name = Randoms.creatureNames()[index]
                
                
                simulationConfiguration.species.append(species)
                
                // Persist your data easily
//                try! realm!.write {
//                    realm!.add(critter)
//                }
                
            }
            
        }
        
        return simulationConfiguration
    }
    
    func createTestConfiguration() {
            try! realm!.write {
                realm!.add(createDefaultConfiguration())
            }
    }

    static func generateImageFileNameFromIndex(index: Int) -> String {
        var imageName = ""
        if index < 10 {

            imageName = "species_0\(index).png"
        } else {

            imageName = "species_\(index).png"
        }
        return imageName
    }

    static func generateImageForSpecies(index: Int) -> UIImage? {
        let imageName = self.generateImageFileNameFromIndex(index)
        return UIImage(named: imageName)
    }

}
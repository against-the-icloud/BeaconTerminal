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

    func addTestGroup() -> Group {
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
        
        let allEcosystems = group.simulationConfiguration!.ecosystems
        let allSpecies = group.simulationConfiguration!.species
        
        for fromSpecies in allSpecies {
           // var makeRelationship : (String, Group) -> List<SpeciesObservation>
            
            let s : SpeciesObservation = createSpeciesObservation(fromSpecies, allSpecies: allSpecies, allEcosystems: allEcosystems)
          
                   
            group.speciesObservations.append(s)
            
    
            
        }

            
        return group
    }

    func createSpeciesObservation(fromSpecies: Species, allSpecies: List<Species>, allEcosystems: List<Ecosystem>) -> SpeciesObservation {
        let speciesObservation = SpeciesObservation()
        speciesObservation.id = NSUUID().UUIDString
        speciesObservation.fromSpecies = fromSpecies
        speciesObservation.lastModified = NSDate()
        let ecosystem = allEcosystems[Int.random(0...3)]
        speciesObservation.ecosystem = ecosystem

        for i in 0...3 {
            
            let relationship = Relationship()
            relationship.id = NSUUID().UUIDString
            relationship.toSpecies = allSpecies[Int.random(0...10)]
            relationship.lastModified = NSDate()
            relationship.note = "hello"
            relationship.ecosystem = ecosystem
            
            
            switch i {
            case 0:
                relationship.relationshipType = SpeciesRelationships.MUTUAL
            case 1:
                relationship.relationshipType = SpeciesRelationships.PRODUCER
            case 2:
                relationship.relationshipType = SpeciesRelationships.CONSUMER
            default:
                relationship.relationshipType = SpeciesRelationships.CONSUMER
            }
            
            speciesObservation.relationships.append(relationship)
        }
        
        return speciesObservation
    }
    
    func checkGroups() -> Bool {
        let foundGroups = realm!.objects(Group)
        
        if foundGroups.count == 0 {
            add(addTestGroup(), shouldUpdate: false)
            if DEBUG {
                LOG.debug("Added Groups, not present")
            }
            return false
        }
        
        return true

    }
    
    func checkNutellaConfigs() -> Bool {
        let foundConfigs = realm!.objects(NutellaConfig)
        
        if foundConfigs.count == 0 {
            let nutellaConfigs = addNutellaConfigs()
            for config in nutellaConfigs {
                add(config, shouldUpdate: false)
            }
            if DEBUG {
                LOG.debug("Added Nutella Configs, not present")
            }
            return false
        }
        
        return true
    }

    func addNutellaConfigs() -> [NutellaConfig] {
        let path = NSBundle.mainBundle().pathForResource("nutella_config", ofType: "json")
        let jsonData = NSData(contentsOfFile:path!)
        let json = JSON(data: jsonData!)
        
        var nutellaConfigs = [NutellaConfig]()

        if let configs = json["configs"].array {
            
            
            for (_,item) in configs.enumerate() {
                let nutellaConfig = NutellaConfig()
                                
                if let id = item["id"].string {
                    nutellaConfig.id = id
                }
                
                if let appId = item["appId"].string {
                    nutellaConfig.appId = appId
                }
                
                if let runId = item["runId"].string {
                    nutellaConfig.runId = runId
                }
                
                if let host = item["host"].string {
                    nutellaConfig.host = host
                }
                
                if let componentId = item["componentId"].string {
                    nutellaConfig.componentId = componentId
                }
                
                if let resourceId = item["resourceId"].string {
                    nutellaConfig.resourceId = resourceId
                }
                
                if let outChannels = item["outChannels"].array {
                    for (_, item) in outChannels.enumerate() {
                        let channel = Channel()
                        channel.name = item.string
                        nutellaConfig.outChannels.append(channel)
                    }
                }
                
                if let inChannels = item["inChannels"].array {
                    for (_, item) in inChannels.enumerate() {
                        let channel = Channel()
                        channel.name = item.string
                        nutellaConfig.inChannels.append(channel)
                        
                    }
                }
                
                
                nutellaConfigs.append(nutellaConfig)
            }
        }
        

        return nutellaConfigs
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
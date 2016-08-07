//
//  RealmDataController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 6/13/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import RealmSwift

class RealmDataController {
    
    let realm: Realm!
    var currentGroup : Group?
    var currentSection : String?
    
    init(realm: Realm) {
        self.realm = realm
    }
    
    convenience init() {
        self.init(realm: try! Realm())
    }
    
    func add(_ realmObject: Object, shouldUpdate: Bool) {
        try! realm.write {
            self.realm.add(realmObject, update: shouldUpdate)
        }
    }
    
    func delete(_ realmObject: Object) {
        try! realm.write {
            self.realm.delete(realmObject)
        }
    }

    // Mark: Group
    
    func checkGroups() -> Bool {
        let foundGroups = realm!.allObjects(ofType: Group.self)
        
        if foundGroups.count == 0 {
            currentGroup = addTestGroup()
            add(currentGroup!, shouldUpdate: false)
            if DEBUG {
                LOG.debug("Added Groups, not present")
            }
            return false
        }
        
        return true
        
    }

    
    func addTestGroup() -> Group {
        let simulationConfiguration = createDefaultConfiguration()

        let group = Group()
        group.id = UUID().uuidString
        group.groupTitle = Randoms.randomFakeGroupName()
        group.last_modified = Date()
        group.simulationConfiguration = simulationConfiguration


        let teacher = "Jonna Jet"
        currentSection = "6DF"


        //four members
        for _ in 0...3 {
            let member = Member()
            member.id = UUID().uuidString
            member.name = Randoms.randomFakeFirstName()
            member.section = currentSection
            member.teacher = teacher
            member.last_modified = Date()
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
    
    
    
    func updateSpeciesObservation(_ toSpecies: Species, speciesObservation: SpeciesObservation, relationshipType: String){
     
        try! realm.write {
            let relationship = Relationship()
            relationship.id = NSUUID().uuidString
            relationship.toSpecies = toSpecies
            relationship.lastModified = NSDate() as Date
            relationship.note = "NEW"
            relationship.ecosystem = speciesObservation.ecosystem
            relationship.relationshipType = relationshipType
            speciesObservation.relationships.append(relationship)
            self.realm.add(relationship, update: true)
        }

     
    }
    
    func createSpeciesObservation(_ fromSpecies: Species, allSpecies: List<Species>, allEcosystems: List<Ecosystem>) -> SpeciesObservation {
        let speciesObservation = SpeciesObservation()
        speciesObservation.id = UUID().uuidString
        speciesObservation.fromSpecies = fromSpecies
        speciesObservation.lastModified = Date()
        let ecosystem = allEcosystems[0]
        speciesObservation.ecosystem = ecosystem

        //create relationships
        
        for i in 0...3 {
            
            let relationship = Relationship()
            relationship.id = UUID().uuidString
            relationship.toSpecies = allSpecies[i+2]
            relationship.lastModified = Date()
            relationship.note = "hello"
            relationship.ecosystem = ecosystem
            
            
            switch i {
//            case 0:
//                relationship.relationshipType = SpeciesRelationships.MUTUAL
            case 0:
                relationship.relationshipType = SpeciesRelationships.PRODUCER
            case 1:
                relationship.relationshipType = SpeciesRelationships.CONSUMER
            case 3:
                relationship.relationshipType = SpeciesRelationships.COMPLETES
            default:
                relationship.relationshipType = SpeciesRelationships.CONSUMER
            }
            
            speciesObservation.relationships.append(relationship)
        }
        
        //create preferences
        let initalPreference = "Not ready to report"
        
        let trophicLevelPreference = Preference()
        trophicLevelPreference.configure(id: UUID().uuidString, type: Preferences.trophicLevel, value: initalPreference)
        
        
        //add(trophicLevelPreference,shouldUpdate: false)
        
        speciesObservation.preferences.append(trophicLevelPreference)
        
        let behavorsPreference = Preference()
        behavorsPreference.configure(id: UUID().uuidString, type: Preferences.behaviors, value: initalPreference)
        
 //       add(behavorsPreference,shouldUpdate: false)
        
        speciesObservation.preferences.append(behavorsPreference)
        
        let predationPreference = Preference()
        predationPreference.configure(id: UUID().uuidString, type: Preferences.predationResistance, value: initalPreference)
        
//        add(predationPreference,shouldUpdate: false)
        
        speciesObservation.preferences.append(predationPreference)
        
        let heatSensitivityPreference = Preference()
        heatSensitivityPreference.configure(id: UUID().uuidString, type: Preferences.heatSensitivity, value: initalPreference)
        
        
//        add(heatSensitivityPreference,shouldUpdate: false)
        
        speciesObservation.preferences.append(heatSensitivityPreference)
        
        let humiditySensistivityPreference = Preference()
        humiditySensistivityPreference.configure(id: UUID().uuidString, type: Preferences.humditiySensitivity, value: initalPreference)
        
//        add(humiditySensistivityPreference,shouldUpdate: false)

        speciesObservation.preferences.append(humiditySensistivityPreference)
        
        let habitatPreference = Preference()
        habitatPreference.configure(id: UUID().uuidString, type: Preferences.habitatPreference, value: "")
        
//        add(humiditySensistivityPreference,shouldUpdate: false)

        speciesObservation.preferences.append(habitatPreference)
       
        return speciesObservation
    }

    
    // Mark: Nutella
    
    func checkNutellaConfigs() -> Bool {
        let foundConfigs = realm!.allObjects(ofType: NutellaConfig.self)
        
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
        let path = Bundle.main.path(forResource: "nutella_config", ofType: "json")
        let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path!))
        let json = JSON(data: jsonData!)
        
        var nutellaConfigs = [NutellaConfig]()

        if let configs = json["configs"].array {
            
            
            for (_,item) in configs.enumerated() {
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
                    for (_, item) in outChannels.enumerated() {
                        let channel = Channel()
                        channel.name = item.string
                        nutellaConfig.outChannels.append(channel)
                    }
                }
                
                if let inChannels = item["inChannels"].array {
                    for (_, item) in inChannels.enumerated() {
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

    // Mark: Configuration
    
    func createDefaultConfiguration() -> SimulationConfiguration {
        let path = Bundle.main.path(forResource: "wallcology_configuration", ofType: "json")
        let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path!))
        let json = JSON(data: jsonData!)
        
        let simulationConfiguration = SimulationConfiguration()
        simulationConfiguration.id = UUID().uuidString
        
        if let ecosystem = json["ecosystems"].array {
            
            for (index,item) in ecosystem.enumerated() {
                
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
            for (index,item) in critters.enumerated() {
                
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

    // Mark: Species
    
    func findSpecies(_ speciesIndex: Int) -> Species? {
        let foundSpecies = realm!.allObjects(ofType: Species.self).filter(using:"index = \(speciesIndex)")[0] as Species!
        return foundSpecies
    }

    static func generateImageFileNameFromIndex(_ index: Int) -> String {
        var imageName = ""
        if index < 10 {

            imageName = "species_0\(index).png"
        } else {

            imageName = "species_\(index).png"
        }
        return imageName
    }

    static func generateImageForSpecies(_ index: Int) -> UIImage? {
        let imageName = self.generateImageFileNameFromIndex(index)
        return UIImage(named: imageName)
    }

}

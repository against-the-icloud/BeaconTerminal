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
    
    var systemConfiguration: SystemConfiguration?
    
    
    init() {
    }
    
    func add(_ realmObject: Object, shouldUpdate: Bool) {
        try! realm?.write {
            realm?.add(realmObject, update: shouldUpdate)
        }
    }
    
    func delete(_ realmObject: Object) {
        try! realm?.write {
            realm?.delete(realmObject)
        }
    }
    
    // Mark: Group
    
    func checkGroups() -> Bool {
        //        let foundGroups = realm!.allObjects(ofType: Group.self)
        //
        //        if foundGroups.count == 0 {
        //          //  currentGroup = addTestGroup()
        //            add(currentGroup!, shouldUpdate: false)
        //            if DEBUG {
        //                LOG.debug("Added Groups, not present")
        //            }
        //            return false
        //        }
        
        return true
        
    }
    
    
    static func exportJson(withSpeciesObservation speciesObservation: SpeciesObservation, group: Group) -> String {
        
        let speciesObsJSON = JSON(speciesObservation.toDictionary())
        if let string = speciesObsJSON.rawString() {
            return string
        }
        
        return ""
    }
    
    
    // MARK: Update Methods
    
    
    func updateUser(withGroup group: Group?, section: Section?) {
        if let g = group, let s = section {
            
            let runtimeObjs = realm?.allObjects(ofType: Runtime.self)
            for r in runtimeObjs! {
                LOG.debug("DELETE runtime obj \(r.id)")
            }
            //create a new one
            
            try! realm?.write {
                realm?.delete((realm?.allObjects(ofType: Runtime.self))!)
                
                let runtime = Runtime()
                runtime.id = UUID().uuidString
                runtime.currentGroup = g
                runtime.currentSection = s
                realm?.add(runtime)
                
                //update bottombar
                
                getAppDelegate().bottomNavigationController?.changeTitle(with: group, and: s)
            }
        }
        
        
    }
    
    func updateRuntimeSection(withSection section: Section?, andOrSpecies species:Species?) {
        
        //get all the current runtimes
        if let currentRuntime = realm?.allObjects(ofType: Runtime.self).first {
            if currentRuntime != nil {
                if let s = section {
                    try! realm?.write {
                        currentRuntime.currentSection = s
                        realm?.add(currentRuntime, update: true)
                    }
                }
                
                if let s = species {
                    try! realm?.write {
                        currentRuntime.currentSpecies = s
                        realm?.add(currentRuntime, update: true)
                    }
                }
            }
        } else {
            //create a new one
            let currentRuntime = Runtime()
            if let s = section {
                try! realm?.write {
                    currentRuntime.currentSection = s
                    realm?.add(currentRuntime, update: true)
                }
            }
            if let s = species {
                try! realm?.write {
                    currentRuntime.currentSpecies = s
                    realm?.add(currentRuntime, update: true)
                }
            }
        }
        
    }
    
    
    // MARK: json read config methods
    
    //step 1. load system config
    func loadSystemConfiguration() -> SystemConfiguration {
        let path = Bundle.main.path(forResource: "system_configuration", ofType: "json")
        let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path!))
        let json = JSON(data: jsonData!)
        
        let systemConfigruation = SystemConfiguration()
        systemConfigruation.id = UUID().uuidString
        systemConfigruation.last_modified = Date()
        systemConfigruation.simulationConfiguration = loadSimulationConfiguration()
        
        self.systemConfiguration = systemConfigruation
        
        if let sections = json["sections"].array {
            
            for (_,sectionItem) in sections.enumerated() {
                let section = Section()
                
                section.id = UUID().uuidString
                section.last_modified = Date()
                
                if let name = sectionItem["name"].string {
                    section.name = name
                }
                
                if let teacher = sectionItem["teacher"].string {
                    section.teacher = teacher
                }
                
                //add system config
                systemConfigruation.sections.append(section)
                
                if let groups = sectionItem["groups"].array {
                    for (groupIndex,groupItem) in groups.enumerated() {
                        
                        let group = Group()
                        group.id = UUID().uuidString
                        
                        if let name = groupItem["name"].string {
                            group.name = name
                        }
                        
                        group.index = groupIndex
                        group.last_modified = Date()
                        
                        //add groups
                        section.groups.append(group)
                        
                        if let groupMembers = groupItem["members"].array {
                            for (_,memberItem) in groupMembers.enumerated() {
                                
                                let member = Member()
                                member.id = UUID().uuidString
                                member.name = memberItem.string
                                member.last_modified = Date()
                                
                                //add members
                                group.members.append(member)
                                section.members.append(member)
                            }
                        }
                        
                        //create speciesObservation place holders for group
                        prepareSpeciesObservations(for: group)
                    }
                }
                
            }
        }
        
        add(systemConfigruation, shouldUpdate: false)
        
        return systemConfigruation
    }
    
    //step 2. add empty speciesobservations
    func prepareSpeciesObservations(for group: Group) {
        if let simConfig = systemConfiguration?.simulationConfiguration  {
            let allSpecies = simConfig.species
            
            //create a speciesObservation for each species
            for fromSpecies in allSpecies {
                // var makeRelationship : (String, Group) -> List<SpeciesObservation>
                
                let speciesObservation = SpeciesObservation()
                speciesObservation.id = UUID().uuidString
                speciesObservation.fromSpecies = fromSpecies
                speciesObservation.lastModified = Date()
                speciesObservation.groupId = group.index
                
                preparePreferences(for: speciesObservation)
                
                group.speciesObservations.append(speciesObservation)
            }
            
        }
    }
    
    //step 3. prepare preferences
    func preparePreferences(for speciesObservation: SpeciesObservation) {
        //create preferences
        let initalPreference = "Not ready to report"
        
        let trophicLevelPreference = Preference()
        trophicLevelPreference.configure(id: UUID().uuidString, type: Preferences.trophicLevel, value: initalPreference)
        speciesObservation.preferences.append(trophicLevelPreference)
        
        let behavorsPreference = Preference()
        behavorsPreference.configure(id: UUID().uuidString, type: Preferences.behaviors, value: initalPreference)
        speciesObservation.preferences.append(behavorsPreference)
        
        let predationPreference = Preference()
        predationPreference.configure(id: UUID().uuidString, type: Preferences.predationResistance, value: initalPreference)
        speciesObservation.preferences.append(predationPreference)
        
        let heatSensitivityPreference = Preference()
        heatSensitivityPreference.configure(id: UUID().uuidString, type: Preferences.heatSensitivity, value: initalPreference)
        speciesObservation.preferences.append(heatSensitivityPreference)
        
        let humiditySensistivityPreference = Preference()
        humiditySensistivityPreference.configure(id: UUID().uuidString, type: Preferences.humditiySensitivity, value: initalPreference)
        speciesObservation.preferences.append(humiditySensistivityPreference)
        
        let habitatPreference = Preference()
        habitatPreference.configure(id: UUID().uuidString, type: Preferences.habitatPreference, value: "")
        
        speciesObservation.preferences.append(habitatPreference)
    }
    
    //step 4. populate data
    func generateTestData() {
        
        if let simConfig = systemConfiguration {
            
            for section in simConfig.sections {
                for group in section.groups {
                    
                    
                    populateWithSpeciesObservationTestData(for: group)
                    
                }
            }
            
        }
        
    }
    
    //populate speciesObservation with fake data
    func populateWithSpeciesObservationTestData(for group: Group?) {
        if let group = group, let simConfig = systemConfiguration?.simulationConfiguration  {
            let allSpecies = simConfig.species
            let allEcosystems = simConfig.ecosystems
            
            for so in group.speciesObservations {
                so.realm?.beginWrite()
                so.lastModified = Date()
                so.groupId = group.index
                for i in 0...Randoms.randomInt(0, 4) {
                    
                    let relationship = Relationship()
                    relationship.id = UUID().uuidString
                    relationship.toSpecies = allSpecies[Randoms.randomInt(0, 10)]
                    relationship.lastModified = Date()
                    relationship.note = Randoms.randomFakeConversation()
                    relationship.attachments = getRandomImage()
                    relationship.ecosystem = allEcosystems[Randoms.randomInt(0, 4)]
                    
                    
                    switch i {
                        //            case 0:
                    //                relationship.relationshipType = SpeciesRelationships.MUTUAL
                    case 0:
                        relationship.relationshipType = RelationshipType.producer.rawValue
                    case 1:
                        relationship.relationshipType = RelationshipType.consumer.rawValue
                    case 3:
                        relationship.relationshipType = RelationshipType.competes.rawValue
                    default:
                        relationship.relationshipType = RelationshipType.consumer.rawValue
                    }
                    
                    so.relationships.append(relationship)
                }
                
                try! so.realm?.commitWrite()
            }
        }
    }
    
    
    func addTestGroup() -> Group {
        let simulationConfiguration = loadSimulationConfiguration()
        
        let group = Group()
        group.id = UUID().uuidString
        group.name = Randoms.randomFakeGroupName()
        group.last_modified = Date()
        group.simulationConfiguration = simulationConfiguration
        
        
        //        let teacher = "Jonna Jet"
        //currentSection = "6DF"
        
        
        //four members
        for _ in 0...3 {
            let member = Member()
            member.id = UUID().uuidString
            member.name = Randoms.randomFakeFirstName()
            member.last_modified = Date()
            group.members.append(member)
        }
        
        let allEcosystems = group.simulationConfiguration!.ecosystems
        let allSpecies = group.simulationConfiguration!.species
        
        
        for fromSpecies in allSpecies {
            // var makeRelationship : (String, Group) -> List<SpeciesObservation>
            let s : SpeciesObservation = createSpeciesObservation(fromSpecies, allSpecies: allSpecies, allEcosystems: allEcosystems)
            s.groupId = group.index
            group.speciesObservations.append(s)
        }
        
        
        return group
    }
    
    
    //update species relationship
    func updateSpeciesObservation(_ toSpecies: Species, speciesObservation: SpeciesObservation, relationshipType: String){
        try! realm?.write {
            let relationship = Relationship()
            relationship.id = NSUUID().uuidString
            relationship.toSpecies = toSpecies
            relationship.lastModified = NSDate() as Date
            relationship.note = Randoms.randomFakeConversation()
            relationship.attachments = getRandomImage()
            relationship.ecosystem = speciesObservation.ecosystem
            relationship.relationshipType = relationshipType
            speciesObservation.relationships.append(relationship)
            realm?.add(relationship, update: true)
        }
    }
    
    func getRandomImage() -> String {
        
        let images = ["graph1","graph2","graph3","graph4","graph5","graph6","screenshot1","screenshot2","screenshot3"]
        
        return images[Randoms.randomInt(0, (images.count-1))]
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
            relationship.attachments = getRandomImage()
            relationship.ecosystem = ecosystem
            
            
            switch i {
                //            case 0:
            //                relationship.relationshipType = SpeciesRelationships.MUTUAL
            case 0:
                relationship.relationshipType = RelationshipType.producer.rawValue
            case 1:
                relationship.relationshipType = RelationshipType.consumer.rawValue
            case 3:
                relationship.relationshipType = RelationshipType.competes.rawValue
            default:
                relationship.relationshipType = RelationshipType.consumer.rawValue
            }
            
            speciesObservation.relationships.append(relationship)
        }
        
        
        return speciesObservation
    }
    
    
    
    // Mark: Nutella
    
    func checkNutellaConfigs() -> Bool {
        let foundConfigs = realm!.allObjects(ofType: NutellaConfig.self)
        
        if foundConfigs.isEmpty {
            let nutellaConfig = addNutellaConfigs()
            add(nutellaConfig, shouldUpdate: false)
            return false
        }
        if DEBUG {
            LOG.debug("Added Nutella Configs, not present")
        }
        
        
        
        return true
    }
    
    func addNutellaConfigs() -> NutellaConfig {
        let path = Bundle.main.path(forResource: "nutella_config", ofType: "json")
        let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path!))
        let json = JSON(data: jsonData!)
        
        let nutellaConfig = NutellaConfig()
        nutellaConfig.id = UUID().uuidString
        nutellaConfig.last_modified = Date()
        
        if let hosts = json["config"]["hosts"].array {
            for (_,item) in hosts.enumerated() {
                
                let host = Host()
                
                if let id = item["id"].string {
                    host.id = id
                }
                
                if let appId = item["appId"].string {
                    host.appId = appId
                }
                
                if let runId = item["runId"].string {
                    host.runId = runId
                }
                
                if let url = item["url"].string {
                    host.url = url
                }
                
                if let componentId = item["componentId"].string {
                    host.componentId = componentId
                }
                
                if let resourceId = item["resourceId"].string {
                    host.resourceId = resourceId
                }
                host.last_modified = Date()
                
                nutellaConfig.hosts.append(host)
            }
        }
        
        if let conditions = json["config"]["conditions"].array {
            for (_,item) in conditions.enumerated() {
                
                let condition = Condition()
                
                if let id = item["id"].string {
                    condition.id = id
                }
                
                if let subscribes = item["subscribes"].string {
                    condition.subscribes = subscribes
                }
                
                if let publishes = item["publishes"].string {
                    condition.publishes = publishes
                }
                
                condition.last_modified = Date()
                
                nutellaConfig.conditions.append(condition)
            }
        }
        
        try! realm!.write {
            realm!.add(nutellaConfig)
        }
        
        
        return nutellaConfig
    }
    
    // Mark: Configuration
    
    func loadSimulationConfiguration() -> SimulationConfiguration {
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
                
            }
            
        }
        
        return simulationConfiguration
    }
    
    func createTestConfiguration() {
        try! realm!.write {
            realm!.add(loadSystemConfiguration())
        }
    }
    
    // Mark: Species
    
    func findSpecies(_ speciesIndex: Int) -> Species? {
        let foundSpecies = realm!.allObjects(ofType: Species.self).filter(using:"index = \(speciesIndex)")[0] as Species!
        return foundSpecies
    }
    
    static func generateImageFileNameFromIndex(_ index: Int, isHighlighted: Bool) -> String {
        var imageName = ""
        
        var highlight = ""
        
        if !isHighlighted {
            highlight = "_0"
        }
        
        if index < 10 {
            imageName = "species_0\(index)\(highlight).png"
        } else {
            
            imageName = "species_\(index)\(highlight).png"
        }
        return imageName
    }
    
    static func generateImageForSpecies(_ index: Int, isHighlighted: Bool) -> UIImage? {
        let imageName = self.generateImageFileNameFromIndex(index, isHighlighted: isHighlighted)
        return UIImage(named: imageName)
    }
    
}

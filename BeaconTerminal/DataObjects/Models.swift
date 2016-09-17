import Foundation
import RealmSwift

struct Header {
    var speciesIndex: Int?
    var groupIndex: Int?
}

enum RelationshipType: String {
    case producer = "producer"
    case consumer = "consumer"
    case mutual = "mutual"
    case competes = "competes"
    static let allRelationships : [RelationshipType] = [.producer, .consumer, .competes]
}

class Member: Object {
    dynamic var id : String = UUID().uuidString
    dynamic var name : String? = nil
    dynamic var last_modified = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Section: Object {
    dynamic var id : String = UUID().uuidString
    dynamic var name : String? = nil
    dynamic var teacher : String? = nil
    dynamic var last_modified = Date()
    
    var members = List<Member>()
    var groups = List<Group>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Group: Object {
    dynamic var id : String = UUID().uuidString
    dynamic var name : String? = nil
    dynamic var index = 0
    dynamic var last_modified = Date()
    dynamic var simulationConfiguration : SimulationConfiguration? = nil
    var members = List<Member>()
    var speciesObservations = List<SpeciesObservation>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class SpeciesObservation: Object {
    dynamic var id : String? = nil
    dynamic var authors : String? = nil
    let isSynced = RealmOptional<Bool>()
    dynamic var groupIndex = 0
    dynamic var lastModified = Date()
    dynamic var fromSpecies: Species?
    dynamic var ecosystem: Ecosystem?
    
    var relationships = List<Relationship>()
    var preferences = List<Preference>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func update(withJson json:JSON, shouldParseId: Bool){
        
        if let authors = json["authors"].string {
            self.authors = authors
        }
        
        if let groupIndex = json["groupIndex"].int {
            self.groupIndex = groupIndex
        }
        
        if let isSynced = json["isSynced"].bool {
            self.isSynced.value = isSynced
        }
        
        if let fromSpecies = realmDataController.parseSpeciesJSON(withJson: json)  {
            self.fromSpecies = fromSpecies
        }
        
        if let ecosystem = realmDataController.parseEcosystemJSON(withJson: json)  {
            self.ecosystem = ecosystem
        }
        
        if shouldParseId {
            if let id = json["id"].string {
                self.id = id
            } else {
                self.id = "\(self.groupIndex)-\(self.fromSpecies?.index)"
            }
        }
        
    }
    
    
}



class Relationship: Object {
    dynamic var id : String? = nil
    dynamic var note: String? = nil
    dynamic var attachments : String? = nil
    dynamic var authors : Group? = nil
    dynamic var relationshipType: String = ""
    dynamic var lastModified = Date()
    dynamic var toSpecies: Species?
    dynamic var ecosystem: Ecosystem?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func generateId() {
        self.id = UUID().uuidString
    }
    
    func update(withJson json:JSON, shouldParseId: Bool){
        if shouldParseId {
            if let id = json["id"].string {
                self.id = id
            } else {
                self.id = UUID().uuidString
            }
        }
        if let attachments = json["attachments"].string {
            self.attachments = attachments
        }
        
        if let note = json["note"].string {
            self.note = note
        }
        
        if let relationshipType = json["relationshipType"].string {
            self.relationshipType = relationshipType
        }
        
        if let toSpecies = realmDataController.parseSpeciesJSON(withJson: json)  {
            self.toSpecies = toSpecies
        }
        
        if let ecosystem = realmDataController.parseEcosystemJSON(withJson: json)  {
            self.ecosystem = ecosystem
        }
        
        
    }
}

struct Preferences {
    static let trophicLevel = "trophic_level"
    static let behaviors = "behaviors"
    static let predationResistance = "predation_resistence"
    static let heatSensitivity = "heat_sensitivity"
    static let humditiySensitivity = "humidity_sensitivity"
    static let habitatPreference = "habitat_preference"
}

class Preference: Object {
    dynamic var id : String? = nil
    dynamic var note: String? = nil
    dynamic var value: String? = nil
    dynamic var attachments : String? = nil
    dynamic var type: String = ""
    dynamic var lastModified = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func configure(type: String, value: String) {
        self.type = type
        self.value = value
    }
    
    func update(withJson json:JSON, shouldParseId: Bool){
        if shouldParseId {
            if let id = json["id"].string {
                self.id = id
            } else {
                self.id = UUID().uuidString
            }
        }
        if let attachments = json["attachments"].string {
            self.attachments = attachments
        }
        if let note = json["note"].string {
            self.note = note
        }
        if let value = json["value"].string {
            self.value = value
        }
        if let type = json["type"].string {
            self.type = type
        }        
    }

}

class NutellaConfig: Object {
    dynamic var id: String = UUID().uuidString
    dynamic var last_modified = Date()
    var hosts = List<Host>()
    var conditions = List<Condition>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Host: Object {
    dynamic var id:String  = UUID().uuidString
    dynamic var last_modified = Date()
    
    dynamic var appId: String? = nil
    dynamic var runId: String? = nil
    dynamic var url: String? = nil
    dynamic var componentId: String? = nil
    dynamic var resourceId: String? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Condition: Object {
    dynamic var id: String = UUID().uuidString
    dynamic var last_modified = Date()
    dynamic var name: String? = nil
    dynamic var subscribes: String? = nil
    dynamic var publishes: String? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
class Channel: Object {
    dynamic var name: String? = nil
}

class SystemConfiguration: Object {
    dynamic var id = UUID().uuidString
    dynamic var last_modified = Date()
    dynamic var simulationConfiguration : SimulationConfiguration? = nil
    
    let sections = List<Section>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Runtime: Object {
    dynamic var id = UUID().uuidString
    dynamic var currentSectionName: String? = nil
    let currentGroupIndex = RealmOptional<Int>()
    let currentSpeciesIndex =  RealmOptional<Int>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}


class SimulationConfiguration: Object {
    dynamic var id = UUID().uuidString
    dynamic var last_modified = Date()
    
    let ecosystems = List<Ecosystem>()
    let species = List<Species>()
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Ecosystem: Object {
    dynamic var temperature = 0
    dynamic var pipelength = 0
    dynamic var brickarea = 0
    dynamic var name = ""
    dynamic var index = 0
    dynamic var last_modified = Date()
    
}

class Species: Object {
    
    dynamic var imgUrl = ""
    dynamic var color = ""
    dynamic var name = ""
    dynamic var index = 0
    dynamic var last_modified = Date()
    
    //    func convertHexColor() -> UIColor {
    //        if !color.isEmpty {
    //            return UIColor.init(hex: self.c)
    //        }
    //
    //        return UIColor.whiteColor()
    //    }
}

class User: Object {
    
    //    dynamic var id = ""
    dynamic var username = ""
    dynamic var displayName = ""
    dynamic var tags = ""
    dynamic var userRole = ""
    dynamic var last_modified = Date()
    dynamic var ecosystemGroup = ""
    
    
    // Specify properties to ignore (Realm won't persist these)
    
    //  override static func ignoredProperties() -> [String] {
    //    return []
    //  }
}

extension Realm {
    
    var species: Results<Species> {
        return allObjects(ofType: Species.self)
    }
    
    func speciesWithIndex(withIndex index: Int) -> Species? {
        return allObjects(ofType: Species.self).filter(using: "index = \(index)").first
    }
   
    func ecosystem(withIndex index: Int) -> Ecosystem? {
        return allObjects(ofType: Ecosystem.self).filter(using: "index = \(index)").first
    }
    
    func runtime() -> Runtime? {
        return allObjects(ofType: Runtime.self).first
    }
    
    func runtimeSectionName() -> String? {
        if let rt = runtime() {
            return rt.currentSectionName
        }
        return nil
    }
    
    func runtimeGroupIndex() -> Int? {
        if let rt = runtime() {
            return rt.currentGroupIndex.value
        }
        return nil
    }
    
    func runtimeSpeciesIndex() -> Int? {
        if let rt = runtime() {
            return rt.currentSpeciesIndex.value
        }
        return nil
    }
    
    func section(withName name: String) -> Section? {
        return allObjects(ofType: Section.self).filter(using: "name = '\(name)'").first
    }
    
    func sections() -> Results<Section> {
        return allObjects(ofType: Section.self)
    }
    
    func group(withSectionName sectionName: String, withGroupIndex index: Int) -> Group? {
        if let section = self.section(withName: sectionName) {
            return section.groups.filter(using: "index = \(index)").first
        }
        return nil
    }
    func groups(withSectionName sectionName: String) -> List<Group>? {
        if let section = self.section(withName: sectionName) {
            return section.groups
        }
        return nil
    }
    
    func currentGroups() -> List<Group>? {
        if let sectionName = runtimeSectionName() {
            return groups(withSectionName: sectionName)
        }
        return nil
    }
    
    func systemConfiguration() -> SystemConfiguration? {
        return allObjects(ofType: SystemConfiguration.self).first
    }
    
    func allSpeciesObservations(withSectionName sectionName: String, withGroupIndex index: Int) -> List<SpeciesObservation>? {
        if let group = self.group(withSectionName: sectionName, withGroupIndex: index) {
            return group.speciesObservations
        }
        return nil
    }
    
    func allSpeciesObservationsForCurrentSectionAndGroup() -> List<SpeciesObservation>? {        
        if let groupIndex = runtimeGroupIndex(), let sectionName = runtimeSectionName() {
            return allSpeciesObservations(withSectionName: sectionName, withGroupIndex: groupIndex)
        }
        return nil
    }
    
    func allSpeciesObservations() -> Results<SpeciesObservation> {
        return allObjects(ofType: SpeciesObservation.self)
    }
    
    func  speciesObservation(withFromSpeciesIndex speciesIndex: Int) -> Results<SpeciesObservation> {
        return allObjects(ofType: SpeciesObservation.self).filter(using: "fromSpecies.index = \(speciesIndex)")
    }
    
    func speciesObservation(withId id: String) -> SpeciesObservation? {
        return allObjects(ofType: SpeciesObservation.self).filter(using: "id = '\(id)'").first
    }
    
    func speciesObservation(FromCollection speciesObservations: List<SpeciesObservation>, withSpeciesIndex speciesIndex: Int) -> SpeciesObservation? {
        
        if speciesObservations.isEmpty {
            return nil
        }
        
        guard let found = speciesObservations.filter(using: "fromSpecies.index = \(speciesIndex)").first else {
            return nil
        }
        
        return found
    }
    
    func relationship(withSpeciesObservation speciesObservation: SpeciesObservation, withRelationshipType relationshipType: String, forSpeciesIndex speciesIndex: Int) -> Relationship? {
        
        let foundRelationships = speciesObservation.relationships.filter(using: "relationshipType = '\(relationshipType)'")
        
        if let toSpeciesFound = foundRelationships.filter(using: "toSpecies.index = \(speciesIndex)").first {
            return toSpeciesFound
        }

        
        return nil
    }
    
    
    func speciesObservations(withSectionName sectionName: String, withGroupIndex groupIndex: Int) -> List<SpeciesObservation>? {
        if let group = group(withSectionName: sectionName, withGroupIndex: groupIndex) {
            return group.speciesObservations
        }
        return nil
    }
    
    func speciesObservation(withGroup group: Group?, withFromSpeciesIndex index: Int) -> SpeciesObservation? {
        if let group = group {
            return group.speciesObservations.filter(using: "fromSpecies.index = \(index)").first
        }
        return nil
    }
    
    func speciesObservationCurrentSectionGroup(withFromSpeciesIndex fromSpeciesIndex: Int) -> SpeciesObservation? {
        if let currentSection = realm?.runtimeSectionName(), let groupIndex = realm?.runtimeGroupIndex() {
            if let group = group(withSectionName: currentSection, withGroupIndex: groupIndex) {
                return speciesObservation(FromCollection: group.speciesObservations, withSpeciesIndex: fromSpeciesIndex)

            }
        }
        return nil
    }
    
    func speciesObservationsCurrentSectionGroup() -> List<SpeciesObservation>? {
        if let currentSection = realm?.runtimeSectionName(), let groupIndex = realm?.runtimeGroupIndex() {
            if let group = group(withSectionName: currentSection, withGroupIndex: groupIndex) {
                return group.speciesObservations
            }
        }
        return nil
    }
    
    func allRelationships() -> Results<Relationship> {
        return allObjects(ofType: Relationship.self)
    }
    
    func relationship(withId id: String) -> Relationship? {
        return allObjects(ofType: Relationship.self).filter(using: "id = '\(id)'").first
    }
    
    func nutellaConfig() -> NutellaConfig? {
        return allObjects(ofType: NutellaConfig.self).first
    }
    
    func relationships(withSpeciesObservation speciesObservation: SpeciesObservation, withRelationshipType relationshipType: String) -> Results<Relationship>? {
        return speciesObservation.relationships.filter(using: "relationshipType = '\(relationshipType)'")
    }
    
    func preference(withId id: String) -> Preference? {
        return allObjects(ofType: Preference.self).filter(using: "id = '\(id)'").first
    }
    
    func allPreferences() -> Results<Preference> {
        return allObjects(ofType: Preference.self)
    }

}

// MARK: object extension for
extension Object {
    
    func toDictionary() -> NSDictionary {
        let properties = self.objectSchema.properties.map { $0.name }
        let dictionary = self.dictionaryWithValues(forKeys: properties)
        
        let mutabledic = NSMutableDictionary()
        mutabledic.setValuesForKeys(dictionary)
        
        for prop in self.objectSchema.properties as [Property]! {
            // find lists
            if let nestedObject = self[prop.name] as? Object {
                mutabledic.setValue(nestedObject.toDictionary(), forKey: prop.name)
            } else if let nestedListObject = self[prop.name] as? ListBase {
                var objects = [AnyObject]()
                for index in 0..<nestedListObject._rlmArray.count  {
                    let object = nestedListObject._rlmArray[index] as AnyObject
                    objects.append(object.toDictionary())
                }
                mutabledic.setObject(objects, forKey: prop.name as NSCopying)
            }  else if let dateObject = self[prop.name] as? NSDate {
                let dateString = dateObject.timeIntervalSince1970  //Perform the conversion you want here
                mutabledic.setValue(dateString, forKey: prop.name)
            }
            
        }
        return mutabledic
    }
    
}

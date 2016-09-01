import Foundation
import RealmSwift


enum RelationshipType: String {
    case producer = "producer"
    case consumer = "consumer"
    case mutual = "mutual"
    case competes = "competes"
    static let allRelationships : [RelationshipType] = [.producer, .consumer, .mutual, .competes]
    
    
}


class Member: Object {
    dynamic var id : String? = nil
    dynamic var name : String? = nil
    dynamic var last_modified = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Section: Object {
    dynamic var id : String? = nil
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
    dynamic var id : String? = nil
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
    dynamic var groupId = 0
    dynamic var lastModified = Date()
    dynamic var fromSpecies: Species?
    dynamic var ecosystem: Ecosystem?
    
    var relationships = List<Relationship>()
    var preferences = List<Preference>()
    
    
    override static func primaryKey() -> String? {
        return "id"
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
    dynamic var value : String? = nil
    dynamic var attachments : String? = nil
    dynamic var type: String = ""
    dynamic var lastModified = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func configure(id: String, type: String, value: String) {
        self.id = id
        self.type = type
        self.value = value
    }
}

class NutellaConfig: Object {
    dynamic var id : String? = nil
    dynamic var last_modified = Date()
    var hosts = List<Host>()
    var conditions = List<Condition>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Host: Object {
    dynamic var id : String? = nil
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
    dynamic var id : String? = nil
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
    dynamic var id : String? = nil
    dynamic var last_modified = Date()
    dynamic var simulationConfiguration : SimulationConfiguration? = nil
    
    let sections = List<Section>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Runtime: Object {
    dynamic var id : String? = nil
    dynamic var currentGroup: Group? = nil
    dynamic var currentSection: Section? = nil
    dynamic var currentSpecies: Species? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
}


class SimulationConfiguration: Object {
    dynamic var id : String? = nil
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
    dynamic var ecosystemNumber = 0
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
    
    func critterWithIndex(_ index: Int) -> Species {
        return allObjects(ofType: Species.self).filter(using: "index = \(index)")[0] as Species!
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

import Foundation
import RealmSwift

struct SpeciesRelationships {
    static let PRODUCER = "Producer"
    static let CONSUMER = "Consumer"
    static let COMPLETES = "Completes"
}

class Member: Object {
    dynamic var id : String? = nil
    dynamic var name : String? = nil
    dynamic var teacher : String? = nil
    dynamic var section : String? = nil
    dynamic var last_modified = NSDate()

    override static func primaryKey() -> String? {
        return "id"
    }
}

class Group: Object {
    dynamic var id : String? = nil
    dynamic var groupTitle : String? = nil
    dynamic var last_modified = NSDate()
    dynamic var simulationConfiguration : SimulationConfiguration? = nil
    let members = List<Member>()
    let speciesObservations = List<SpeciesObservation>()

    override static func primaryKey() -> String? {
        return "id"
    }

}



class SpeciesObservation: Object {
    dynamic var id : String? = nil

    //needs to be an array
    dynamic var note: String? = nil
    //dynamic var attachments = [String]()
    dynamic var authors : Group? = nil
    dynamic var title: String? = nil
    dynamic var relationship: String = ""
    dynamic var lastModified = NSDate()
    dynamic var toSpecies: Species?
    dynamic var fromSpecies: Species?
    dynamic var ecosystem: Ecosystem?

    override static func primaryKey() -> String? {
        return "id"
    }

}

class SimulationConfiguration: Object {
    dynamic var id : String? = nil
    dynamic var last_modified = NSDate()

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
    dynamic var last_modified = NSDate()

}

class Species: Object {

    dynamic var imgUrl = ""
    dynamic var color = ""
    dynamic var name = ""
    dynamic var index = 0
    dynamic var last_modified = NSDate()

    func convertHexColor() -> UIColor {
        if !color.isEmpty {
            return UIColor.init(hex: self.color)
        }
        
        return UIColor.whiteColor()
    }
}

class User: Object {

//    dynamic var id = ""
    dynamic var username = ""
    dynamic var displayName = ""
    dynamic var tags = ""
    dynamic var userRole = ""
    dynamic var last_modified = NSDate()
    dynamic var ecosystemGroup = ""


    // Specify properties to ignore (Realm won't persist these)

    //  override static func ignoredProperties() -> [String] {
    //    return []
    //  }
}

extension Realm {


    var species: Results<Species> {
        return objects(Species.self)
    }

    func critterWithIndex(index: Int) -> Species {
        
            return objects(Species).filter("index = \(index)")[0] as Species!
     
    }
}

// MARK: object extension for
extension Object {

    func toDictionary() -> NSDictionary {
        let properties = self.objectSchema.properties.map { $0.name }
        let dictionary = self.dictionaryWithValuesForKeys(properties)

        let mutabledic = NSMutableDictionary()
        mutabledic.setValuesForKeysWithDictionary(dictionary)

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
                mutabledic.setObject(objects, forKey: prop.name)
            }  else if let dateObject = self[prop.name] as? NSDate {
                let dateString = dateObject.timeIntervalSince1970  //Perform the conversion you want here
                mutabledic.setValue(dateString, forKey: prop.name)
            }

        }
        return mutabledic
    }

}

import Foundation
import RealmSwift

class Artifact: Object {

    dynamic var body: String = ""
    dynamic var author: String = ""
    dynamic var class_name: String = ""
    dynamic var title: String = ""
    dynamic var last_modified = NSDate()
    dynamic var type: String = ""
    dynamic var id: Int = 0
    dynamic var to_species: Critter?
    dynamic var from_species: Critter?
    dynamic var habitat: Habitat?

    override static func primaryKey() -> String? {
        return "id"
    }

}

class Configutation: Object {
    dynamic var id: String = ""
    dynamic var last_modified = NSDate()

    let habitats = List<Habitat>()
    let critters = List<Critter>()


    override static func primaryKey() -> String? {
        return "id"
    }
}

class Habitat: Object {

    dynamic var temperature = 0
    dynamic var pipelength = 0
    dynamic var brickarea = 0
    dynamic var name = ""
    dynamic var habitatNumber = 0
    dynamic var last_modified = NSDate()

}

class Critter: Object {

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

class Vote: Object {
    dynamic var mainCritter: Critter?
    dynamic var versusCritter: Critter?
    dynamic var voteCount = 0
    dynamic var id = 0


}

extension Vote {

    func containsIndex(index: Int) -> Bool {
        if let mc = mainCritter {
            if mc.index == index {
                return true
            }
        }
        if let vs = versusCritter {
            if vs.index == index {
                return true
            }
        }
        return false
    }
}

class User: Object {

    dynamic var id = ""
    dynamic var username = ""
    dynamic var displayName = ""
    dynamic var tags = ""
    dynamic var userRole = ""
    dynamic var last_modified = NSDate()
    dynamic var habitatGroup = ""


    // Specify properties to ignore (Realm won't persist these)

    //  override static func ignoredProperties() -> [String] {
    //    return []
    //  }
}

extension Realm {


    var critters: Results<Critter> {
        return objects(Critter.self)
    }

    func critterWithIndex(index: Int) -> Critter {
        do {
            return try objects(Critter).filter("index = \(index)")[0] as Critter!
        } catch {
            print("find critters with index action failed: \(error)")
        }
    }
}

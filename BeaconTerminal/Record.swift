

import Foundation
import RealmSwift

class Artifact : Object{
    
	dynamic var body : String = ""
	dynamic var author : String = ""
	dynamic var class_name : String = ""
	dynamic var title : String = ""
	dynamic var last_modified = NSDate()
	dynamic var type : String = ""
	dynamic var id : Int = 0
	dynamic var to_species: Critter?
	dynamic var from_species: Critter?
	dynamic var habitat: Habitat?

	override static func primaryKey() -> String?
	{
		return "id"
	}
    
}

class Configutation : Object{
    dynamic var id : String = ""
    dynamic var last_modified = NSDate()
    
    let habitats = List<Habitat>()
    let critters = List<Critter>()
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Habitat : Object{
    
    dynamic var temperature = 0
    dynamic var pipelength  = 0
    dynamic var brickarea = 0
    dynamic var name = ""
    dynamic var habitatNumber = 0
    dynamic var last_modified = NSDate()
    
}

class Critter : Object{
    
    dynamic var imgUrl  = ""
    dynamic var color = ""
    dynamic var name  = ""
    dynamic var index = 0
    dynamic var last_modified = NSDate()
    
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

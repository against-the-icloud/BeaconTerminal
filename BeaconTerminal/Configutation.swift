

import Foundation
import RealmSwift

class Configutation : Object{
    dynamic var id : String = ""
    dynamic var last_modified = NSDate()
    
    let habitats = List<Habitat>()
    let critters = List<Critter>()
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
}